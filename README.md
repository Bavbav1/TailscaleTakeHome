# TailscaleTakeHome
This assignment demonstrates the deployment of secure and private Tailscale subnet routers on AWS EC2 instance. The setup involves deploying EC2 instance through  Terraform. The machine is connected to a Tailscale Tailnet, enabling private communication and routing between them.

The focus is on securely connecting and routing traffic across the Tailnet using Tailscale’s VPN service.

Key Components:

Tailscale: A secure, peer-to-peer VPN service that enables private network routing across devices and cloud instances.
AWS EC2 Instance:  deployed using Terraform and configured to advertise their private subnets.

Architecture

The architecture includes:

EC2 Instances:
Instance 1: Deployed via Terraform with public IP 54.167.XXX.XX, acting as a subnet router advertising the subnet 172.31.41.134/32.

Subnet Routing: All devices advertise their private subnets on Tailscale, ensuring secure routing of traffic between devices.

Prerequisites: 
Before deploying this setup, ensure the following tools are installed and properly configured:

AWS CLI: Configured with appropriate access keys and permissions. 
Terraform: relevant version
Tailscale Account: A working Tailscale account to manage your devices and Tailnet.
SSH Key: A key pair created in AWS for accessing the EC2 instances.


Deployment Instructions:

Step 1: Clone the Repository
To start, clone this repository to your local machine:
git clone https://github.com/Bavbav1/TailscaleTakeHome.git
cd TailscaleTakeHome

Step 2: Terraform Configuration
The following files are provided to deploy an EC2 instance via Terraform:

main.tf: Defines the EC2 instance and security group configuration.
variables.tf: Contains configurable variables like the AWS region and SSH key name.
outputs.tf: Outputs the public IP of the EC2 instance once deployed.

Step 3: Customize Variables
Before applying the Terraform configuration, update variables.tf to reflect your AWS settings:
variable "aws_region" {
  default = "us-east-1"
}

variable "key_name" {
  description = "The name of the SSH key pair"
  default     = "your-aws-key"
}

Make sure to replace "your-aws-key" with the actual name of your AWS key pair.

Step 4: Initialize and Apply Terraform
Once the configuration is set, initialize and apply the Terraform deployment:

1. Initialize Terraform:
   terraform init
   
3. Apply the cofig
   terraform apply
   
This will create an EC2 instance , configure the required security groups, and deploy Tailscale on the instance. It will also advertise the subnet CIDR on Tailscale.

Step 5: Manually Deployed Instance via AWS
For testing purposes, another EC2 instance was manually deployed via AWS. This instance has the following details:


Step 6: Verify the Deployment
1. SSH into the EC2 Instances: Use the public IP addresses to SSH into your instances.

Instance 1 (Terraform-deployed):
ssh -i /path/to/your-key.pem ubuntu@XX.XXX.XXX.XXX

2. Check Tailscale Status: Run the following command on each instance to verify that Tailscale is running and subnet routing is enabled:
   
tailscale status

You should see information about the connected devices in the output

3. Check Subnet Routes: Confirm that the subnet CIDR is being advertised and accepted by devices in the Tailnet.
   
Step 8: Security Group Configuration
The security group attached to the EC2 instances allows inbound SSH (port 22) and Tailscale P2P traffic (port 41641 UDP):
resource "aws_security_group" "allow_ssh_and_tailscale" {
  name        = "allow_ssh_and_tailscale"
  description = "Allow SSH and Tailscale inbound traffic"

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
}


Cleanup
To delete the resources created by Terraform, run:
terraform destroy

Conclusion
This assignment demonstrates the deployment of Tailscale subnet routers using Terraform on AWS EC2 instances with the machine advertising its private subnets to the Tailnet. The EC2 instance is  securely connected through Tailscale, allowing seamless communication and routing across the network.
