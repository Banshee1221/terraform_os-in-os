resource "openstack_compute_instance_v2" "nova" {
  name            = "compute-${format("%02d", count.index+1)}"
  image_id        = "${var.image}"
  flavor_name     = "m1.large"
  key_pair        = "${var.keypair}"
  security_groups = ["${var.secgroup}"]
  count           = 3
  user_data       = "${var.data}"

  network {
    uuid        = "${var.netid_man}"
    fixed_ip_v4 = "10.0.0.10${format("%01d", count.index+1)}"
  }

  network {
    uuid        = "${var.netid_os1}"
    fixed_ip_v4 = "10.1.0.10${format("%01d", count.index+1)}"
  }

  network {
    uuid        = "${var.netid_os2}"
    fixed_ip_v4 = "10.2.0.10${format("%01d", count.index+1)}"
  }
}
