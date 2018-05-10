// This file defines what you want returned to stdout after
// the terraform script has been run.

output "controller_addr" {
  value = "${openstack_compute_floatingip_v2.controller.address}"
}

output "manager_addr" {
  value = "${openstack_compute_floatingip_v2.manager.address}"
}
