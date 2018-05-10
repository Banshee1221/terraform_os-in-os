resource "openstack_compute_instance_v2" "ceph-mon" {
  name            = "ceph-mon${format("%01d", count.index+1)}"
  image_id        = "${var.image}"
  flavor_name     = "${var.flavor}"
  key_pair        = "${var.keypair}"
  security_groups = ["${var.secgroup}"]
  count           = 3
  user_data       = "${var.data}"

  network {
    uuid        = "${var.netid_man}"
    fixed_ip_v4 = "10.0.0.20${format("%01d", count.index+1)}"
  }

  network {
    uuid        = "${var.netid_os1}"
    fixed_ip_v4 = "10.1.0.20${format("%01d", count.index+1)}"
  }

  network {
    uuid        = "${var.netid_os2}"
    fixed_ip_v4 = "10.2.0.20${format("%01d", count.index+1)}"
  }
}

resource "openstack_compute_instance_v2" "ceph-osd" {
  name            = "ceph-osd${format("%01d", count.index+1)}"
  flavor_name     = "${var.flavor}"
  image_id        = "${var.image}"
  key_pair        = "${var.keypair}"
  security_groups = ["${var.secgroup}"]
  count           = 3
  user_data       = "${var.data}"

  network {
    uuid        = "${var.netid_man}"
    fixed_ip_v4 = "10.0.0.21${format("%01d", count.index+1)}"
  }

  network {
    uuid        = "${var.netid_os1}"
    fixed_ip_v4 = "10.1.0.21${format("%01d", count.index+1)}"
  }

  network {
    uuid        = "${var.netid_os2}"
    fixed_ip_v4 = "10.2.0.21${format("%01d", count.index+1)}"
  }

  block_device {
    uuid                  = "${var.image}"
    source_type           = "image"
    destination_type      = "local"
    boot_index            = 0
    delete_on_termination = true
  }

  block_device {
    source_type           = "blank"
    destination_type      = "volume"
    volume_size           = 50
    boot_index            = 1
    delete_on_termination = true
  }

  block_device {
    source_type           = "blank"
    destination_type      = "volume"
    volume_size           = 50
    boot_index            = 2
    delete_on_termination = true
  }
}
