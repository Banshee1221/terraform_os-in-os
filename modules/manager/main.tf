resource "openstack_compute_instance_v2" "manager" {
  name            = "manager-01"
  image_id        = "${var.image}"
  flavor_name     = "${var.flavor}"
  key_pair        = "${var.keypair}"
  security_groups = ["${var.secgroup}"]
  user_data       = "${var.data}"

  network {
    uuid        = "${var.netid}"
    fixed_ip_v4 = "10.0.0.5"
  }
}

resource "openstack_compute_floatingip_associate_v2" "controller_fip" {
  floating_ip = "${var.floatingip_addr}"
  instance_id = "${openstack_compute_instance_v2.manager.id}"
}
