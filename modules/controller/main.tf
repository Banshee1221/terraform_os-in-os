resource "openstack_compute_instance_v2" "controller" {
  name            = "controller-${format("%02d", count.index+1)}"
  image_id        = "${var.image}"
  flavor_name     = "${var.flavor}"
  key_pair        = "${var.keypair}"
  security_groups = ["${var.secgroup}"]
  count           = 3
  user_data       = "${var.data}"

  network {
    uuid        = "${var.netid_man}"
    fixed_ip_v4 = "10.0.0.1${format("%01d", count.index+1)}"
  }

  network {
    uuid        = "${var.netid_os1}"
    fixed_ip_v4 = "10.1.0.1${format("%01d", count.index+1)}"
  }

  network {
    uuid        = "${var.netid_os2}"
    fixed_ip_v4 = "10.2.0.1${format("%01d", count.index+1)}"
  }
}

resource "openstack_compute_floatingip_associate_v2" "controller_fip" {
  floating_ip = "${var.floatingip_addr}"
  instance_id = "${openstack_compute_instance_v2.controller.0.id}"
}
