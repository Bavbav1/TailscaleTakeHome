provider "aws" {
  region = "us-east-1"
}

# this will create the security group to allow SSH and Tailscale traffic
resource "aws_security_group" "allow_ssh_and_tailscale" {
  name        = "allow_ssh_and_tailscale"
  description = "Allow SSH and Tailscale inbound traffic"

  # Allow SSH (port 22) from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Tailscale traffic (port 41641 for P2P communication, UDP)
  ingress {
    from_port   = 41641
    to_port     = 41641
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
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

# Create an EC2 instance
resource "aws_instance" "tailscale_router" {
  ami           = "ami-0866a3c8686eaeeba"
  instance_type = "t2.micro"               
  key_name      = var.My-keys-tailscale

  #Security Group settings
  vpc_security_group_ids = [aws_security_group.allow_ssh_and_tailscale.id]

  # Subnet Routing
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "curl -fsSL https://tailscale.com/install.sh | sh",
      "sudo tailscale up --advertise-routes=172.31.32.0/20",
      "sudo apt-get install openssh-server -y",
      "sudo systemctl enable ssh",
      "sudo systemctl start ssh"
    ]
    # Define how Terraform will connect via SSH
  connection {
    type        = "ssh"
    user        = "ubuntu"  # Default user for Ubuntu AMIs
    private_key = file("/Users/tolabavery/Downloads/My-keys-tailscale.pem")  # Path to your private SSH key
    host        = aws_instance.tailscale_router.public_ip  
   }
  }

  tags = {
    Name = "Subnet Router for Task1"
  }
}
