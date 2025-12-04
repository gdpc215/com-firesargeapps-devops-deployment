terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate${PROJECT_ID}"
    container_name       = "tfstate"
    key                  = "fsapps-${PROJECT_ID}.tfstate"
  }
}

provider "azurerm" {
  features {}
}

locals {
  project_id = "${PROJECT_ID}"
  environment = "dev"
  location = "eastus"
  
  common_tags = {
    Project     = "fsapps-${PROJECT_ID}"
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}
