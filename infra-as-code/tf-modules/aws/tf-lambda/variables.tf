variable "backend_directory" {
  type        = string
  description = "Path to the backend directory for Terraform state"
  default     = "../../../../backend"
}

variable "lambda_src_dir" {
  type        = string
  description = "Path to the folder containing Dockerfile and Lambda code"
}

variable "lambda_name" {
  type = string
}

variable "lambda_memory_size" {
  type        = number
  description = "Lambda memory in MB"
  default     = 512
}

variable "lambda_timeout" {
  type        = number
  description = "Lambda timeout in seconds"
  default     = 30
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables to pass to the Lambda function"
  default     = {}
}

variable "additional_iam_policy_arns" {
  type        = list(string)
  description = "Optional: Additional IAM policy ARNs to attach to Lambda role"
  default     = []
}

variable "vpc_subnet_ids" {
  type        = list(string)
  description = "Optional: VPC subnet IDs for Lambda function"
  default     = []
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Optional: VPC security group IDs for Lambda function"
  default     = []
}

variable "skip_docker_build" {
  type        = bool
  description = "Skip Docker build in Terraform (for CI/CD where images are pre-built)"
  default     = false
}

variable "skip_ecr_creation" {
  type        = bool
  description = "Skip ECR repository creation (use when ECR is created externally)"
  default     = false
}

variable "ecr_repository_url" {
  type        = string
  description = "ECR repository URL (required when skip_ecr_creation=true)"
  default     = ""
}

variable "platform" {
  type        = string
  description = "Docker platform architecture (linux/amd64 or linux/arm64)"
  default     = "linux/amd64"

  validation {
    condition     = contains(["linux/amd64", "linux/arm64"], var.platform)
    error_message = "Platform must be either linux/amd64 or linux/arm64."
  }
}

variable "docker_image_tag" {
  type        = string
  description = "Docker image tag to use (overrides computed hash). Used in CI/CD with pre-built images."
  default     = ""
}
