variable "location" {
  description = "location for resources"
  type        = string
  default     = "us-east-1"

}

variable "prefix" {
  description = "Prefix for resources"
  type        = string
  default     = "dev"

}
variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH Public Key for the VM"
  type        = string
  sensitive   = true
}
variable "address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}
variable "address_prefixes" {
  description = "Subnet address prefix"
  type        = list(string)
  default     = ["10.0.2.0/24"]

}