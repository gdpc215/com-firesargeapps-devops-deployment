resource "azurerm_resource_group" "main" {
  name     = "rg-fsapps-${PROJECT_ID}-${local.environment}"
  location = local.location
  tags     = local.common_tags
}
