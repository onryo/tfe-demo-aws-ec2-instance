terraform {
  required_version = ">= 0.12.1"
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ubuntu" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  availability_zone      = "${var.aws_region}b"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name  = "${var.name}_ubuntu"
    owner = var.owner
    TTL   = var.ttl
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "${var.name}_allow_ssh"
  description = "Allow TLS inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  tags = {
    Name  = "${var.name}_allow_ssh"
    owner = var.owner
    TTL   = var.ttl
  }
}

