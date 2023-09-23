resource "aws_vpc" "demo_vpc" {
  cidr_block = var.vpc_cidr  # Use the variable for the VPC CIDR block
  
  tags = {
    name = "${var.vpc_cidr}-vpc"
  }

}

resource "aws_security_group" "custom_sg" {
  name = "custom-sg"
  description = "Custom security group with restricted rules"
  vpc_id = aws_vpc.demo_vpc.id

  # Define inbound rules to allow specific traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["176.0.0.0/32"] # Replace with your trusted IP
    description = "Allow SSH access from anywhere"
  }

  # Define outbound rules to allow specific traffic
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # restrict egress traffic to only specific destinations, such as an RDS database or an API endpoint
    description = "Allow outbound traffic"
  }
}

resource "aws_default_security_group" "default" {     # This is required for default security group and can be modified accordingly
                                                       # Ensure that default security group is not connected to your vpc

  // Ingress rule to deny all inbound traffic
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self = true
  }

  // Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_subnet" "my_private_subnet" {
  vpc_id                  = aws_vpc.demo_vpc.id
  cidr_block                    = var.private_subnet_cidr  # Use the variable for the private subnet CIDR block
  availability_zone       = "us-west-1a"  # Replace with your desired availability zone

  tags = {
    Name = "My Private Subnet"
  }
}

resource "aws_subnet" "my_public_subnet" {
  vpc_id                  = aws_vpc.demo_vpc.id
  cidr_block                    = var.public_subnet_cidr  # Use the variable for the public subnet CIDR block
  availability_zone       = "us-west-1a"  # Replace with your desired availability zone
  map_public_ip_on_launch = false  # This is a public subnet

  tags = {
    Name = "My Public Subnet"
  }
}

resource "aws_flow_log" "demo_vpc" {
  log_destination         = "arn:aws:s3:::kayode_s3_bucket_2023"  # Use the ARN of your existing S3 bucket
  log_destination_type    = "s3"
  traffic_type            = "ALL"
  vpc_id                  = aws_vpc.demo_vpc.id


}



resource "aws_nat_gateway" "demo_ngw" {
  count       = var.enable_nat_gateway ? 1 : 0
  #allocation_id = aws_eip.example.id  # Replace with your Elastic IP allocation ID
  subnet_id   = aws_subnet.my_public_subnet.id  # Replace with your public subnet ID

  tags = {
    Name = "My NAT Gateway"
    Environment = "Production"
  }
}


output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.demo_vpc.id
}