variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project Identifier"
  type        = string
  default     = "dr-vault"


  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Use lowercase letters, numbers and hyphens only."
  }
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging or prod."
  }
}

variable "noncurrent_version_expiration_days" {
  description = "Days before noncurrent object versions expire"
  type        = number
  default     = 90

  validation {
    condition     = var.noncurrent_version_expiration_days >= 30
    error_message = "Keep noncurrent versions for at least 30 days."
  }
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)

  default = {
    Project     = "Terraform-S3-DR-Vault"
    ManagedBy   = "Terraform"
    Environment = "dev"
    Owner       = "DevOps"
  }
}