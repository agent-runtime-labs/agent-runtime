data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
locals {
  aws_account_id       = data.aws_caller_identity.current.account_id
  resource_name_prefix = format("%s-%s-%s-%s", local.aws_account_id, var.env, var.resource_region_short, var.project_name)
  ssm_param_prefix     = format("/%s/%s", var.env, var.project_name)
    # Decode base64-encoded ECR URLs JSON from CI/CD
  ecr_urls_decoded = var.ecr_urls != "" ? jsondecode(base64decode(var.ecr_urls)) : {}

}