data azurerm_key_vault main {
  name                = "kv-tfazde-devops-dev"
  resource_group_name = "rg-dev-tfazde-devops"
}

data azurerm_key_vault_secret ssh_public_key {
  name         = "ssh-public"
  key_vault_id = data.azurerm_key_vault.main.id
}

data azurerm_shared_image_version ubuntu2004 {
  name                = "2023.06.4"
  image_name          = "ubuntu2004-baseline"
  gallery_name        = "galdevtfazdemachineimages"
  resource_group_name = "rg-dev-tfazde-machine-images"
}

data azurerm_storage_account boot_diagnostics {
  name                = var.boot_diagnostics_storage.storage_account_name
  resource_group_name = var.boot_diagnostics_storage.resource_group_name
}

module linux_vm {
  
  source = "git::ssh://git@ssh.dev.azure.com/v3/azdeivids/infrastructure/terraform-modules//compute/vm/linux/ubuntu-baseline?ref=v1.0.9"

  name                                 = "${random_pet.name.id}-${var.env_name}" 
  resource_group_name                  = azurerm_resource_group.main.name
  location                             = azurerm_resource_group.main.location
  subnet_id                            = module.network.subnet_id
  vm_size                              = "Standard_DS2_v2"
  vm_image_id                          = data.azurerm_shared_image_version.ubuntu2004.id
  admin_user                           = "deivids"
  ssh_public_key                       = data.azurerm_key_vault_secret.ssh_public_key.value
  boot_diagnostics_storage_account_uri = data.azurerm_storage_account.boot_diagnostics.primary_blob_endpoint
  
}

module "linux_monitor" {
  
  source = "git::ssh://git@ssh.dev.azure.com/v3/azdeivids/infrastructure/terraform-modules//compute/vm-extensions/linux-azure-monitor?ref=v1.0.9"

  name               = "AzureMonitorLinuxAgent"
  virtual_machine_id = module.linux_vm.id

}

module linux_diag {

  source = "git::ssh://git@ssh.dev.azure.com/v3/azdeivids/infrastructure/terraform-modules//compute/vm-extensions/linux-diagnostics?ref=v1.0.9"

  name                      = "vme-diag-${module.linux_vm.hostname}"
  virtual_machine_id        = module.linux_vm.id
  storage_account_name      = data.azurerm_storage_account.boot_diagnostics.name
  storage_account_sas_token = data.azurerm_storage_account_sas.vm_diagnostics.sas

}

resource time_offset sas_expiry {
  offset_years = 1
}

resource time_offset sas_start {
  offset_days = -1
}

data azurerm_storage_account_sas vm_diagnostics {

  connection_string = data.azurerm_storage_account.boot_diagnostics.primary_connection_string
  https_only        = true
  signed_version    = "2017-07-29"

  resource_types {
    service   = false
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = true
    file  = false
  }

  start  = time_offset.sas_start.rfc3339
  expiry = time_offset.sas_expiry.rfc3339

  permissions {
    add                        = true
    create                     = true
    delete                     = false
    filter                     = false
    list                       = true
    process                    = false
    read                       = false
    tag                        = false
    update                     = true
    write                      = true
  }
}