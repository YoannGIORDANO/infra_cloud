output "vm_ips" {
  # Sortie utilisée pour vérifier rapidement les adresses attribuées par DHCP.
  value = {
    for name, vm in proxmox_virtual_environment_vm.vm :
    name => vm.ipv4_addresses[1][0]
  }
}
