resource "azurerm_linux_virtual_machine" "main" {
  name                = "linuxvm1"
  computer_name       = "linuxvm1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_DS1_v2"
  admin_username      = "devops"
  admin_password      = random_password.pw.result

  network_interface_ids = [azurerm_network_interface.linux.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "linuxvm1-disk1"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  patch_mode                      = "AutomaticByPlatform"
  disable_password_authentication = false
  tags                            = azurerm_resource_group.main.tags
}

resource "azurerm_windows_virtual_machine" "main" {
  name                = "windowsvm1"
  computer_name       = "windowsvm1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_DS1_v2"
  admin_username      = "localadmin"
  admin_password      = random_password.pw.result
  identity { type = "SystemAssigned" }

  network_interface_ids = [azurerm_network_interface.windows.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "windowsvm1-disk1"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition-core"
    version   = "latest"
  }

  patch_mode          = "AutomaticByPlatform"
  hotpatching_enabled = true
  tags                = azurerm_resource_group.main.tags
}

data "azurerm_virtual_machine" "main" {
  for_each = toset( ["linuxvm1", "windowsvm1"] )

  name                = "${each.key}"
  resource_group_name = azurerm_resource_group.main.name

  depends_on = [
    azurerm_windows_virtual_machine.main,
    azurerm_linux_virtual_machine.main
  ]
}

resource "azurerm_virtual_machine_extension" "ama-linux" {
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.main.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.22"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "ama-windows" {
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.main.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.9"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
}
