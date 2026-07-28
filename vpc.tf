data "ibm_is_vpc" "vpc1" {
  name = var.vpc
}
data "ibm_is_subnet" "subnet1" {
  identifier = var.subnet1
}

data "ibm_is_subnet" "subnet2" {
  identifier = var.subnet2
}

resource "ibm_is_security_group" "fgt_security_group_port1" {
  name  = "${var.cluster_name}-fgt-sg-port1-${random_string.random_suffix.result}"
  vpc   = data.ibm_is_vpc.vpc1.id
}

resource "ibm_is_security_group_rule" "fgt_port1_inbound_self" {
  group     = ibm_is_security_group.fgt_security_group_port1.id
  direction = "inbound"
  remote    = ibm_is_security_group.fgt_security_group_port1.id
  name      = "allow-inbound-from-same-sg"
}

resource "ibm_is_security_group_rule" "fgt_port1_inbound_https" {
  group     = ibm_is_security_group.fgt_security_group_port1.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  protocol  = "tcp"
  port_min  = 443
  port_max  = 443
  name      = "allow-inbound-https-tcp-443"
}

resource "ibm_is_security_group_rule" "fgt_port1_outbound_dns" {
  group     = ibm_is_security_group.fgt_security_group_port1.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  protocol  = "udp"
  port_min  = 53
  port_max  = 53
  name      = "allow-outbound-fortiguard-dns-udp-53"
}

resource "ibm_is_security_group_rule" "fgt_port1_outbound_https" {
  group     = ibm_is_security_group.fgt_security_group_port1.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  protocol  = "tcp"
  port_min  = 443
  port_max  = 443
  name      = "allow-outbound-fortiguard-licensing-tcp-443"
}

resource "ibm_is_security_group_rule" "fgt_port1_outbound_fortiguard_updates" {
  group     = ibm_is_security_group.fgt_security_group_port1.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  protocol  = "tcp"
  port_min  = 8890
  port_max  = 8890
  name      = "allow-outbound-fortiguard-updates-tcp-8890"
}



resource "ibm_is_security_group" "fgt_security_group_port2" {
  name  = "${var.cluster_name}-fgt-sg-port2-${random_string.random_suffix.result}"
  vpc   = data.ibm_is_vpc.vpc1.id
}

# Inbound - allow traffic only from interfaces in this same SG (inter-FGT)
resource "ibm_is_security_group_rule" "fgt_port2_inbound_self" {
  group     = ibm_is_security_group.fgt_security_group_port2.id
  direction = "inbound"
  remote    = ibm_is_security_group.fgt_security_group_port2.id
  name      = "allow-inbound-from-same-sg"
}

# Outbound - allow traffic only to interfaces in this same SG (inter-FGT)
resource "ibm_is_security_group_rule" "fgt_port2_outbound_self" {
  group     = ibm_is_security_group.fgt_security_group_port2.id
  direction = "outbound"
  remote    = ibm_is_security_group.fgt_security_group_port2.id
  name      = "allow-outbound-to-same-sg"
}


resource "ibm_is_virtual_network_interface" "vni-port1" {
  name                      = "${var.cluster_name}-fgt-interface1-${random_string.random_suffix.result}"
  allow_ip_spoofing         = false
  auto_delete               = false
  enable_infrastructure_nat = true
  security_groups           = [ibm_is_security_group.fgt_security_group_port1.id]
  subnet                    = data.ibm_is_subnet.subnet1.id

}

resource "ibm_is_virtual_network_interface" "vni-port2" {
  name                      = "${var.cluster_name}-fgt-interface2-${random_string.random_suffix.result}"
  allow_ip_spoofing         = false
  auto_delete               = false
  enable_infrastructure_nat = true
  security_groups           = [ibm_is_security_group.fgt_security_group_port2.id]
  subnet                    = data.ibm_is_subnet.subnet2.id

}