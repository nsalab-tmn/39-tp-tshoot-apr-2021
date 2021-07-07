variable "prod_rg" {
  default = "nsalab-prod"
}

variable "prod_loc" {
  default = "East US"
}

resource "null_resource" "archive" {
  provisioner "local-exec" {
    command = "rm -f ${path.module}/ts39-api.zip &&  zip -j ${path.module}/ts39-api.zip ${path.module}/app.py ${path.module}/requirements.txt ${path.module}/config.yml ${path.module}/Dockerfile"
  }
}


resource "azurerm_storage_account" "tshoot_39" {
  name                     = "ts39storacc"
  resource_group_name      = var.prod_rg
  location                 = var.prod_loc
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true
}

resource "azurerm_storage_container" "tshoot_39" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.tshoot_39.name
  container_access_type = "container"
}

resource "azurerm_storage_blob" "tshoot_39" {
  depends_on             = [null_resource.archive]
  name                   = "ts39-api.zip"
  storage_account_name   = azurerm_storage_account.tshoot_39.name
  storage_container_name = azurerm_storage_container.tshoot_39.name
  type                   = "Block"
  source                 = "${path.module}/ts39-api.zip"
}

output "ts39-api-url" {
  value       = azurerm_storage_blob.tshoot_39.url
  description = "url of ts39 api zip"
  
}
