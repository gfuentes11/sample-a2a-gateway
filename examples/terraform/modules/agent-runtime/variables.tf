variable "agent_runtime_name" {
  description = "Name for the AgentCore agent runtime"
  type        = string
}

variable "description" {
  description = "Description of the agent runtime"
  type        = string
  default     = ""
}

variable "role_arn" {
  description = "IAM execution role ARN"
  type        = string
}

variable "container_uri" {
  description = "Full container image URI (repo:tag)"
  type        = string
}

variable "network_mode" {
  description = "Network mode for the agent runtime (PUBLIC or VPC)"
  type        = string
  default     = "PUBLIC"

  validation {
    condition     = contains(["PUBLIC", "VPC"], var.network_mode)
    error_message = "Network mode must be either PUBLIC or VPC."
  }
}

variable "subnet_ids" {
  description = "Subnet IDs for VPC mode (required when network_mode is VPC)"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Security group IDs for VPC mode (required when network_mode is VPC)"
  type        = list(string)
  default     = []
}

variable "discovery_url" {
  description = "OIDC discovery URL for JWT authorizer"
  type        = string
}

variable "allowed_clients" {
  description = "List of allowed OAuth client IDs"
  type        = list(string)
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the agent container"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to the runtime"
  type        = map(string)
  default     = {}
}
