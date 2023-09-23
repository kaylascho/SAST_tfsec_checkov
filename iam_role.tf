resource "aws_iam_role" "ec2_role" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "EC2 Role"
  }
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = var.iam_instance_profile_name
  role = aws_iam_role.ec2_role.name
}

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.ec2_role.arn
}

