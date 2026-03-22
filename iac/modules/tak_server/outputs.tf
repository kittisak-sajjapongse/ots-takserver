output "instance_id" {
  value = aws_instance.tak.id
}

output "public_ip" {
  value = aws_eip.tak.public_ip
}

output "security_group_id" {
  value = aws_security_group.tak.id
}
