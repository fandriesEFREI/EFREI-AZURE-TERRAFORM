# variables.tf

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  default     = "East US"
  description = "Azure region"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
}

variable "public_key_path" {
  type        = string
  description = "Path to your SSH public key"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "public_ip_address" {
  type        = string
  description = "Public IP address to assign to the VM"
}

variable "domain_name_label" {
  type        = string
  description = "Domain name label for the public IP"
}

variable "storage_account_name" {
  type        = string
  description = "Storage account name for Blob storage"
}

variable "storage_container_name" {
  type        = string
  description = "Container name for Blob storage"
}

variable "alert_email_address" {
  type        = string
  description = "Email address to receive alerts"
}

variable "key_vault_name" {
  type        = string
  description = "Name of the Azure Key Vault"
}

variable "key_vault_secret_name" {
  type        = string
  description = "Name of the secret to store in Key Vault"
}