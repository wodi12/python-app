# AMI ID
data "aws_ami" "amazonlinux" {
  most_recent      = true
  # name_regex       = "^ami-0[0-9a-f]{10}$"
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.4.20240319.1-*"]
  }

  # filter {
  #   name   = "root-device-type"
  #   values = ["ebs"]
  # }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
  name = "architecture"
  values = [ "x86_64" ]
  }
  
}

# Launch template
resource "aws_launch_template" "main" {
  name = "jenkins-template"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
      delete_on_termination = true
    }
  }

  # capacity_reservation_specification {
  #   capacity_reservation_preference = "open"
  # }

  # cpu_options {
  #   core_count       = 4
  #   threads_per_core = 2
  # }

  # credit_specification {
  #   cpu_credits = "standard"
  # }

  # disable_api_stop        = false
  # disable_api_termination = false

  # ebs_optimized = true

  # elastic_gpu_specifications {
  #   type = "test"
  # }

  # elastic_inference_accelerator {
  #   type = "eia1.medium"
  # }

  # iam_instance_profile {
  #   name = "test" # <--------------
  # }

  image_id = data.aws_ami.amazonlinux.id

  instance_initiated_shutdown_behavior = "terminate"

  instance_market_options {
    market_type = "spot"
  }

  instance_type = var.instance_type

  key_name = var.instance_keypair



  monitoring {
    enabled = true
  }

  # network_interfaces {
  #   associate_public_ip_address = true
  # }

  vpc_security_group_ids = ["sg-076a263fa5da1717e"] # <-------

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "jenkins-asg"
    }
  }

  user_data = filebase64("${path.module}/installations.sh")
}


resource "aws_autoscaling_group" "jenkins" {
  name                      = "jenkins-group"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  force_delete              = true   
  vpc_zone_identifier       = ["subnet-08097e04211f22c2d", "subnet-08160280f6c3366f9"] # <--------------
  target_group_arns         = []

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  instance_maintenance_policy {
    min_healthy_percentage = 90
    max_healthy_percentage = 120
  }


  tag {
    key                 = "Createdby"
    value               = "terraform"
    propagate_at_launch = true
  }

  timeouts {
    delete = "20m"
  }

}

resource "aws_autoscaling_attachment" main {
  autoscaling_group_name = aws_autoscaling_group.jenkins.id
  lb_target_group_arn = aws_lb_target_group.jenkins.arn
}

# Target group
resource "aws_lb_target_group" "jenkins" {
  name     = "jenkins-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "vpc-05b73b4064618b9e3" # <--------
  health_check {
    enabled = "true"
    path = "/login"
  }
}

# resource "aws_lb_target_group_attachment" "tg_attachment_a" {
#  target_group_arn = aws_lb_target_group.jenkins.arn
#  target_id        = aws_autoscaling_attachment.main.id # <-------
#  port             = 8080
# }

# ALB
resource "aws_lb" "jenkins_alb" {
  name               = "jenkins-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-076a263fa5da1717e"] # <--------
  subnets            = ["subnet-08097e04211f22c2d", "subnet-08160280f6c3366f9"] # <-----------
}

resource "aws_lb_listener" "my_alb_listener" {
 load_balancer_arn = aws_lb.jenkins_alb.arn
 port              = "80" # change to 443
 protocol          = "HTTP" # change to HTTPS and add cert

 default_action {
   type             = "forward"
   target_group_arn = aws_lb_target_group.jenkins.arn
 }
}


# EFS
resource "aws_efs_file_system" "jenkins" {
  creation_token = "jenkins"

  tags = {
    Name = "jenkins-efs"
  }
}

resource "aws_efs_mount_target" "jenkins" {
  file_system_id = aws_efs_file_system.jenkins.id
  for_each = toset(var.subnet_ids)
  subnet_id        = each.value
}

resource "aws_security_group" "efs_sg" {
  name_prefix = "efs-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}