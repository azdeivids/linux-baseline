resource azurerm_virtual_network main {
  name                = "vnet-${var.name}"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Azure Bastion subnet name is fixed and cannot be changed.
resource azurerm_subnet bastion {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource azurerm_subnet default {
  name                 = "snet-${var.name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource azurerm_network_security_group default {
  name                = "nsg-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource azurerm_subnet_network_security_group_association default_rule1 {
  subnet_id                 = azurerm_subnet.default.id
  network_security_group_id = azurerm_network_security_group.default.id
}