output "validator_node_ip_address" {
  value = aws_instance.validator_node_public.*.public_ip
}