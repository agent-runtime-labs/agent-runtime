variable "docker_image_tag" {
  type        = string
  description = "Docker image tag for pre-built images (from CI/CD). Empty string uses computed hash."
  default     = ""
}

variable "ecr_urls" {
  type        = string
  description = "Base64-encoded JSON object with ECR repository URLs for pre-built images (from CI/CD). Empty string triggers ECR creation in Terraform."
  default     = ""
}

variable "talent_kb_ssm_kb_id_path" {
  type        = string
  description = "SSM Parameter path for the Talent KB ID (used by orchestrator and talent-kb Lambda)."
  default     = ""
}