# ========================================
# ECR Repository
# ========================================

# ECR repository for the agentcore_runtime Docker image
# Only create if not using pre-built images from CI/CD
resource "aws_ecr_repository" "agentcore_runtime" {
  count = var.skip_ecr_creation ? 0 : 1

  name                 = "local-${local.resource_name_prefix_underscored}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true # Allow deletion even with images

  image_scanning_configuration {
    scan_on_push = false
  }
}
