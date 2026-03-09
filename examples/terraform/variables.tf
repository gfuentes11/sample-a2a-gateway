variable "aws_region" {
  description = "AWS region for deployment"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d{1}$", var.aws_region))
    error_message = "Must be a valid AWS region (e.g., us-east-1, eu-west-1)"
  }
}

variable "stack_name" {
  description = "Stack name used for resource naming"
  type        = string
  default     = "agentcore-a2a-sample"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "weather_agent_name" {
  description = "Name for the weather agent runtime"
  type        = string
  default     = "WeatherAgent"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{0,47}$", var.weather_agent_name))
    error_message = "Agent name must start with a letter, max 48 chars, alphanumeric and underscores only."
  }
}

variable "calculator_agent_name" {
  description = "Name for the calculator agent runtime"
  type        = string
  default     = "CalculatorAgent"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{0,47}$", var.calculator_agent_name))
    error_message = "Agent name must start with a letter, max 48 chars, alphanumeric and underscores only."
  }
}

variable "network_mode" {
  description = "Network mode for AgentCore runtimes (PUBLIC or VPC)"
  type        = string
  default     = "PUBLIC"

  validation {
    condition     = contains(["PUBLIC", "VPC"], var.network_mode)
    error_message = "Network mode must be either PUBLIC or VPC."
  }
}

variable "subnet_ids" {
  description = "Subnet IDs for VPC mode. Required when network_mode is VPC. Use private subnets in supported AZs."
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Security group IDs for VPC mode. Required when network_mode is VPC."
  type        = list(string)
  default     = []
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "ecr_repository_name" {
  description = "Base name for ECR repositories"
  type        = string
  default     = "a2a-agents"
}

variable "bedrock_model_id" {
  description = "Bedrock cross-region inference profile ID for agent model invocation"
  type        = string
  default     = "us.anthropic.claude-sonnet-4-5-20250929-v1:0"
}

variable "bedrock_cris_regions" {
  description = "Destination regions for the US geographic cross-region inference profile"
  type        = list(string)
  default     = ["us-east-1", "us-east-2", "us-west-2"]
}
