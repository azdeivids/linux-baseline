data azurerm_key_vault main {
  name                = "kv-tfazde-devops-dev"
  resource_group_name = "rg-dev-tfazde-devops"
}

data azurerm_key_vault_secret ssh_public_key {
  name         = "ssh-public"
  key_vault_id = data.azurerm_key_vault.main.id
}

data azurerm_shared_image_version ubuntu2004 {
  name                = "2023.06.2"
  image_name          = "ubuntu2004-baseline"
  gallery_name        = "galdevtfazdemachineimages"
  resource_group_name = "rg-dev-tfazde-machine-images"
}

module linux_vm {
  
  source = "git::ssh://git@ssh.dev.azure.com/v3/azdeivids/infrastructure/terraform-modules//compute/vm/linux/ubuntu-baseline?ref=v1.0.3"

  name                = "${random_pet.name.id}-${var.env_name}" 
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  subnet_id           = module.network.subnet_id
  vm_size             = "Standard_DS2_v2"
  vm_image_id         = data.azurerm_shared_image_version.ubuntu2004.id
  admin_user          = "deivids"
  ssh_public_key      = data.azurerm_key_vault_secret.ssh_public_key.value
  
}