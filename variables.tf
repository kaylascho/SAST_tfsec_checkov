variable "ec2_instance_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}


variable "sqs_queue_queue_name" {
  type        = string
  description = "Name of the SQS queue"
  default     = "my-queue-name"
}

variable "asg_instance_type" {
  type        = string
  description = "EC2 instance type for the Auto Scaling Group"
  default     = "t2.micro"
}

variable "asg_availability_zones" {
  type        = list(string)
  description = "List of availability zones for the Auto Scaling Group"
  default     = ["us-west-1a"]
}

variable "asg_name" {
  type        = string
  description = "Name of the Auto Scaling Group"
  default     = "my-asg"
}

variable "asg_max_size" {
  type        = number
  description = "Maximum size of the Auto Scaling Group"
  default     = 5
}

variable "asg_min_size" {
  type        = number
  description = "Minimum size of the Auto Scaling Group"
  default     = 1
}

variable "asg_health_check_grace_period" {
  type        = number
  description = "Health check grace period for the Auto Scaling Group"
  default     = 300
}

variable "asg_health_check_type" {
  type        = string
  description = "Health check type for the Auto Scaling Group"
  default     = "ELB"
}

variable "asg_desired_capacity" {
  type        = number
  description = "Desired capacity of the Auto Scaling Group"
  default     = 4
}

variable "asg_force_delete" {
  type        = bool
  description = "Force delete the Auto Scaling Group"
  default     = true
}

variable "iam_instance_profile_name" {
  type        = string
  description = "Name of the IAM instance profile"
  default     = "jenkins-ec2-instance-profile"
}

variable "iam_role_name" {
  type        = string
  description = "Name of the IAM role"
  default     = "my-ec2-role-name"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for the public subnet"
  default     = "10.0.0.0/24" # Replace with your desired public subnet CIDR block
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR block for the private subnet"
  default     = "10.0.1.0/24" # Replace with your desired private subnet CIDR block
}

# variables.tf

variable "enable_nat_gateway" {
  type    = bool
  default = true # You can change the default value if needed
}


variable "instanceTenancy" {
  default = "default"
}
variable "dnsSupport" {
  default = true
}
variable "dnsHostNames" {
  default = true
}

variable "availabilityZone" {
  default = "us-west-1a"
}

variable "ingressCIDRblock" {
  type    = list(any)
  default = ["10.1.0.0/16"]
}

variable "destinationCIDRblock" {
  default = "10.0.0.0/32"
}