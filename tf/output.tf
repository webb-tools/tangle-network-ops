output "bastion_ip_address" {
  value = aws_instance.bastion.public_ip
}

output "authority_node_ip_address" {
  value = aws_instance.authority_node.private_ip
}

output "full_node_ip_address" {
  value = aws_instance.full_node_public.*.private_ip
}

output "full_node_secondary_ip_address" {
  value = aws_instance.full_node_public_secondary.*.private_ip
}
