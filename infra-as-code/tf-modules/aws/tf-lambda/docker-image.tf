resource "null_resource" "build_and_push_image" {
  count = var.skip_docker_build ? 0 : 1

  triggers = {
    src_hash = local.lambda_src_hash
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e

      AWS_REGION="${var.region}"
      REPO_URL="${local.ecr_repository_url}"
      IMAGE_TAG="${local.image_tag}"
      LAMBDA_SRC_DIR="${local.lambda_src_abs_dir}"
      BACKEND_DIR="${local.lambda_backend_abs_dir}"
      PLATFORM="${var.platform}"

      echo "Logging in to ECR..."
      aws ecr get-login-password --region "$AWS_REGION" \
        | docker login --username AWS --password-stdin "$REPO_URL" 2>&1 || {
          echo "Warning: Docker login encountered an issue, but continuing (credentials may be cached)"
        }

      echo "Building $PLATFORM image using buildx..."
      BUILDER_NAME="lambda_builder_${var.lambda_name}"
      docker buildx create --use --name "$BUILDER_NAME" 2>/dev/null || docker buildx use "$BUILDER_NAME"

      echo "Building $PLATFORM image..."
      docker buildx build \
        --platform $PLATFORM \
        --load \
        --progress=plain \
        -f "$LAMBDA_SRC_DIR/Dockerfile.lambda" \
        -t "$REPO_URL:$IMAGE_TAG" \
        "$BACKEND_DIR"

      echo "Pushing Docker image to $REPO_URL:$IMAGE_TAG"
      docker push "$REPO_URL:$IMAGE_TAG"
    EOT

    interpreter = ["/bin/bash", "-c"]
  }
}
