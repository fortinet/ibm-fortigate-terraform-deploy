data "ibm_is_vpc" "vpc1" {
  name = var.vpc
}
data "ibm_is_subnet" "subnet1" {
  identifier = var.subnet1
}

data "ibm_is_subnet" "subnet2" {
  identifier = var.subnet2
}

data "ibm_is_security_group" "fgt_security_group" {
  name = var.security_group
}

resource "ibm_is_virtual_network_interface" "vni-active" {
  depends_on = [ ibm_is_instance.fgt1 ]
  name                      = "${var.CLUSTER_NAME}-fgt-interface1-${random_string.random_suffix.result}"
  allow_ip_spoofing         = false
  auto_delete               = false
  enable_infrastructure_nat = true
  security_groups           = [data.ibm_is_security_group.fgt_security_group.id]
  subnet                    = data.ibm_is_subnet.subnet1.id

}

resource "ibm_is_virtual_network_interface" "vni-passive" {
  depends_on = [ ibm_is_instance.fgt1 ]
  name                      = "${var.CLUSTER_NAME}-fgt-interface2-${random_string.random_suffix.result}"
  allow_ip_spoofing         = false
  auto_delete               = false
  enable_infrastructure_nat = true
  subnet                    = data.ibm_is_subnet.subnet2.id

}