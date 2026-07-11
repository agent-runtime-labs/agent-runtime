########################
# Reference pre-built Docker image (built in CI/CD pipeline)
# For local development, you can still build manually or use the build script
########################

# This resource is kept for local development scenarios
# In CI/CD, images are pre-built before Terraform runs
resource "null_resource" "build_and_push_image" {
  count = var.skip_docker_build ? 0 : 1

  triggers = {
    src_hash = local.agentcore_runtime_src_hash
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e

      AWS_REGION="${var.region}"
      REPO_URL="${local.ecr_repository_url}"
      IMAGE_TAG="${local.image_tag}"
      AGENTCORE_RUNTIME_SRC_DIR="${local.agentcore_runtime_src_abs_dir}"
      BACKEND_DIR="${local.agentcore_runtime_backend_abs_dir}"
      PLATFORM="${var.platform}"
      
      echo "Logging in to ECR..."
      aws ecr get-login-password --region "$AWS_REGION" \
        | docker login --username AWS --password-stdin "$REPO_URL" 2>&1 || {
          echo "Warning: Docker login encountered an issue, but continuing (credentials may be cached)"
        }

      echo "Building $PLATFORM image using buildx..."
      BUILDER_NAME="agentcore_runtime_builder_${var.agent_name}"
      docker buildx create --use --name "$BUILDER_NAME" 2>/dev/null || docker buildx use "$BUILDER_NAME"

      echo "Building $PLATFORM image..."
      docker buildx build \
        --platform $PLATFORM \
        --target dist \
        --load \
        --progress=plain \
        -f "$AGENTCORE_RUNTIME_SRC_DIR/Dockerfile" \
        -t "$REPO_URL:$IMAGE_TAG" \
        "$BACKEND_DIR"

      echo "Pushing Docker image to $REPO_URL:$IMAGE_TAG"
      docker push "$REPO_URL:$IMAGE_TAG"
    EOT

    interpreter = ["/bin/bash", "-c"]
  }
}
