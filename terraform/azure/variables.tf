variable "location" {
  type    = string
  default = "francecentral"
}

variable "environment" {
  # Sert à distinguer les ressources si plusieurs environnements coexistent.
  type    = string
  default = "prod"
}

variable "admin_username" {
  type    = string
  default = "devops"
}

variable "ssh_public_key" {
  # Clé publique injectée dans le compte administrateur de la VM.
  type = string
}

variable "vms" {
  # Liste des VM Azure à créer avec leur taille SKU.
  type = map(object({ size = string }))
  default = {
    "wiki-web" = { size = "Standard_B2s" }
    "wiki-db"  = { size = "Standard_B2s" }
  }
}
