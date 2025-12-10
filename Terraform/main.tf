terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

provider "azurerm" {
  features {

    # Not really needed, but avoids some issues with resource group deletion
    # especially useful during testing
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  # not safe, but needed for Student Subscriptions (i think)
  # first try without it, if you get provider registration errors (or nothng happens for a long time), add it
  skip_provider_registration = true

  # Change to your Subscription ID
  subscription_id = var.subscription_id
}

provider "cloudflare" {
  api_token = var.cloudflare_api
}

resource "azurerm_resource_group" "dev" {
  name = "dev-vpn-rg"

  # Change the location as needed 
  # (I used it because the Student Subscription has few available locations and this was the ony one working for me)
  # I would recommend using a location closer to your physical location
  location = var.location
}

resource "azurerm_virtual_network" "dev-vpn-vnet" {
  name                = "dev-vpn-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name
}

resource "azurerm_subnet" "dev-vpn-subnet" {
  name                 = "dev-vpn-subnet"
  resource_group_name  = azurerm_resource_group.dev.name
  virtual_network_name = azurerm_virtual_network.dev-vpn-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a Public IP for the VM
# VERY IMPORTANT: Make sure to use "Static" allocation
resource "azurerm_public_ip" "vpn_ip" {
  name                = "vpn-public-ip"
  resource_group_name = azurerm_resource_group.dev.name
  location            = azurerm_resource_group.dev.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "dev-nic" {
  name                = "dev-nic"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name

  # Network IP Configuration
  # Make sure to link the subnet and public IP created before
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dev-vpn-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vpn_ip.id
  }
}

resource "azurerm_network_security_group" "dev-nsg" {
  name                = "dev-vpn-nsg"
  location            = azurerm_resource_group.dev.location
  resource_group_name = azurerm_resource_group.dev.name

  # 22 - SSH Port
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # 51820 - Wireguard VPN Port
  security_rule {
    name                       = "WireGuard"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "51820"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # docker port
  security_rule {
    name                       = "DockerWebsite"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "51821"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # allow http traffic
  dynamic "security_rule" {
    for_each = var.create_dns_record ? [1] : []
    content {
      name                       = "HTTP"
      priority                   = 1004
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  # allow https traffic
  dynamic "security_rule" {
    for_each = var.create_dns_record ? [1] : []
    content {
      name                       = "HTTPS"
      priority                   = 1005
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_network_interface_security_group_association" "dev-nsg-assoc" {
  network_interface_id      = azurerm_network_interface.dev-nic.id
  network_security_group_id = azurerm_network_security_group.dev-nsg.id
}

resource "azurerm_linux_virtual_machine" "dev-vm" {
  name                = "dev-vm"
  resource_group_name = azurerm_resource_group.dev.name
  location            = azurerm_resource_group.dev.location

  # Change the size as needed, this worked the best for me in Student Subscription
  size           = "Standard_B2ats_v2"
  admin_username = var.vm_user
  network_interface_ids = [
    azurerm_network_interface.dev-nic.id,
  ]

  # The key should be already generated - this just copies it to ~/.ssh on the VM
  # You can generate it with: ssh-keygen -t rsa
  # Make sure to not have a passphrase, or use ssh-agent to manage it
  admin_ssh_key {
    username   = var.vm_user
    public_key = file("${var.private_key_path}.pub")
  }

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

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../Ansible/inventory.ini"
  content = templatefile("${path.module}/inventory.tftpl", {
    vm_ip           = azurerm_public_ip.vpn_ip.ip_address
    vm_user         = var.vm_user
    private_key_vpn = var.private_key_path
    record_link     = var.create_dns_record ? "${var.dns_name}.${var.domain_name}" : azurerm_public_ip.vpn_ip.ip_address
  })
}

# Cloudflare DNS Record

resource "cloudflare_dns_record" "vpn_dns" {
  count = var.create_dns_record ? 1 : 0

  zone_id = var.zone_id
  name    = var.dns_name
  content = azurerm_public_ip.vpn_ip.ip_address
  type    = "A"
  proxied = false
  ttl     = 60
}