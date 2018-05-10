// This script defines the variables that are to be
// used by terraform.
variable "image" {
  // OpenStack image ID
  default = "e27ee185-7bd9-48b0-9ceb-a9aaa589c12e"
}

variable "flavor" {
  // Flavour 
  default = "m1.small"
}

variable "keypair" {
  // Keypair to use for accessing the VMs
}

variable "secgroup" {
  // Security group to use for VMs
}

//variable "ssh_key_file" {
//  default = "./OaaS-eugene"
//}

//variable "ssh_user_name" {
//  default = "ubuntu"
//}

variable "external_gateway" {
  // OpenStack network ID to use for gateway, usually called "public" or "public1"
}

variable "pool" {
  // The name of the floating IP pool (external)
  default = "public1"
}
