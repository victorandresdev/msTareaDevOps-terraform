resource "azurerm_container_app_environment" "cae_01" {
name                               = var.cae_01_name
location                           = azurerm_resource_group.rg_01_name.location
resource_group_name                = azurerm_resource_group.rg_01_name.name
infrastructure_resource_group_name = var.cae_01_name
tags = merge(var.tags, {
    Workload = "Transversal"
})

workload_profile {
    name                  = var.cae_01_workload_profile
    workload_profile_type = var.cae_01_workload_profile
}
lifecycle {
    ignore_changes = [
    infrastructure_resource_group_name
    ]
}
}

resource "azurerm_container_app" "aca_01" {
  name                         = var.aca_01_name
  container_app_environment_id = azurerm_container_app_environment.cae_01.id
  resource_group_name          = azurerm_resource_group.rg_01_name.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity_01.id]
  }
  secret {
    name                = "app-secreto"
    identity            = azurerm_user_assigned_identity.identity_01.id
    key_vault_secret_id = "${trimsuffix(azurerm_key_vault.kv_01.vault_uri, "/")}/secrets/clavesecreta"
  }
  secret {
    name                = "sql-password"
    identity            = azurerm_user_assigned_identity.identity_01.id
    key_vault_secret_id = "${trimsuffix(azurerm_key_vault.kv_01.vault_uri, "/")}/secrets/sql-password"
  }
  template {
    min_replicas = 3
    container {
      name   = "examplecontainerapp"
      image  = "docker.io/victorandrev/app-tarea-dmcdevops-01:v2.1"
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "APP_MENSAJE"
        value = "Evaluacion final DevOps en Azure"
      }
      env {
        name        = "APP_SECRETO"
        secret_name = "app-secreto"
      }
      env {
        name  = "DB_HOST"
        value = azurerm_mssql_server.sql_01.fully_qualified_domain_name
      }
      env {
        name  = "DB_NAME"
        value = azurerm_mssql_database.sql_01_db.name
      }
      env {
        name  = "DB_USER"
        value = var.sql_01_admin_login
      }
      env {
        name        = "DB_PASSWORD"
        secret_name = "sql-password"
      }
      volume_mounts {
        name = "imagenes"
        path = "/mnt"
      }
    }
    volume {
      name         = "imagenes"
      storage_type = "AzureFile"
      storage_name = azurerm_container_app_environment_storage.storage_01.name
    }
  }
  ingress {
    external_enabled           = true
    target_port                = 8080
    allow_insecure_connections = false

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }

  }
  
}