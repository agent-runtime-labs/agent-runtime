data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  resource_name_prefix_hyphenated = format("%s-%s", lower(var.env), lower(var.lambda_name))
  lambda_backend_abs_dir          = "${path.module}/${var.backend_directory}"
  lambda_src_abs_dir              = "${local.lambda_backend_abs_dir}/${var.lambda_src_dir}"
  lambda_shared_abs_dir           = "${local.lambda_backend_abs_dir}/shared"
  lambda_src_files                = fileset(local.lambda_src_abs_dir, "**")
  lambda_shared_src_files         = fileset(local.lambda_shared_abs_dir, "**")

  lambda_src_content_hash = sha1(
    join("", [for f in local.lambda_src_files : filesha1("${local.lambda_src_abs_dir}/${f}")])
  )

  lambda_shared_content_hash = sha1(
    join("", [for f in local.lambda_shared_src_files : filesha1("${local.lambda_shared_abs_dir}/${f}")])
  )

  lambda_src_hash = sha1("${local.lambda_src_content_hash}-${local.lambda_shared_content_hash}")

  image_tag = var.docker_image_tag != "" ? var.docker_image_tag : local.lambda_src_hash

  ecr_repository_url = var.skip_ecr_creation ? var.ecr_repository_url : aws_ecr_repository.lambda[0].repository_url

  ecr_repo_name_from_url = var.skip_ecr_creation ? split("/", var.ecr_repository_url)[1] : "local-${local.resource_name_prefix_hyphenated}"

  ecr_repository_arn = var.skip_ecr_creation ? (
    "arn:aws:ecr:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:repository/${local.ecr_repo_name_from_url}"
  ) : aws_ecr_repository.lambda[0].arn
}
