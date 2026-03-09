locals {
  # Strip geographic prefix (e.g., "us.") from the inference profile ID to get the foundation model ID
  foundation_model_id = replace(var.bedrock_model_id, "/^[a-z]+\\./", "")
}

resource "aws_iam_role" "agent_execution" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AssumeRolePolicy"
      Effect = "Allow"
      Principal = {
        Service = "bedrock-agentcore.amazonaws.com"
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = var.account_id
        }
        ArnLike = {
          "aws:SourceArn" = "arn:aws:bedrock-agentcore:${var.region}:${var.account_id}:*"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "execution" {
  name = "${var.role_name}-policy"
  role = aws_iam_role.agent_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ECRImageAccess"
        Effect   = "Allow"
        Action   = ["ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer", "ecr:BatchCheckLayerAvailability"]
        Resource = var.ecr_repository_arn
      },
      {
        Sid      = "ECRTokenAccess"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid      = "CloudWatchLogs"
        Effect   = "Allow"
        Action   = ["logs:DescribeLogStreams", "logs:CreateLogGroup", "logs:DescribeLogGroups", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/bedrock-agentcore/runtimes/*"
      },
      {
        Sid      = "XRayTracing"
        Effect   = "Allow"
        Action   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords", "xray:GetSamplingRules", "xray:GetSamplingTargets"]
        Resource = "*"
      },
      {
        Sid       = "CloudWatchMetrics"
        Effect    = "Allow"
        Action    = ["cloudwatch:PutMetricData"]
        Resource  = "*"
        Condition = { StringEquals = { "cloudwatch:namespace" = "bedrock-agentcore" } }
      },
      {
        Sid      = "BedrockCrisInferenceProfileAccess"
        Effect   = "Allow"
        Action   = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
        Resource = "arn:aws:bedrock:${var.region}:${var.account_id}:inference-profile/${var.bedrock_model_id}"
      },
      {
        Sid    = "BedrockCrisModelAccess"
        Effect = "Allow"
        Action = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
        Resource = [
          for r in var.bedrock_cris_regions :
          "arn:aws:bedrock:${r}::foundation-model/${local.foundation_model_id}"
        ]
        Condition = {
          StringEquals = {
            "bedrock:InferenceProfileArn" = "arn:aws:bedrock:${var.region}:${var.account_id}:inference-profile/${var.bedrock_model_id}"
          }
        }
      }
    ]
  })
}
