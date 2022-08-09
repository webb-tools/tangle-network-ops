output "collator_node_ip_address" {
  value = aws_instance.collator_node_public.*.private_ip
}