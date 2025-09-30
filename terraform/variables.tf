variable "yc_token" {
  description = "Yandex Cloud token"
  type        = string
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "yc_folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for VM(instance) access"
  type        = string
}