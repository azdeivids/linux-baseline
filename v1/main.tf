resource random_pet name {
  length = 1
}

resource azurerm_resource_group main {
  name     = "rg-${var.env_name}-${random_pet.name.id}"
  location = var.location
}

module network {
  
  source = "../modules/network/bastion"

  name                = "${random_pet.name.id}-${var.env_name}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}