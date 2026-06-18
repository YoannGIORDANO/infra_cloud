variable "proxmox_endpoint" {
  type = string
}

variable "proxmox_api_token" {
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

variable "vms" {
  type = map(object({
    vmid   = number
    cores  = number
    memory = number
    disk   = number
  }))
  default = {
    "wiki-web" = { vmid = 201, cores = 2, memory = 4096, disk = 30 }
    "wiki-db"  = { vmid = 202, cores = 2, memory = 4096, disk = 30 }
  }
}
