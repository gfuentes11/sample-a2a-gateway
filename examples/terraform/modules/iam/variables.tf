variable "role_name" {
  description = "Name for the IAM execution role"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "ecr_repository_arn" {
  description = "ARN of the ECR repository this role needs access to"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the role"
  type        = map(string)
  default     = {}
}

variable "bedrock_model_id" {
  description = "Bedrock cross-region inference profile ID (e.g., us.anthropic.claude-sonnet-4-5-20250929-v1:0)"
  type        = string
}

variable "bedrock_cris_regions" {
  description = "Destination regions for the cross-region inference profile"
  type        = list(string)
}

