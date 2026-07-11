
################################################################################
# DynamoDB Table for Orchestrator Task Results
################################################################################

module "orchestrator_task_results_table" {
  source = "../tf-modules/aws/dynamodb-table"

  name         = "${var.env}-${var.project_name_short}-orchestrator-task-results"
  billing_mode = "PAY_PER_REQUEST"

  # Primary key configuration
  hash_key = "task_id"
  attributes = [
    {
      name = "task_id"
      type = "S"
    }
  ]

  # Enable TTL for automatic cleanup of old task results (1 hour)
  ttl_enabled        = true
  ttl_attribute_name = "ttl"

  # Enable point-in-time recovery for production environments
  point_in_time_recovery_enabled = var.env == "prod" ? true : false

  # Enable encryption at rest
  server_side_encryption_enabled = true
}

# IAM Policy for Lambda to access DynamoDB table
resource "aws_iam_policy" "orchestrator_dynamodb_access" {
  name        = "${var.env}-${var.project_name_short}-orchestrator-dynamodb"
  description = "Allow orchestrator Lambda to access DynamoDB task results table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          module.orchestrator_task_results_table.dynamodb_table_arn,
          "${module.orchestrator_task_results_table.dynamodb_table_arn}/*"
        ]
      }
    ]
  })
}

# Store DynamoDB table name in SSM Parameter Store
resource "aws_ssm_parameter" "orchestrator_task_results_table_name" {
  name        = "${local.ssm_param_prefix}/orchestrator/task-results-table-name"
  description = "DynamoDB table name for orchestrator task results in ${var.env}"
  type        = "String"
  value       = module.orchestrator_task_results_table.dynamodb_table_id
}

################################################################################
# AgentCore Runtime for Orchestrator
################################################################################

module "agentcore_runtime_orchestrator_agent" {
  source = "../tf-modules/aws/agentcore-runtime"

  env    = var.env
  region = var.resource_region

  agent_name    = "${var.project_name_short}_orchestrator"
  agent_src_dir = "/agents/orchestrator"

  # Use pre-built image from CI/CD if available
  skip_docker_build = var.docker_image_tag != "" ? true : false
  docker_image_tag  = var.docker_image_tag

  # Use external ECR from CI/CD if provided
  skip_ecr_creation  = try(local.ecr_urls_decoded["${var.project_name}-orchestrator"], "") != "" ? true : false
  ecr_repository_url = try(local.ecr_urls_decoded["${var.project_name}-orchestrator"], "")

  # JWT authorizer configuration for runtime
  authorizer_config = {
    enabled           = true
    discovery_url     = "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_vpcJtdeVX/.well-known/openid-configuration"
    allowed_audiences = ["default-m2m-resource-server-5f796"]
    allowed_scopes   = ["default-m2m-resource-server-5f796/read"]
  }


  # Forward Authorization header to Lambda
  request_header_allowlist = ["Authorization"]

  additional_iam_policy_arns = [
    aws_iam_policy.common_ssm_parameter_access.arn,
    aws_iam_policy.common_bedrock_kb_access.arn,
    aws_iam_policy.orchestrator_dynamodb_access.arn,
  ]


  environment_variables = merge(
    {
      ENV       = var.env
    },
    {
      # DynamoDB table for task results
      ORCHESTRATOR_TASK_RESULTS_TABLE_NAME = module.orchestrator_task_results_table.dynamodb_table_id
      TALENT_KB_SSM_KB_ID_PATH = var.talent_kb_ssm_kb_id_path

    },
    
  )
}

# Store Agent Runtime ARN in SSM Parameter Store
resource "aws_ssm_parameter" "orchestrator_runtime_arn" {
  name        = "${local.ssm_param_prefix}/orchestrator/agentcore-runtime-arn"
  description = "Bedrock AgentCore Runtime ARN for orchestrator in ${var.env}"
  type        = "String"
  value       = module.agentcore_runtime_orchestrator_agent.agent_runtime_arn

}
