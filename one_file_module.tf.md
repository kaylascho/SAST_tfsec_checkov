provider "aws" {
  region = "us-west-1"
}

resource "aws_instance" "web" {
  instance_type = "t2.micro"
  ami = data.aws_ami.amzlinux2.id
  monitoring = true
  ebs_optimized = true

  # Add block_device_mappings to specify encryption for the root block device
  root_block_device {
    encrypted = true
  }

  # Specify metadata_options to require HTTP tokens for IMDS
  metadata_options {
    http_tokens = "required"
  }

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
}

# create IAM role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "jenkins-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  # Attach more policies and permissions as needed
}

# Create an instance profile associated with the IAM role
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "jenkins-ec2-instance-profile"
  role = aws_iam_role.jenkins_ec2_role.name
}



resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"
  #cidr_block = var.cidr_block
}

# Ensure the default security group of every VPC restricts all traffic
resource "aws_security_group" "custom_sg" {
  name_prefix = "custom-sg-"
  description = "Custom security group with restricted rules"

  # Define inbound rules to allow specific traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust as needed for your requirements
  }

  # Add more inbound rules as needed

  # Define outbound rules to allow specific traffic
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust as needed for your requirements
  }

  # Add more outbound rules as needed
}


resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.demo_vpc.id

  # Associate the custom security group as the default security group
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All traffic
    security_groups = [aws_security_group.custom_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All traffic
    security_groups = [aws_security_group.custom_sg.id]
  }
}




resource "aws_flow_log" "demo_vpc" {
  log_destination      = aws_s3_bucket.my_bucket.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.demo_vpc.id
}

resource "aws_launch_template" "my_web_template" {
  name_prefix   = "my-launch-template"
  instance_type = "t2.micro"
  # Other launch template settings
}

resource "aws_autoscaling_group" "my_asg" {
  availability_zones        = ["us-west-1a"]
  name                      = "my_asg"
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  force_delete              = true

  # Use the launch template instead of launch configuration
  launch_template {
    id = aws_launch_template.my_web_template.id
    version = "$Latest"  # Use the latest version of the launch template
  }
}


resource "aws_launch_template" "my_web_template" {
  name_prefix   = "my-web-template"
  image_id      = data.aws_ami.amzlinux2.id
  instance_type = "t2.micro"

  metadata_options {
    http_tokens = "required"
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
      volume_type = "gp2"
    }
  }

  # Other launch template settings, if needed
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

# Create an SQS queue (events notification) for s3 bucket. You can also use SQS topic
resource "aws_sqs_queue" "my_queue" {
  name = "s3_my-queue"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-bucket-name"

    # Enable event notifications (sqs queue)
  event_notification {
    queue {
      queue_arn     = aws_sqs_queue.my_queue.arn
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = "uploads/"
      filter_suffix = ".jpg"
    }
  }

  replication_configuration {
    role = aws_iam_role.replication_role.arn

    rule {
      id     = "cross-region-replication"
      status = "Enabled"

      destination {
        bucket = "arn:aws:s3:::destination-bucket-name" # Replace "destination-bucket-name" with the ARN or name of your destination bucket
        storage_class = "STANDARD" # Modify storage class as needed
      }
    }
  }  

}

# Create an aws_iam_role resource named "replication_role" and attach the necessary permissions using the assume_role_policy
resource "aws_iam_role" "replication_role" {
  name = "s3-replication-role"

  # Attach policies and permissions as needed for replication
  # Example: Attach the necessary permissions for S3 cross-region replication
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com",
        },
      },
    ],
  })
}


resource "aws_s3_bucket_public_access_block" "my_bucket" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "my_bucket" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.my_kms_key.arn
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_logging" "my_bucket" {
  bucket = aws_s3_bucket.my_bucket.bucket
  target_bucket = "kayode_setup_my_bucket"  # Replace with your log bucket
  target_prefix = "log/"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.my_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_kms_key" "my_kms_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  # Define a key policy
  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "key-default-1",
    Statement = [
      {
        Sid       = "Enable IAM User Permissions",
        Effect    = "Allow",
        Principal = "*",
        Action    = "kms:*",
        Resource  = "*",
        Condition = {
          Bool = {
            "kms:GrantIsForAWSResource" = "true"
          }
        }
      },
      {
        Sid       = "Allow administration of the key",
        Effect    = "Allow",
        Principal = {
          AWS = "arn:aws:iam::986114105941:root" # Replace with your AWS account ID
        },
        Action    = "kms:*",
        Resource  = "*"
      }
      # Add more statements as needed for your use case
    ],
  })
}

