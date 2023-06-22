provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
    name = "terraform-example"
    location = "polandcentral"
}

resource "azurerm_virtual_network" "example" {
    name = "terraform-example-network"
    address_space = ["10.0.0.0/16"]
    location =  azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
    name =  "terraform-example-subnet"
    resource_group_name = azurerm_resource_group.example.name
    virtual_network_name = azurerm_virtual_network.example.name
    address_prefixes = ["10.0.1.0/24"]
 
}

resource "azurerm_network_interface" "example" {
    name = "terraform-example-nic"
    location = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name

    ip_configuration {
      name = "terraform-example-ipconfig"
      subnet_id = azurerm_subnet.example.id
      private_ip_address_allocation = "Dynamic"
    }
}

# resource "local_file" "id_rsa_pub" {
#   filename = "${path.module}\\id_rsa.pub"
#   content  = file("${path.module}\\id_rsa.pub")
# }


resource "azurerm_linux_virtual_machine" "example" {
  name                = "terraform-example-vm"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    name              = "terraform-example-osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  admin_ssh_key {
    username     = "adminuser"
     public_key = file("./id_rsa.pub")
  }
}