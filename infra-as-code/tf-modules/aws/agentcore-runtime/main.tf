# ============================================================================
# AgentCore Runtime - Main Agent Runtime Resource
# ============================================================================

resource "aws_bedrockagentcore_agent_runtime" "agentcore_runtime" {
  agent_runtime_name = local.resource_name_prefix_underscored
  description        = var.agent_description
  role_arn           = aws_iam_role.agent_execution.arn

  agent_runtime_artifact {
    container_configuration {
      container_uri = "${local.ecr_repository_url}:${local.image_tag}"
    }
  }

  network_configuration {
    network_mode = var.network_mode

    dynamic "network_mode_config" {
      for_each = var.network_mode == "VPC" ? [1] : []
      content {
        security_groups = var.vpc_security_group_ids
        subnets         = var.vpc_subnet_ids
      }
    }
  }

  dynamic "authorizer_configuration" {
    for_each = var.authorizer_config.enabled ? [1] : []
    content {
      custom_jwt_authorizer {
        discovery_url    = var.authorizer_config.discovery_url

        allowed_scopes   = var.authorizer_config.allowed_scopes
      }
    }
  }

  request_header_configuration {
    request_header_allowlist = var.request_header_allowlist
  }

  environment_variables = merge(
    {
      AWS_ACCOUNT_ID     = data.aws_caller_identity.current.account_id
      AWS_REGION         = data.aws_region.current.region
      AWS_DEFAULT_REGION = data.aws_region.current.region
    },
    var.environment_variables
  )

  depends_on = [
    null_resource.build_and_push_image,
    aws_iam_role_policy.agent_execution,
    aws_iam_role_policy_attachment.agent_execution_managed
  ]
}
