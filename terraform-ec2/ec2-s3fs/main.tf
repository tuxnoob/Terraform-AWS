data "aws_availability_zones" "available" {}

terraform {
  backend "s3" {
    encrypt                 = true
    bucket                  = "terraform-tuxnoob"
    region                  = "ap-southeast-3"
    key                     = "terraform-tuxnoob/Infra/AWS-EC2/S3fs/terraform.tfstate"
    profile                 = "default"
    shared_credentials_file = "~/.aws/credentials"
    role_arn                = "arn:aws:iam::xxxxxxxxxxxxxxx:role/DevOps_Engineer"
  }
}

locals {
  subnet_id = ["subnet-xxxxxxxxxxxxxx"]
  profile   = "default"
  region    = "ap-southeast-3"
  #  ec2-name = "testing-devstaging-${trimprefix(data.aws_availability_zones.available.names[count.index], "ap-southeast-")}"
  ec2-name = "Tuxnoob-S3fs"
  #  sg-name = "testing-devstaging-sg-${trimprefix(data.aws_availability_zones.available.names[count.index], "ap-southeast-")}"
  sg-name = "Tuxnoob-S3fs-SG"
  tags = {
    Environment  = "Tuxnoob Infrastructure"
    Env          = "Infra"
    Organization = "tuxnoob-id"
    ManagedBy    = "terraform"
    Terraform    = true
    Type         = "storage-infra"
  }

}

###############################################################################
###############################################################################
###############################################################################

#Provider AWS
provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = local.profile
  region                   = local.region
}

#AWS Key Name
resource "aws_key_pair" "tuxnoob" {
  key_name   = "tuxnoob-s3fs"
  public_key = file("~/.ssh/deployer.pub")
}

#AWS EC2
module "ec2_instance" {
  source                      = "../ec2/"
  count                       = 1
  name                        = "${local.ec2-name}-${trimprefix(data.aws_availability_zones.available.names[count.index], "ap-southeast-")}"
  ami                         = "ami-06edbb08d7b9081ce"
  instance_type               = "t4g.small"
  key_name                    = aws_key_pair.tuxnoob.id
  vpc_security_group_ids      = aws_security_group.tuxnoob-s3fs-sg[*].id
  subnet_id                   = ["${local.subnet_id[count.index]}"]
  user_data                   = file("tuxnoob.sh")
  associate_public_ip_address = true

  root_block_device = [
    {
      device_name = "/dev/sda1"
      volume_size = 15
      volume_type = "gp3"
    }
  ]

  tags = merge({ "Name" = "${local.ec2-name}-${trimprefix(data.aws_availability_zones.available.names[count.index], "ap-southeast-")}" }, local.tags)
}

# Security Group Creation
resource "aws_security_group" "tuxnoob-s3fs-sg" {
  count  = 1
  name   = "${local.sg-name}-${trimprefix(data.aws_availability_zones.available.names[count.index], "ap-southeast-")}"
  vpc_id = "vpc-xxxxxxxxxxx"

  tags = merge({ "Name" = "${local.sg-name}-${trimprefix(data.aws_availability_zones.available.names[count.index], "ap-southeast-")}" }, local.tags)
}

# Ingress Security Port 22
resource "aws_security_group_rule" "ssh_inbound_access" {
  count             = 1
  description       = "allow for ssh access"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = element(aws_security_group.tuxnoob-s3fs-sg.*.id, count.index)
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["10.0.0.0/16"]
}

resource "aws_security_group_rule" "nodeexporter_inbound_access" {
  count             = 1
  description       = "allow for nodeexporter metrics"
  from_port         = 9100
  protocol          = "tcp"
  security_group_id = element(aws_security_group.tuxnoob-s3fs-sg.*.id, count.index)
  to_port           = 9100
  type              = "ingress"
  cidr_blocks       = ["10.0.0.0/16"]
}

# All OutBound Access
resource "aws_security_group_rule" "all_outbound_access" {
  count             = 1
  from_port         = 0
  protocol          = "-1"
  security_group_id = element(aws_security_group.tuxnoob-s3fs-sg.*.id, count.index)
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Output EC2 Instance
output "key_name" {
  value       = aws_key_pair.tuxnoob
  description = "Name of key pair RSA"
}

output "region" {
  description = "AWS region."
  value       = local.region
}

output "profile" {
  description = "AWS profile."
  value       = local.profile
}

output "security_group" {
  value       = aws_security_group.tuxnoob-s3fs-sg[*].id
  description = "Id of security group"
}

output "ec2_instance_id" {
  description = "The ID of the instance"
  value       = module.ec2_instance[*].id
}

output "ec2_instance_arn" {
  description = "The ARN of the instance"
  value       = module.ec2_instance[*].arn
}

output "ec2_instance_capacity_reservation_specification" {
  description = "Capacity reservation specification of the instance"
  value       = module.ec2_instance[*].capacity_reservation_specification
}

output "ec2_instance_instance_state" {
  description = "The state of the instance. One of: `pending`, `running`, `shutting-down`, `terminated`, `stopping`, `stopped`"
  value       = module.ec2_instance[*].instance_state
}

output "ec2_instance_primary_network_interface_id" {
  description = "The ID of the instance's primary network interface"
  value       = module.ec2_instance[*].primary_network_interface_id
}

output "ec2_instance_private_dns" {
  description = "The private DNS name assigned to the instance. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC"
  value       = module.ec2_instance[*].private_dns
}

output "ec2_instance_public_dns" {
  description = "The public DNS name assigned to the instance. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
  value       = module.ec2_instance[*].public_dns
}

output "ec2_instance_public_ip" {
  description = "The public IP address assigned to the instance, if applicable. NOTE: If you are using an aws_eip with your instance, you should refer to the EIP's address directly and not use `public_ip` as this field will change after the EIP is attached"
  value       = module.ec2_instance[*].public_ip
}

output "ec2_instance_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block"
  value       = module.ec2_instance[*].tags_all
}
