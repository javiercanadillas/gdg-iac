output "vms" {
  description = "The www VM names."
  value       = ({
    for _,vm in google_compute_instance.my_www_vms
    : vm.name => vm.network_interface[0].network_ip
  })
}
