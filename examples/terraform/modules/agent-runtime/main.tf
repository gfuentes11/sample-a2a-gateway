data "aws_region" "current" {}

resource "aws_bedrockagentcore_agent_runtime" "a2a_agent" {
  agent_runtime_name = var.agent_runtime_name
  description        = var.description
  role_arn           = var.role_arn

  lifecycle {
    precondition {
      condition     = var.network_mode != "VPC" || length(var.subnet_ids) > 0
      error_message = "subnet_ids must be provided when network_mode is VPC."
    }
    precondition {
      condition     = var.network_mode != "VPC" || length(var.security_group_ids) > 0
      error_message = "security_group_ids must be provided when network_mode is VPC."
    }
  }

  agent_runtime_artifact {
    container_configuration {
      container_uri = var.container_uri
    }
  }

  network_configuration {
    network_mode = var.network_mode

    dynamic "network_mode_config" {
      for_each = var.network_mode == "VPC" ? [1] : []
      content {
        subnets         = var.subnet_ids
        security_groups = var.security_group_ids
      }
    }
  }

  protocol_configuration {
    server_protocol = "A2A"
  }

  authorizer_configuration {
    custom_jwt_authorizer {
      discovery_url   = var.discovery_url
      allowed_clients = var.allowed_clients
    }
  }

  environment_variables = merge(
    {
      AWS_REGION         = var.region
      AWS_DEFAULT_REGION = var.region
    },
    var.environment_variables
  )

  tags = var.tags
}

locals {
  encoded_arn = urlencode(aws_bedrockagentcore_agent_runtime.a2a_agent.agent_runtime_arn)
  base_url    = "https://bedrock-agentcore.${data.aws_region.current.id}.amazonaws.com/runtimes/${local.encoded_arn}/invocations"
}
