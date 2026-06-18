resource "azurerm_resource_group" "rg" {
  # Groupe de ressources racine pour isoler tout le déploiement Azure du projet.
  name     = "rg-wiki-${var.environment}"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  # Réseau privé principal qui contiendra les VM.
  name                = "vnet-wiki-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  # Sous-réseau dédié aux VM de Wiki.js.
  name                 = "subnet-wiki"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  # Règles d'entrée minimales: SSH pour l'administration et HTTP pour l'accès public.
  name                = "nsg-wiki-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "pip" {
  # Une IP publique par VM permet de les exposer ou de les administrer individuellement.
  for_each            = var.vms
  name                = "pip-${var.environment}-${each.key}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic" {
  # Chaque VM reçoit sa propre interface réseau liée au sous-réseau privé.
  for_each            = var.vms
  name                = "nic-${var.environment}-${each.key}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[each.key].id
  }
}

resource "azurerm_network_interface_security_group_association" "assoc" {
  # Le NSG est attaché à chaque interface pour appliquer les règles d'accès.
  for_each                  = var.vms
  network_interface_id      = azurerm_network_interface.nic[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  # Les VM utilisent Ubuntu Jammy et reçoivent le même cloud-init que sur Proxmox.
  for_each              = var.vms
  name                  = "${var.environment}-${each.key}"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = each.value.size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  custom_data = base64encode(templatefile("${path.module}/../cloud-init/user-data.yaml.tftpl", {
    hostname       = "${var.environment}-${each.key}"
    ssh_public_key = var.ssh_public_key
  }))

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

output "vm_public_ips" {
  # Permet de récupérer rapidement les adresses publiques après un apply.
  value = { for k, p in azurerm_public_ip.pip : k => p.ip_address }
}
