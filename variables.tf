variable "location" {
  description = "La ubicación donde se creará el componente"
  type        = string
}

variable "tags" {
  description = "Etiquetas opcionales para aplicar al componente"
  type        = map(string)
  default = {
    Environment = ""
  }
}

variable "rg_01_name" {
  description = "El nombre del grupo de recursos"
  type        = string
}

#Cluster
variable "cae_01_name" {
  description = "El nombre del Container Apps Environment"
  type        = string
}

variable "cae_01_workload_profile" {
  description = "El perfil de carga del Container Apps Environment"
  type        = string
}

variable "aca_01_name" {
  description = "Nombre de la Container App"
  type        = string
}

# KeyVault e Identity
variable "kv_01_name" {
  description = "Nombre del Key Vault"
  type        = string
}

variable "identity_01_name" {
  description = "Nombre de la identidad administrada"
  type        = string
}

# Storage
variable "st_01_name" {
  description = "Nombre de la cuenta de almacenamiento"
  type        = string
}

variable "share_01_name" {
  description = "Nombre del recurso compartido de Azure Files"
  type        = string
}

# Bd

variable "sql_01_location" {
  description = "La ubicación del SQL Server 01"
  type        = string
}

variable "sql_01_server_name" {
  description = "Nombre del servidor lógico de Azure SQL"
  type        = string
}

variable "sql_01_db_name" {
  description = "Nombre de la base de datos"
  type        = string
}

variable "sql_01_admin_login" {
  description = "Usuario administrador de Azure SQL para el laboratorio"
  type        = string
}

variable "sql_01_admin_password" {
  description = "Contraseña del administrador de Azure SQL"
  type        = string
  sensitive   = true
}