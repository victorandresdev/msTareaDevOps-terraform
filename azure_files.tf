resource "azurerm_storage_share" "share_01" {
  name                 = var.share_01_name
  storage_account_name = azurerm_storage_account.st_01.name
  quota                = 1
}

resource "azurerm_container_app_environment_storage" "storage_01" {
  name                         = "imagenes-storage"
  container_app_environment_id = azurerm_container_app_environment.cae_01.id
  account_name                 = azurerm_storage_account.st_01.name
  share_name                   = azurerm_storage_share.share_01.name
  access_key                   = azurerm_storage_account.st_01.primary_access_key
  access_mode                  = "ReadOnly"
}