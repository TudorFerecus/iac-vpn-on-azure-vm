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