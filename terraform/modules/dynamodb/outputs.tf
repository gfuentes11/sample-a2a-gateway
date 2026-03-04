output "agent_registry_table_name" {
  description = "Name of the AgentRegistry DynamoDB table"
  value       = aws_dynamodb_table.agent_registry.name
}

output "agent_registry_table_arn" {
  description = "ARN of the AgentRegistry DynamoDB table"
  value       = aws_dynamodb_table.agent_registry.arn
}

output "permissions_table_name" {
  description = "Name of the Permissions DynamoDB table"
  value       = aws_dynamodb_table.permissions.name
}

output "permissions_table_arn" {
  description = "ARN of the Permissions DynamoDB table"
  value       = aws_dynamodb_table.permissions.arn
}

output "rate_limit_counters_table_name" {
  description = "Name of the RateLimitCounters DynamoDB table"
  value       = aws_dynamodb_table.rate_limit_counters.name
}

output "rate_limit_counters_table_arn" {
  description = "ARN of the RateLimitCounters DynamoDB table"
  value       = aws_dynamodb_table.rate_limit_counters.arn
}
