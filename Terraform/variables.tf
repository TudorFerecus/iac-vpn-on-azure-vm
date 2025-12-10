variable "subscription_id" {
  description = "Subscription ID"
  type        = string
  default     = "-" # default value, change in terraform.tfvars
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "eastus" # default value, change in terraform.tfvars
}

variable "cloudflare_api" {
  description = "Cloudflare API Token"
  type        = string
  default     = "-" # default value, change in terraform.tfvars
}

variable "dns_name" {
  description = "Desired DNS name for the VPN server"
  type        = string
  default     = "vpn"
}

variable "domain_name" {
  description = "Domain name managed in Cloudflare"
  type        = string
  default     = "example.com"
}

variable "zone_id" {
  description = "Cloudflare Zone ID for the domain"
  type        = string
  default     = "-"
}

variable "account_id" {
  description = "Cloudflare Account ID"
  type        = string
  default     = "-"
}

variable "create_dns_record" {
  description = "Whether to create a Cloudflare DNS record for the VPN server"
  type        = bool
  default     = false
}

variable "vm_user" {
  description = "Username for the VM"
  type        = string
  default     = "user"
}

variable "private_key_path" {
  description = "Path to the private SSH key"
  type        = string
  default     = "~/.ssh/vpn_vm_key"
}