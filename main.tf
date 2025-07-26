resource "azurerm_resource_group" "test_net" {
  name     = "${var.prefix}-resources"
  location = var.location
}

resource "azurerm_virtual_network" "demo_network" {
  name                = "${var.prefix}-network"
  address_space       = var.address_space
  location            = azurerm_resource_group.test_net.location
  resource_group_name = azurerm_resource_group.test_net.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test_net.name
  virtual_network_name = azurerm_virtual_network.demo_network.name
  address_prefixes     = var.address_prefixes
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.test_net.location
  resource_group_name = azurerm_resource_group.test_net.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "vmtest" {
  name                          = "${var.prefix}-vm"
  location                      = azurerm_resource_group.test_net.location
  resource_group_name           = azurerm_resource_group.test_net.name
  network_interface_ids         = [azurerm_network_interface.main.id]
  vm_size                       = "Standard_B2as_v2"
  delete_os_disk_on_termination = true

  storage_os_disk {
    name              = "${var.prefix}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.prefix}-vm"
    admin_username = var.admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = var.ssh_public_key
    }
  }
}
