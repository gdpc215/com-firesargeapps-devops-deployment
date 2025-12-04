variable "project_id" {
  description = "Project identifier"
  type        = string
  default     = "${PROJECT_ID}"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "rg-fsapps-${PROJECT_ID}"
}
