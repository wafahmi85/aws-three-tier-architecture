################################################################################
# Auto Scaling
################################################################################

#https://developer.hashicorp.com/terraform/tutorials/aws/aws-asg?utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS&utm_source=WEBSITE&_ga=2.42797157.1760158776.1676158630-296032563.1668325719

# Web tier asg
resource "aws_autoscaling_group" "web" {                        # Create auto-scaling group for web tier with desiresire capasity is 1 minimum 1 maximum 2.
  name                      = "web-asg"
  max_size                  = 2                               
  min_size                  = 1
  health_check_grace_period = 60
  health_check_type         = "ELB"                             # Will monitor both ALB and EC2
  desired_capacity          = 1
  vpc_zone_identifier       = aws_subnet.public_subnets.*.id    # will deploy an instance from any of public subnet defined.

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  lifecycle { 
    ignore_changes = [desired_capacity, target_group_arns]      # Prevent Terraform from scaling your instances when it changes other aspects of your configuration
  }

  depends_on = [
    aws_db_instance.rds           #Prevent creation before RDS created
  ]

  tag {
    key                 = "Name"
    value               = format("%s-web", var.name)
    propagate_at_launch = true
  }
}

# Web tier asg attachment
resource "aws_autoscaling_attachment" "web" {                   # Attach asg with load balancer
  autoscaling_group_name = aws_autoscaling_group.web.id
  lb_target_group_arn    = aws_lb_target_group.public.arn
}

# Web tier Scaling policy
resource "aws_autoscaling_policy" "web_scale_out" {            # Simple scaling policy for scale out
  name                   = "web_scale_out"
  autoscaling_group_name = aws_autoscaling_group.web.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 180
}

resource "aws_cloudwatch_metric_alarm" "web_scale_out" {            # Configure alarm to monitor cpu are more than 85% for two minutes before scale out.
  alarm_description   = "Monitors CPU utilization for Web ASG"
  alarm_actions       = [aws_autoscaling_policy.web_scale_out.arn]
  alarm_name          = "web_scale_out"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "85"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
}

resource "aws_autoscaling_policy" "web_scale_in" {            # Simple scaling policy for scale in
  name                   = "web_scale_in"
  autoscaling_group_name = aws_autoscaling_group.web.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 180
}

resource "aws_cloudwatch_metric_alarm" "web_scale_in" {                # Configure alarm to monitor cpu are less than 10% for two minutes before scale in.
  alarm_description   = "Monitors CPU utilization for Web ASG"
  alarm_actions       = [aws_autoscaling_policy.web_scale_in.arn]
  alarm_name          = "web_scale_in"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "10"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
}


# App tier asg
resource "aws_autoscaling_group" "app" {                  # Create auto-scaling group for app tier with desiresire capasity is 1 minimum 1 maximum 2.
  name                      = "app-asg"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 60
  health_check_type         = "ELB"                       # Will monitor both ALB and EC2
  desired_capacity          = 1
  vpc_zone_identifier       = aws_subnet.private_subnets.*.id   # will deploy an instance from any of private subnet defined.

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  lifecycle { 
    ignore_changes = [desired_capacity, target_group_arns]      # Prevent Terraform from scaling your instances when it changes other aspects of your configuration
  }

  depends_on = [
    aws_db_instance.rds           #Prevent creation before RDS created
  ]

  tag {
    key                 = "Name"
    value               = format("%s-app", var.name)
    propagate_at_launch = true
  }
}

# App tier asg attachment
resource "aws_autoscaling_attachment" "app" {                 # Attach asg with load balancer
  autoscaling_group_name = aws_autoscaling_group.app.id       
  lb_target_group_arn    = aws_lb_target_group.private.arn
}

# App tier Scaling policy
resource "aws_autoscaling_policy" "app_scale_out" {            # Simple scaling policy for scale out
  name                   = "app_scale_out"
  autoscaling_group_name = aws_autoscaling_group.app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 180
}

resource "aws_cloudwatch_metric_alarm" "app_scale_out" {            # Configure alarm to monitor cpu are more than 85% for two minutes before scale out.
  alarm_description   = "Monitors CPU utilization for App ASG"
  alarm_actions       = [aws_autoscaling_policy.app_scale_out.arn]
  alarm_name          = "app_scale_out"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "85"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
}

resource "aws_autoscaling_policy" "app_scale_in" {            # Simple scaling policy for scale in
  name                   = "app_scale_in"
  autoscaling_group_name = aws_autoscaling_group.app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 180
}

resource "aws_cloudwatch_metric_alarm" "app_scale_in" {                # Configure alarm to monitor cpu are less than 10% for two minutes before scale in.
  alarm_description   = "Monitors CPU utilization for Web ASG"
  alarm_actions       = [aws_autoscaling_policy.app_scale_in.arn]
  alarm_name          = "app_scale_in"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "10"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
}
