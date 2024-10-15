# AWS Region
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

# VPC CIDR Block
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "172.31.0.0/16"
}

# VPC Name
variable "vpc_name" {
  description = "VPC name "
  type        = string
  default     = "My_VPC"
}

# Subnet CIDR Block
variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "172.31.1.0/24"
}

# Subnet Name
variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "My_Subnet"
}

# Availability Zone
variable "availability_zone" {
  description = "The AWS availability zone for the subnet"
  type        = string
  default     = "us-east-1a"
}

# AMI ID
variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0866a3c8686eaeeba"  
}

# Instance Type
variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

# SSH Key Name
variable "ssh_key_name" {
  description = "The name of the SSH key pair for the EC2 instance"
  type        = string
  default     = "My-keys-tailscale"  
}
