# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  resource_name_prefix_underscored   = format("%s_%s", lower(var.env), lower(var.agent_name))
  agentcore_runtime_backend_abs_dir  = "${path.module}/${var.backend_directory}"
  agentcore_runtime_src_abs_dir      = "${local.agentcore_runtime_backend_abs_dir}/${var.agent_src_dir}"
  agentcore_runtime_shared_abs_dir   = "${local.agentcore_runtime_backend_abs_dir}/shared"
  agentcore_runtime_src_files        = fileset(local.agentcore_runtime_src_abs_dir, "**")
  agentcore_runtime_shared_src_files = fileset(local.agentcore_runtime_shared_abs_dir, "**")

  # Combined content hash over agentcore_runtime source files
  agentcore_runtime_src_content_hash = sha1(
    join(
      "",
      [
        for f in local.agentcore_runtime_src_files :
        filesha1("${local.agentcore_runtime_src_abs_dir}/${f}")
      ]
    )
  )

  # Combined content hash over shared files
  agentcore_runtime_shared_content_hash = sha1(
    join(
      "",
      [
        for f in local.agentcore_runtime_shared_src_files :
        filesha1("${local.agentcore_runtime_shared_abs_dir}/${f}")
      ]
    )
  )

  # Combined hash of both source and shared files
  agentcore_runtime_src_hash = sha1("${local.agentcore_runtime_src_content_hash}-${local.agentcore_runtime_shared_content_hash}")

  # Use provided docker_image_tag if set, otherwise use computed hash
  # This allows CI/CD to use pre-built images with specific tags (e.g., git sha)
  image_tag = var.docker_image_tag != "" ? var.docker_image_tag : local.agentcore_runtime_src_hash

  # Use external ECR URL if provided, otherwise use created ECR
  ecr_repository_url = var.skip_ecr_creation ? var.ecr_repository_url : aws_ecr_repository.agentcore_runtime[0].repository_url

  # Extract repository name from ECR URL (format: account.dkr.ecr.region.amazonaws.com/repo-name)
  ecr_repo_name_from_url = var.skip_ecr_creation ? split("/", var.ecr_repository_url)[1] : "local-${local.resource_name_prefix_underscored}"

  # Construct ECR ARN for IAM policies
  # When ECR is created by Terraform, use its ARN; when provided externally, construct from URL
  ecr_repository_arn = var.skip_ecr_creation ? (
    "arn:aws:ecr:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:repository/${local.ecr_repo_name_from_url}"
  ) : aws_ecr_repository.agentcore_runtime[0].arn
}
