# ============================================================================
# Common IAM Policy for SSM Parameter Store Access
# ============================================================================
resource "aws_iam_policy" "common_ssm_parameter_access" {
  name        = "${var.project_name}-${var.env}-common-ssm-parameter-access"
  description = "Allow read access to SSM parameters for ${var.project_name} in ${var.env}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SSMParameterAccess"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = concat(
          ["arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.id}:parameter${local.ssm_param_prefix}/*"],
          ["arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.id}:parameter/${var.env}/talent-mcp-server/*"]
        )
      }
    ]
  })
}

# ============================================================================
# Common IAM Policy for Bedrock Knowledge Base Access
# ============================================================================
resource "aws_iam_policy" "common_bedrock_kb_access" {
  name        = "${var.project_name}-${var.env}-common-bedrock-kb-access"
  description = "Allow access to Bedrock models and knowledge bases for ${var.project_name} in ${var.env}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BedrockModelInvocation"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:ApplyGuardrail",
          "bedrock:Retrieve",
          "bedrock:RetrieveAndGenerate",
          "bedrock:GetInferenceProfile"
        ]
        Resource = [
          "arn:aws:bedrock:*::foundation-model/*",
          "arn:aws:bedrock:${data.aws_region.current.region}:${data.aws_caller_identity.current.id}:knowledge-base/*",
          "arn:aws:bedrock:${data.aws_region.current.region}:${data.aws_caller_identity.current.id}:inference-profile/*"
        ]
      }
    ]
  })
}