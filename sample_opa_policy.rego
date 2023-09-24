package aws_resources
# Define a rule to check VPC resources
check_vpc {
    resource := input.aws_vpc[_]
    has_tags
    is_encrypted
}

# Define a rule to check subnet resources
check_subnet {
    resource := input.aws_subnet[_]
    has_tags
    is_encrypted
}

# Define a rule to check EC2 instances
check_ec2 {
    resource := input.aws_instance[_]
    has_tags
    is_encrypted
}

# Define a rule to check security groups for VPC
check_security_group_vpc {
    resource := input.aws_security_group[_]
    has_tags
}

# Define a rule to check security groups for EC2
check_security_group_ec2 {
    resource := input.aws_security_group[_]
    has_tags
}

# Main rule that combines all checks
main = {
    "vpc": check_vpc,
    "subnet": check_subnet,
    "ec2": check_ec2,
    "security_group_vpc": check_security_group_vpc,
    "security_group_ec2": check_security_group_ec2
}
