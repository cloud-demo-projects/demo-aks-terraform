# deploy virtual network
resource "azurerm_virtual_network" "virtual_network" {
  resource_group_name               = var.resource_group_name
  address_space                     = var.address_space
  name                              = var.name
  location                          = var.location
}
