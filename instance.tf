data "ibm_is_ssh_key" "ssh_key" {
  name = var.ssh_public_key
}

resource "ibm_is_volume" "logDisk" {
  // Name must be lower case
  name    = "${var.cluster_name}-logdisk-${random_string.random_suffix.result}"
  profile = "10iops-tier"
  zone    = var.zone1
}

resource "ibm_is_floating_ip" "publicip" {
  name   = "${var.cluster_name}-publicip-${random_string.random_suffix.result}"
  target = ibm_is_instance.fgt1.primary_network_interface[0].id
}

resource "ibm_is_instance" "fgt1" {
  name    = "${var.cluster_name}-fortigate-${random_string.random_suffix.result}"
  image   = ibm_is_image.vnf_custom_image.id
  profile = var.profile

  primary_network_attachment {
    name = "${var.CLUSTER_NAME}-fgt-port1-${random_string.random_suffix.result}"
    virtual_network_interface {
      id = ibm_is_virtual_network_interface.vni-passive["interface1"].id
    }
  }
  network_attachments {
    name = "${var.CLUSTER_NAME}-fgt-port2-${random_string.random_suffix.result}"
    virtual_network_interface {
      id = ibm_is_virtual_network_interface.vni-passive["interface2"].id
    }
  }

  volumes = [ibm_is_volume.logDisk.id]

  vpc       = data.ibm_is_vpc.vpc1.id
  zone      = var.zone1
  user_data = data.template_file.userdata.rendered
  keys      = [data.ibm_is_ssh_key.ssh_key.id]
}
// Use for bootstrapping cloud-init
data "template_file" "userdata" {
  template = file(var.user_data)
}