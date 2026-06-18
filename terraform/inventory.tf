resource "local_file" "ansible_inventory" {
  # L'inventaire est régénéré à chaque apply pour éviter les IP codées en dur.
  filename = "${path.module}/../ansible/inventory-${var.environment}.ini"
  content = templatefile("${path.module}/templates/inventory.tftpl", {
    web_ip = proxmox_virtual_environment_vm.vm["wiki-web"].ipv4_addresses[1][0]
    db_ip  = proxmox_virtual_environment_vm.vm["wiki-db"].ipv4_addresses[1][0]
  })
}
