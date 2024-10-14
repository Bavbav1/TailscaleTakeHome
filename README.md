# TailscaleTakeHome
This assignment demonstrates the deployment of secure and private Tailscale subnet routers on AWS EC2 instances. The setup involves deploying EC2 instances through both Terraform and manual AWS configuration for testing purposes. All devices are connected to a Tailscale Tailnet, enabling private communication and routing between them.

While the deployment was tested using two different methods, the focus remains on securely connecting and routing traffic across the Tailnet using Tailscale’s VPN service.

Key Components:

Tailscale: A secure, peer-to-peer VPN service that enables private network routing across devices and cloud instances.
AWS EC2 Instances: Two EC2 instances, one deployed using Terraform and the other manually via AWS, both configured to advertise their private subnets.
MacBook Device: A personal MacBook connected to the Tailnet using the Tailscale client, also configured to advertise its private subnet.
Subnet Routing: All devices advertise their private subnets to the Tailnet, ensuring secure and seamless communication.

Architecture

The architecture includes:

EC2 Instances:
Instance 1: Deployed via Terraform with public IP 34.229.185.111, acting as a subnet router advertising the subnet 172.31.32.0/20.
Instance 2: Manually configured via AWS with public IP 54.165.243.182, also advertising the subnet 172.31.32.0/20.
MacBook Device: Connected to the Tailnet using the Tailscale client, configured to advertise its private subnet 192.168.4.0/22
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
2. Apply the cofig
   terraform apply
This will create an EC2 instance with public IP 34.229.185.111, configure the required security groups, and deploy Tailscale on the instance. It will also advertise the subnet 172.31.32.0/20 on Tailscale.

Step 5: Manually Deployed Instance via AWS
For testing purposes, another EC2 instance was manually deployed via AWS. This instance has the following details:

Public IP: 54.165.243.182
Private Subnet: Shares the same subnet 172.31.32.0/20.
Tailscale was manually installed and configured on this instance to join the Tailnet and advertise the same subnet as the Terraform-deployed instance.

Step 6: MacBook Connected via Tailscale Client
A personal MacBook (tolas-macbook-air) is connected to the Tailnet using the Tailscale client. The MacBook is also configured to advertise the private subnet 172.31.32.0/20.

Step 7: Verify the Deployment
1. SSH into the EC2 Instances: Use the public IP addresses to SSH into your instances.

Instance 1 (Terraform-deployed):
ssh -i /path/to/your-key.pem ubuntu@34.229.185.111

Instance 2 (Manually deployed):
ssh -i /path/to/your-key.pem ubuntu@54.165.243.182
2. Check Tailscale Status: Run the following command on each instance to verify that Tailscale is running and subnet routing is enabled:
tailscale status

You should see information about the connected devices, including:

MacBook: tolas-macbook-air
Linux EC2 Instance 1: ip-172-31-33-219
Linux EC2 Instance 2: ip-172-31-42-19

3. Check Subnet Routes: Confirm that the subnet 172.31.32.0/20 is being advertised and accepted by devices in the Tailnet.
   
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

Devices on Tailnet
Device Name	Device ID	OS	Tailscale IP	Public IP	Advertised Subnet
ip-172-31-33-219	nSPgFzzSWG11CNTRL	Linux	100.92.43.33	34.229.185.111	172.31.32.0/20
ip-172-31-42-19	n2TjW1uAj511CNTRL	Linux	100.109.29.77	54.165.243.182	172.31.32.0/20
tolas-macbook-air	nb3NRd8Nv621CNTRL	macOS	100.117.228.21	N/A	172.31.32.0/20

Cleanup
To delete the resources created by Terraform, run:
terraform destroy

Conclusion
This assignment demonstrates the deployment of Tailscale subnet routers using Terraform on AWS EC2 instances and a MacBook, with all devices advertising their private subnets to the Tailnet. Both EC2 instances and the MacBook are securely connected through Tailscale, allowing seamless communication and routing across the network.
