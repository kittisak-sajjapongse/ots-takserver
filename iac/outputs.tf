output "instance_id" {
  value = module.tak_server.instance_id
}

output "public_ip" {
  value = module.tak_server.public_ip
}

output "security_group_id" {
  value = module.tak_server.security_group_id
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "availability_zones" {
  value = module.network.availability_zones
}
