variable "backend_directory" {
  type        = string
  description = "Path to the backend directory for Terraform state"
  default     = "../../../../backend"
}
# Folder that contains Dockerfile + Agent source
variable "agent_src_dir" {
  type        = string
  description = "Path to the folder containing Dockerfile and Agent code"
}

variable "agent_name" {
  type = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{0,47}$", var.agent_name))
    error_message = "Agent name must start with a letter, max 48 characters, alphanumeric and underscores only."
  }

}

variable "agent_description" {
  type        = string
  description = "Description for the AgentCore Runtime agent"
  default     = "AgentCore Runtime agent"
}


variable "network_mode" {
  description = "Network mode for AgentCore resources"
  type        = string
  default     = "PUBLIC"

  validation {
    condition     = contains(["PUBLIC", "VPC"], var.network_mode)
    error_message = "Network mode must be either PUBLIC or VPC."
  }
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables to pass to the AgentCore Runtime function"
  default     = {}
}

variable "additional_iam_policy_arns" {
  type        = list(string)
  description = "Optional: Additional IAM policy ARNs to attach to AgentCore Runtime role"
  default     = []
}

variable "authorizer_config" {
  type = object({
    enabled           = bool
    discovery_url     = string
    allowed_audiences = list(string)
    allowed_scopes   = list(string)
  })
  description = "Custom JWT authorizer configuration for the agent runtime"
  default = {
    enabled           = false
    discovery_url     = ""
    allowed_audiences = []
    allowed_scopes   = []
  }
}

variable "request_header_allowlist" {
  type        = list(string)
  description = "List of HTTP headers to forward to the Lambda function"
  default     = []
}

variable "skip_docker_build" {
  type        = bool
  description = "Skip Docker build in Terraform (for CI/CD where images are pre-built)"
  default     = false
}

variable "skip_ecr_creation" {
  type        = bool
  description = "Skip ECR repository creation (use when ECR is created externally, e.g., in CI/CD)"
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
  default     = "linux/arm64"

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


variable "vpc_subnet_ids" {
  type        = list(string)
  description = "Optional: VPC subnet IDs for AgentCore Runtime function"
  default     = []
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "Optional: VPC security group IDs for AgentCore Runtime function"
  default     = []
}
