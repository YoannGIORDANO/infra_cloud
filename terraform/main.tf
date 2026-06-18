resource "proxmox_virtual_environment_download_file" "ubuntu_cloud" {
  content_type = "iso"
  datastore_id = var.datastore_images
  node_name    = var.proxmox_node
  file_name    = "jammy-server-cloudimg-amd64.img"
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

resource "proxmox_virtual_environment_file" "cloud_init" {
  for_each     = var.vms
  content_type = "snippets"
  datastore_id = var.datastore_images
  node_name    = var.proxmox_node
  source_raw {
    file_name = "cloud-init-${each.key}.yaml"
    data = templatefile("${path.module}/cloud-init/user-data.yaml.tftpl", {
      hostname       = each.key
      ssh_public_key = var.ssh_public_key
    })
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  for_each  = var.vms
  name      = each.key
  vm_id     = each.value.vmid
  node_name = var.proxmox_node

  agent { enabled = true }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory { dedicated = each.value.memory }

  disk {
    datastore_id = var.datastore_disks
    file_id  = proxmox_virtual_environment_download_file.ubuntu_cloud.id
    interface    = "scsi0"
    size         = each.value.disk
  }

  initialization {
    datastore_id = var.datastore_disks
    ip_config {
      ipv4 { address = "dhcp" }
    }
    user_data_file_id = proxmox_virtual_environment_file.cloud_init[each.key].id
  }

  network_device { bridge = var.network_bridge }
}
