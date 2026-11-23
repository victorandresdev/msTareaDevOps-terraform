resource "azurerm_resource_group" "rg_01_name" {
  name     = var.rg_01_name
  location = var.location
  tags     = var.tags
}