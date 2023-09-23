resource "aws_vpc" "demo_vpc" {
  cidr_block           = var.vpc_cidr # Use the variable for the VPC CIDR block
  instance_tenancy     = var.instanceTenancy
  enable_dns_support   = var.dnsSupport
  enable_dns_hostnames = var.dnsHostNames

  tags = {
    name = "${var.vpc_cidr}-vpc"
  }

}

resource "aws_security_group" "custom_sg" {
  name        = "custom-sg"
  description = "Custom security group with restricted rules for VPC"
  vpc_id      = aws_vpc.demo_vpc.id

  # Define inbound rules to allow specific traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ingressCIDRblock # Replace with your trusted IP
    description = "Allow SSH access from anywhere"
  }

  # Define outbound rules to allow specific traffic
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["172.0.0.0/32"]
    #cidr_blocks = ["10.0.0.0/16"] # restrict egress traffic to only specific destinations, such as an RDS database or an API endpoint
    description = "Allow outbound traffic"
  }


  tags = {
    Name        = "My VPC Security Group"
    Description = "My VPC Security Group"
  }
}

resource "aws_subnet" "my_private_subnet" {
  vpc_id            = aws_vpc.demo_vpc.id
  cidr_block        = var.private_subnet_cidr # Use the variable for the private subnet CIDR block
  availability_zone = var.availabilityZone

  tags = {
    Name = "My Private Subnet"
  }
}

resource "aws_subnet" "my_public_subnet" {
  vpc_id                  = aws_vpc.demo_vpc.id
  cidr_block              = var.public_subnet_cidr # Use the variable for the public subnet CIDR block
  availability_zone       = var.availabilityZone
  map_public_ip_on_launch = false # This is a public subnet

  tags = {
    Name = "My Public Subnet"
  }
}

resource "aws_flow_log" "demo_vpc" {
  log_destination      = "arn:aws:s3:::kayode_s3_bucket_2023" # Use the ARN of your existing S3 bucket
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.demo_vpc.id


}


resource "aws_nat_gateway" "demo_ngw" {
  count = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.public_ip.id  # Replace with your Elastic IP allocation ID
  subnet_id = aws_subnet.my_public_subnet.id # Replace with your public subnet ID

  tags = {
    Name        = "My NAT Gateway"
    Environment = "Production"
  }
}


output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.demo_vpc.id
}

# create VPC Network access control list
resource "aws_network_acl" "My_VPC_Security_ACL" {
  vpc_id     = aws_vpc.demo_vpc.id
  subnet_ids = [aws_subnet.my_public_subnet.id]

  # allow ingress port 22
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 22
    to_port    = 22
  }

  # allow ingress port 80 
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 80
    to_port    = 80
  }

  # allow ingress ephemeral ports 
  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 1024
    to_port    = 65535
  }

  # allow egress port 22 
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 22
    to_port    = 22
  }

  # allow egress port 80 
  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 80
    to_port    = 80
  }

  # allow egress ephemeral ports
  egress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = var.destinationCIDRblock
    from_port  = 1024
    to_port    = 65535
  }
  tags = {
    Name = "My VPC ACL"
  }
}

# Create the Internet Gateway
resource "aws_internet_gateway" "demo_vpc_GW" {
  vpc_id = aws_vpc.demo_vpc.id
  tags = {
    Name = "My VPC Internet Gateway"
  }
}

# Create the Route Table
resource "aws_route_table" "demo_vpc_route_table" {
  vpc_id = aws_vpc.demo_vpc.id
  tags = {
    Name = "My VPC Route Table"
  }
}

# Create the Internet Access
resource "aws_route" "demo_vpc_internet_access" {
  route_table_id         = aws_route_table.demo_vpc_route_table.id
  destination_cidr_block = var.destinationCIDRblock
  gateway_id             = aws_internet_gateway.demo_vpc_GW.id
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "demo_vpc_association" {
  subnet_id      = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.demo_vpc_route_table.id
}

resource "aws_default_security_group" "default" {     # remove both ingress and egress from default security group like this
  vpc_id = aws_vpc.demo_vpc.id                       # That is, no association with default security group
}