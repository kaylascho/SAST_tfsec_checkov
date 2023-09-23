resource "aws_instance" "ec2_instance" {
  ami                  = data.aws_ami.amzlinux2.id
  instance_type        = var.ec2_instance_instance_type
  subnet_id            = aws_subnet.my_private_subnet.id # Specify the subnet ID here
  key_name             = "key_for_practice"              # Include the KMS key description in the key name
  monitoring           = true
  ebs_optimized        = true
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name # taken from iam_role.tf
  security_groups      = [aws_security_group.custom_sg.name]                # Attach the security group to the EC2 instance


  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    encrypted             = true
    delete_on_termination = true
    kms_key_id            = "arn:aws:kms:us-west-1:986114105941:key/92610e36-0cd6-4fc7-be9a-bfa7831db4b0" # Replace the KMS key ARN with your actual KMS key ARN
  }

  tags = {
    Name = "EC2 Instance"
  }
}

data "aws_ami" "amzlinux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_eip" "public_ip" {
  instance = aws_instance.ec2_instance.id  # Replace with the ID of the EC2 instance you want to associate with the EIP, or remove this line if not needed
  #vpc = true     # will soon be deprecated
  domain = "vpc"  # recommended to specify for VPC EIP
}

