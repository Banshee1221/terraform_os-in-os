// This file defines the overall functions to run on the cloud.
// It does bootstrapping and config of networks and brings up
// VMs.

// Terraform syntax <module_type> "<module>" "<variable name>"{}
//

data "template_cloudinit_config" "common" {
  // This template is used to be rendered for inserting  // data into a cloud instance (VM) on launch.

  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"

    content = <<EOF
#cloud-config
disable_root: true
EOF
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${file("${path.root}/files/common.sh")}"
  }
}

data "template_cloudinit_config" "manager" {
  // Same as above, but for the manager node as references   // by the variable "manager"

  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"

    content = <<EOF
#cloud-config
disable_root: true
chpasswd:
  list: |
    ubuntu:wh@t@p@ss
  expire: False
EOF
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${file("${path.root}/files/manager_setup.sh")}"
  }
}

####################################
# Main external management network #
####################################

resource "openstack_networking_network_v2" "net_management" {
  // This brings up a private network for the management  // of OpenStack services.

  name           = "management"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "sub_management" {
  // This creates the subnet to use for the management  // network, created above.

  name            = "management"
  network_id      = "${openstack_networking_network_v2.net_management.id}"
  cidr            = "10.0.0.0/24"
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

resource "openstack_networking_router_v2" "router_management" {
  // This creates a router to use for internet access through  // the private network. It references the variable  // "external_gateway" from the variables file.

  name                = "net_management"
  admin_state_up      = "true"
  external_network_id = "${var.external_gateway}"
}

resource "openstack_networking_router_interface_v2" "management" {
  // This attaches the management network created above  // to the external network (defined in the variables file).

  router_id = "${openstack_networking_router_v2.router_management.id}"
  subnet_id = "${openstack_networking_subnet_v2.sub_management.id}"
}

resource "openstack_compute_floatingip_v2" "manager" {
  // Request a floating IP from the pool.

  pool       = "${var.pool}"
  depends_on = ["openstack_networking_router_interface_v2.management"]
}

###################################
# Main external operating network #
###################################

resource "openstack_networking_network_v2" "net_openstack1" {
  name           = "openstack1"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "sub_openstack1" {
  name        = "openstack1"
  network_id  = "${openstack_networking_network_v2.net_openstack1.id}"
  cidr        = "10.1.0.0/24"
  ip_version  = 4
  enable_dhcp = true
}

resource "openstack_networking_router_v2" "router_openstack1" {
  name                = "net_openstack1"
  admin_state_up      = "true"
  external_network_id = "${var.external_gateway}"
}

resource "openstack_networking_router_interface_v2" "os1" {
  router_id = "${openstack_networking_router_v2.router_openstack1.id}"
  subnet_id = "${openstack_networking_subnet_v2.sub_openstack1.id}"
}

resource "openstack_compute_floatingip_v2" "controller" {
  pool       = "${var.pool}"
  depends_on = ["openstack_networking_router_interface_v2.os1"]
}

####################
# Internal network #
####################

resource "openstack_networking_network_v2" "net_openstack2" {
  name           = "openstack2"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "sub_openstack2" {
  name        = "openstack2"
  network_id  = "${openstack_networking_network_v2.net_openstack2.id}"
  cidr        = "10.2.0.0/24"
  ip_version  = 4
  enable_dhcp = true
}

#######################
# OS controller nodes #
#######################

module "controller" {
  // Modules are used to import other terraform scripts.  // You must define the source and can use a relative   // path. The variables required by these modules must  // also be defined.

  source   = "./modules/controller"
  image    = "${var.image}"
  flavor   = "${var.flavor}"
  keypair  = "${var.keypair}"
  secgroup = "${var.secgroup}"

  // You can see here that we are referencing the 
  // openstack_networking_network_v2.net_management.id
  // variable that is created after the item is created
  // above in this script. You use 
  // "${<module>.<variable name>.<property}".

  netid_man       = "${openstack_networking_network_v2.net_management.id}"
  netid_os1       = "${openstack_networking_network_v2.net_openstack1.id}"
  netid_os2       = "${openstack_networking_network_v2.net_openstack2.id}"
  floatingip_addr = "${openstack_compute_floatingip_v2.controller.address}"
  data            = "${data.template_cloudinit_config.common.rendered}"
}

#################
# OS Nova nodes #
#################

module "compute" {
  source    = "./modules/compute"
  image     = "${var.image}"
  flavor    = "${var.flavor}"
  keypair   = "${var.keypair}"
  secgroup  = "${var.secgroup}"
  netid_man = "${openstack_networking_network_v2.net_management.id}"
  netid_os1 = "${openstack_networking_network_v2.net_openstack1.id}"
  netid_os2 = "${openstack_networking_network_v2.net_openstack2.id}"
  data      = "${data.template_cloudinit_config.common.rendered}"
}

##############
# Ceph nodes #
##############

module "storage" {
  source    = "./modules/storage"
  image     = "${var.image}"
  flavor    = "${var.flavor}"
  keypair   = "${var.keypair}"
  secgroup  = "${var.secgroup}"
  netid_man = "${openstack_networking_network_v2.net_management.id}"
  netid_os1 = "${openstack_networking_network_v2.net_openstack1.id}"
  netid_os2 = "${openstack_networking_network_v2.net_openstack2.id}"
  data      = "${data.template_cloudinit_config.common.rendered}"
}

################
# Manager node #
################

module "manager" {
  source          = "./modules/manager"
  image           = "${var.image}"
  flavor          = "${var.flavor}"
  keypair         = "${var.keypair}"
  secgroup        = "${var.secgroup}"
  netid           = "${openstack_networking_network_v2.net_management.id}"
  floatingip_addr = "${openstack_compute_floatingip_v2.manager.address}"
  data            = "${data.template_cloudinit_config.manager.rendered}"
}
