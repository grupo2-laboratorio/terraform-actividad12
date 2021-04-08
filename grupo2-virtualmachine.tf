provider "azurerm" {
    tenant_id = "b61edac7-725c-4319-8919-13d2d6bd013e"
    subscription_id = "513140d0-b180-4730-9451-6bbbdecdbc57"
    client_id = "b23718c8-4357-4eb0-836d-6d469797b67f"
    client_secret = "fz0LfH4y88R_z4UkRU2D.fLe~~-38a6E6R"
    features {}
}

resource "azurerm_resource_group" "grupo2" {
  name     = "grupo2-vmlmv"
  location = "eastus2"
}

resource "azurerm_virtual_network" "grupo2" {
  name                = "grupo2-vnet"
  location            = "eastus2"
  resource_group_name = azurerm_resource_group.grupo2.name
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "grupo2" {
  name                 = "grupo2-subnet"
  resource_group_name  = azurerm_resource_group.grupo2.name
  address_prefixes     = ["192.168.1.0/24"]
  virtual_network_name = azurerm_virtual_network.grupo2.name
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_network_interface" "grupo2" {
  name                = "grupo2-nic"
  location            = azurerm_resource_group.grupo2.location
  resource_group_name = azurerm_resource_group.grupo2.name

  ip_configuration {
    name                          = "ipconfiguration"
    subnet_id                     = azurerm_subnet.grupo2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "grupo2" {
  name                  = "grupo2-vm"
  location              = azurerm_resource_group.grupo2.location
  resource_group_name   = azurerm_resource_group.grupo2.name
  network_interface_ids = [azurerm_network_interface.grupo2.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "grupo2Disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "development"
  }
}