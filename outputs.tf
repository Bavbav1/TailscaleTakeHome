output "ec2_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.tailscale_routers.public_ip
}

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.my_vpc.id
}
