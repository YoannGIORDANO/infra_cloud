variable "proxmox_endpoint" {
  type = string
}

variable "proxmox_api_token" {
  # Jeton API Proxmox, marqué sensible pour éviter son affichage dans les sorties.
  type      = string
  sensitive = true
}

variable "proxmox_node" {
  type    = string
  default = "pve"
}

variable "datastore_images" {
  type    = string
  default = "local"
}

variable "datastore_disks" {
  type    = string
  default = "local-lvm"
}

variable "network_bridge" {
  type    = string
  default = "vmbr0"
}

variable "ssh_public_key" {
  type = string
}

variable "environment" {
  type        = string
  description = "Nom de l'environnement (dev ou prod)"
}

variable "vms" {
  # Décrit les VM à créer: chaque clé devient un nom logique réutilisé par l'inventaire Ansible.
  type = map(object({
    vmid   = number
    cores  = number
    memory = number
    disk   = number
  }))
}
