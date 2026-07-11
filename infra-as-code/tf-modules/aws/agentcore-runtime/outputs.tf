output "agent_runtime_arn" {
  description = "ARN of the Agent Runtime"
  value       = aws_bedrockagentcore_agent_runtime.agentcore_runtime.agent_runtime_arn
}

output "agent_runtime_id" {
  description = "Unique identifier of the Agent Runtime"
  value       = aws_bedrockagentcore_agent_runtime.agentcore_runtime.agent_runtime_id
}

output "ecr_repository_url" {
  value       = local.ecr_repository_url
  description = "ECR repository URL"
}

output "role_arn" {
  description = "ARN of the IAM execution role attached to the AgentCore Runtime"
  value       = aws_iam_role.agent_execution.arn
}
