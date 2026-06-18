output "vm_ips" {
  value = {
    for name, vm in proxmox_virtual_environment_vm.vm :
    name => vm.ipv4_addresses[1][0]
  }
}
