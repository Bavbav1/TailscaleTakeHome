provider "aws" {
  region = var.aws_region
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

# Create a subnet within the VPC
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.availability_zone

  tags = {
    Name = var.subnet_name
  }
}

# Create a security group to allow SSH and Tailscale traffic
resource "aws_security_group" "allow_ssh_and_tailscale" {
  name        = "allow_ssh_and_tailscale"
  description = "Allow SSH and Tailscale inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 41641
    to_port     = 41641
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow SSH and Tailscale"
  }
}

# Create an EC2 instance in the newly created VPC and subnet using user_data
resource "aws_instance" "tailscale_routers" {
  ami           = var.ami_id  # Use a variable for the AMI ID
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  vpc_security_group_ids = [aws_security_group.allow_ssh_and_tailscale.id]
  subnet_id              = aws_subnet.my_subnet.id

  user_data = <<-EOF
    #!/bin/bash
    exec > >(tee /var/log/tailscale-user-data.log|logger -t tailscale-user-data -s 2>/dev/console) 2>&1

    echo -e '\n#\n# Beginning Tailscale installation...\n#\n'

    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

    apt-get -qq update
    apt-get install -yqq tailscale

    # Advertise the full VPC range and enable Tailscale's SSH
    tailscale up --advertise-routes=${var.vpc_cidr_block} --ssh

    echo -e '\n#\n# Tailscale installation complete.\n#\n'

    # Check Tailscale connection status
    tailscale status --peers=false 2>&1 1> /dev/null && echo -e '\n#\n# Tailscale status: connected\n#\n' || echo -e '\n#\n# Tailscale status: NOT connected\n#\n'
  EOF

  tags = {
    Name = "Tailscale Subnet Router"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "My_Internet_Gateway"
  }
}

# Create a route table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "My_Route_Table"
  }
}

# Associate the subnet with the route table
resource "aws_route_table_association" "my_subnet_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}
