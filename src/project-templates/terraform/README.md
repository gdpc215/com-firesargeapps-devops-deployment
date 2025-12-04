# fsapps-${PROJECT_ID}-iaac

Infrastructure as Code (IaC) repository for project ${PROJECT_ID}.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Azure subscription

## Getting Started

1. Login to Azure:
```bash
az login
```

2. Initialize Terraform:
```bash
terraform init
```

3. Plan changes:
```bash
terraform plan
```

4. Apply changes:
```bash
terraform apply
```

## Project Structure

- `main.tf` - Main configuration and provider setup
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `resource-group.tf` - Resource group configuration

## Project ID

This project uses the identifier: **${PROJECT_ID}**
