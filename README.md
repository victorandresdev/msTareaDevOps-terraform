# Infraestructura de msTareaDevOps

Infraestructura como código para desplegar el microservicio Spring Boot de la evaluación final de DevOps. Terraform administra los recursos de Azure y la versión de la imagen Docker que ejecuta la Container App.

- [Repositorio Java](https://github.com/victorandresdev/msTareaDevOps)
- [Imagen en Docker Hub](https://hub.docker.com/r/victorandrev/app-tarea-dmcdevops-01/tags)

## Arquitectura del laboratorio

| Componente | Configuración del despliegue |
|---|---|
| Resource Group | `rg-dmctareafinal-dev-eastus2-002` |
| Container Apps Environment | `cae-dmctareafinal-dev-eastus2-002`, East US 2, perfil Consumption |
| Container App | `ca-dmctareafinal-dev-eastus2-003`, entrada pública HTTPS hacia el puerto 8080 |
| Key Vault | `kv-dmctareafinal-003`, con acceso de lectura mediante una identidad administrada |
| Azure Files | Cuenta `stdmctareafinal003`, recurso compartido `imagenes`, montado en `/mnt` en modo solo lectura |
| Azure SQL | Servidor `sql-clasefinal-dev-centralus-001` y base `sqldb-clasefinal-dev-centralus-001`, SKU Basic en Central US |

Azure SQL se aprovisionó en Central US después de que la suscripción devolviera `ProvisioningDisabled` en East US 2. El firewall de SQL incluye la regla `AllowAzureServices` usada en el laboratorio. La aplicación requiere autenticación SQL para consultar la base.

## Archivos

| Archivo | Responsabilidad |
|---|---|
| `provider.tf` | Configura AzureRM 4.4.0 y la suscripción de destino. |
| `variables.tf` | Declara los parámetros de infraestructura. |
| `resource_group.tf` | Crea el grupo de recursos. |
| `container_app_env.tf` | Crea el Environment y la Container App. Define imagen, ingress, variables de entorno y montaje. |
| `identity_user_assigned.tf` | Crea la identidad administrada y las asignaciones de roles en Key Vault. |
| `keyvault.tf` | Crea el Key Vault con control de acceso RBAC. |
| `storage_account.tf` | Crea la cuenta de almacenamiento. |
| `azure_files.tf` | Crea el recurso compartido y lo registra en el Environment. |
| `sql.tf` | Crea el servidor Azure SQL, la base de datos y la regla de firewall. |

## Preparar el despliegue

Necesitas Terraform, Azure CLI, una suscripción habilitada para los servicios utilizados y permisos para crear recursos y asignar roles. La etiqueta declarada en la Container App debe estar publicada en Docker Hub.

Desde la carpeta que contiene los archivos `.tf`:

~~~powershell
az login
az account set --subscription "ID-DE-TU-SUSCRIPCION"
az account show --query "{Nombre:name,ID:id}" -o table
terraform init
terraform validate
~~~

Verifica que el proveedor use esa misma suscripción. Completa los valores que declara `variables.tf` en un `terraform.tfvars` local. Para replicar el laboratorio en otra suscripción, usa un estado separado y elige nombres disponibles globalmente para Key Vault, Storage Account y el servidor SQL.

Para publicar este repositorio, incluye los archivos `.tf` y `.terraform.lock.hcl`. Usa un ejemplo sin credenciales si quieres compartir los valores de configuración. Excluye la configuración local, el estado y los planes guardados del repositorio:

~~~gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
*.tfvars
*.tfvars.json
~~~

## Desplegar desde cero

1. En `container_app_env.tf`, comenta temporalmente los bloques `secret` de `app-secreto` y `sql-password`, y los bloques `env` que los referencian (`APP_SECRETO` y `DB_PASSWORD`). Conserva la identidad administrada. Así puedes crear el vault y asignar los permisos antes de que la app intente resolver las referencias.
2. Ejecuta `terraform plan`, revisa los recursos y ejecuta `terraform apply`.
3. En el Key Vault creado, agrega `clavesecreta` con un valor ficticio y `sqlpwd` con la contraseña configurada para Azure SQL. La Container App referencia `sqlpwd` mediante el alias interno `sql-password`.
4. Sube `bosque.jpg` a la raíz del recurso compartido `imagenes`. El contenedor lo leerá como `/mnt/bosque.jpg`.
5. En el editor de consultas de la base SQL, crea la tabla y su registro ficticio como se muestra abajo.
6. Reactiva los bloques de secretos y sus variables de entorno. Revisa el nuevo plan y vuelve a aplicar. En un entorno ya desplegado, revisa los cambios desde la carpeta y el estado con los que se creó.

~~~sql
CREATE TABLE dbo.usuarios (
    id        INT           NOT NULL PRIMARY KEY,
    nombres   NVARCHAR(100) NOT NULL,
    apellidos NVARCHAR(100) NOT NULL,
    dni       CHAR(8)       NOT NULL
);

INSERT INTO dbo.usuarios (id, nombres, apellidos, dni)
VALUES (1, N'Ana', N'Pérez Gómez', '65488953');
~~~

## Verificar la revisión

Copia la URL HTTPS de la Container App cuando la revisión esté activa y comprueba estas rutas:

| Ruta | Resultado esperado |
|---|---|
| `/hello` | Saludo del microservicio. |
| `/variable` | Valor configurado en `APP_MENSAJE`. |
| `/secreto` | Valor ficticio de `clavesecreta`. |
| `/imagen` | JPEG subido a Azure Files. |
| `/consulta` | JSON con el registro `id = 1` leído desde Azure SQL. |

Para la entrega, guarda la salida de `terraform apply`, la etiqueta de Docker Hub y capturas de las rutas con su URL visible. El pipeline de GitHub Actions se documentó como una propuesta. En el laboratorio, la publicación de la imagen y el despliegue con Terraform se ejecutaron manualmente.

## Eliminar la infraestructura

Una vez guardadas las evidencias, usa la misma carpeta, suscripción y estado del despliegue. Revisa los recursos antes de confirmar la eliminación.

~~~powershell
terraform plan -destroy
terraform destroy
~~~
