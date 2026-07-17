data "ibm_is_vpc" "vpc1" {
  name = var.vpc
}
data "ibm_is_subnet" "subnet1" {
  identifier = var.subnet1
}

data "ibm_is_subnet" "subnet2" {
  identifier = var.subnet2
}

data "ibm_is_security_group" "fgt_security_group_port1" {
  count = var.security_group_port1 != "" ? 1 : 0
  name = var.security_group_port1
}

data "ibm_is_security_group" "fgt_security_group_port2" {
  count = var.security_group_port2 != "" ? 1 : 0
  name = var.security_group_port2
}

resource "ibm_is_security_group" "fgt_security_group_port1" {
  count = var.security_group_port1 == "" ? 1 : 0
  name  = "${var.cluster_name}-fgt-sg-port1-${random_string.random_suffix.result}"
  vpc   = data.ibm_is_vpc.vpc1.id
}

resource "ibm_is_security_group" "fgt_security_group_port2" {
  count = var.security_group_port2 == "" ? 1 : 0
  name  = "${var.cluster_name}-fgt-sg-port2-${random_string.random_suffix.result}"
  vpc   = data.ibm_is_vpc.vpc1.id
}

locals {
  security_group_port1_id = var.security_group_port1 != "" ? data.ibm_is_security_group.fgt_security_group_port1[0].id : ibm_is_security_group.fgt_security_group_port1[0].id
  security_group_port2_id = var.security_group_port2 != "" ? data.ibm_is_security_group.fgt_security_group_port2[0].id : ibm_is_security_group.fgt_security_group_port2[0].id
  security_group_port1_name = var.security_group_port1 != "" ? data.ibm_is_security_group.fgt_security_group_port1[0].name : ibm_is_security_group.fgt_security_group_port1[0].name
  security_group_port2_name = var.security_group_port2 != "" ? data.ibm_is_security_group.fgt_security_group_port2[0].name : ibm_is_security_group.fgt_security_group_port2[0].name

}

resource "ibm_is_virtual_network_interface" "vni-port1" {
  name                      = "${var.cluster_name}-fgt-interface1-${random_string.random_suffix.result}"
  allow_ip_spoofing         = false
  auto_delete               = false
  enable_infrastructure_nat = true
  security_groups           = [local.security_group_port1_id]
  subnet                    = data.ibm_is_subnet.subnet1.id

}

resource "ibm_is_virtual_network_interface" "vni-port2" {
  name                      = "${var.cluster_name}-fgt-interface2-${random_string.random_suffix.result}"
  allow_ip_spoofing         = false
  auto_delete               = false
  enable_infrastructure_nat = true
  security_groups           = [local.security_group_port2_id]
  subnet                    = data.ibm_is_subnet.subnet2.id

}