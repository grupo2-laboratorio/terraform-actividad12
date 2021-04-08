provider "azurerm" {
    tenant_id = "b61edac7-725c-4319-8919-13d2d6bd013e"
    subscription_id = "513140d0-b180-4730-9451-6bbbdecdbc57"
    client_id = "b23718c8-4357-4eb0-836d-6d469797b67f"
    client_secret = "fz0LfH4y88R_z4UkRU2D.fLe~~-38a6E6R"
    features {}
}


resource "azurerm_resource_group" "grupo2" {
  name     = "grupo2"
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

resource "azurerm_kubernetes_cluster" "grupo2" {
  name                = "grupo2-aks"
  location            = azurerm_resource_group.grupo2.location
  resource_group_name = azurerm_resource_group.grupo2.name
  dns_prefix          = "grupo2-dns-prefix"
  kubernetes_version  = "1.19.6"

  default_node_pool {
    name           = "grupo2pool"
    node_count     = 2
    vm_size        = "Standard_B2s"
    max_count = 4
    min_count = 1
    enable_auto_scaling = true
    max_pods = 3
    vnet_subnet_id = azurerm_subnet.grupo2.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "Standard"
  }
}


data "azurerm_subscription" "primary" {}
resource random_uuid grupo2 {}

resource "azurerm_role_definition" "grupo2" {
  name               = "grupo2"
  role_definition_id = random_uuid.grupo2.result
  scope              = resource.azurerm_kubernetes_cluster.grupo2.id
  description        = "This is a custom role created via Terraform"

  permissions {
    actions     = ["*"]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id,
  ]
}

data "azurerm_public_ip" "grupo2" {
  name                = reverse(split("/", tolist(azurerm_kubernetes_cluster.grupo2.network_profile.0.load_balancer_profile.0.effective_outbound_ips)[0]))[0]
  resource_group_name = azurerm_kubernetes_cluster.grupo2.node_resource_group
}