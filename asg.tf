resource "aws_launch_template" "my_web_template" {
  name_prefix   = "my-launch-template"
  instance_type = var.asg_instance_type

  metadata_options {
    http_tokens = "required"
  }

}

resource "aws_autoscaling_group" "my_asg" {
  availability_zones        = var.asg_availability_zones
  name                      = var.asg_name
  max_size                  = var.asg_max_size
  min_size                  = var.asg_min_size
  health_check_grace_period = var.asg_health_check_grace_period
  health_check_type         = var.asg_health_check_type
  desired_capacity          = var.asg_desired_capacity
  force_delete              = var.asg_force_delete

  tag { # tags must be passed in aws_autoscaling_group resource to be passed
    key                 = "Name"
    value               = "walmart_asg"
    propagate_at_launch = true
  }


  launch_template {
    id      = aws_launch_template.my_web_template.id
    version = "$Latest"
  }

}
