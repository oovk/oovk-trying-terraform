# Terraform commands: terraform init(initialize), terraform apply(apply given config), terraform plan(shows resource plan), terraform destroy(removes all the deployed resources)
# Symbols: +(added changes), -(removed changes) and ~(updations in infra)


# EC2 resource Declaration, ami-instance_id by amazon supposed to change frequently
/* resource "aws_instance" "first-terraform-instance" {
  ami           = "ami-0d527b8c289b4af7f"
  instance_type = "t2.micro"

  tags = {
    Name = "terra-instance"
  }
}
 */

# Declare VPC
/* resource "aws_vpc" "terraform-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "production"
  }
}

# Delcare subnet in vpc
resource "aws_subnet" "terra-subnet" {
  vpc_id     = aws_vpc.terraform-vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    "Name" = "prod-subnet"
  }
} */

# Project Demo:

/* 1. Create vpc
2. Create Internet Gateway
3. Create custom route table
4. Create subnet
5. Associate subnet with route table
6. Create security group to allow port 22, 80, 443
7. Create network interface with an ip in the subnet that was created in step 4
8. Assign an elastic IP to the network interface created in step 7
9. Create Ubuntu server and install/enable apache
 */

# Provider Configurations for connnecting to AWS
provider "aws" {
  region     = "eu-central-1"
  access_key = ""
  secret_key = ""
}


# Create vpc
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id

}

# Create custom route table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Prod"
  }
}

# Create subnet
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "prod-subnet"
  }
}

# Associate subnet with route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}

#Create security group to allow port 22, 80, 443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "allow_web"
  }
}

# Create network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}

# Assign an elastic IP to the network interface created in step 7
# EIP may require IGW to exist prior to association. Use depends_on here.
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [
    aws_internet_gateway.gw,
  ]
}

# Create Ubuntu server and install/enable apache
resource "aws_instance" "web-server-instance" {
  ami               = "ami-0d527b8c289b4af7f"
  instance_type     = "t2.micro"
  availability_zone = "eu-central-1a"
  key_name          = "oovk-terraform"

  network_interface {
    network_interface_id = aws_network_interface.web-server-nic.id
    device_index         = 0
  }

  user_data = <<-EOF
		#! /bin/bash
        sudo apt update -y
		sudo apt install apache2 -y
		sudo systemctl start apache2
		sudo bash -c 'echo your very first web server" > /var/www/html/index.html'
	    EOF

  tags = {
    Name = "web-server"
  }

}
