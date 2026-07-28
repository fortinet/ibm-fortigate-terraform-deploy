output "FortiGate_Public_IP" {
  value = ibm_is_floating_ip.publicip.address
}

output "Custom_Image_Name" {
  description = "Your local FortiGate Custom Image reference"
  value       = ibm_is_image.vnf_custom_image.name
}

output "Security_Group_Port1_Name" {
  description = "The name of the security group attached to FortiGate port1"
  value       = ibm_is_security_group.fgt_security_group_port1.name
}

output "Security_Group_Port2_Name" {
  description = "The name of the security group attached to FortiGate port2"
  value       = ibm_is_security_group.fgt_security_group_port2.name
}

output "Username" {
  value = "admin"
}

output "Default_Admin_Password" {
  value = ibm_is_instance.fgt1.id
}