output "rds-endpoint" {
  value = aws_db_instance.rds_instance.endpoint
}

output "rds-hostname" {
  value = aws_db_instance.rds_instance.address
}

output "ec2-app-server"{
  value = aws_instance.app_server.public_ip
}
