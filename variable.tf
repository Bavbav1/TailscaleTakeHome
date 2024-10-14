variable "My-keys-tailscale" {
  description = "The SSH key name to access the EC2 instance"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy the EC2 instance"
  type        = string
  default     = "us-east-1"
}
