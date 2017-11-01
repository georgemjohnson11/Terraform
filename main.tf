provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "us-east-1"
}

resource "aws_launch_configuration" "application" {
  image_id      = "ami-8c1be5f6"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.application_security.id}"] 

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.from_port}" &
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "application" {
  launch_configuration  = "${aws_launch_configuration.application.id}"
  availability_zones    = ["us-east-1a"]

  load_balancers        = ["${aws_elb.application.name}"]
  health_check_type     = "ELB"

  min_size = 1
  max_size = 1

  tag {
    key                 = "Application"
    value               = "terraform-application-asg"
    propagate_at_launch = true
  }  
}

resource "aws_security_group" "application_security" {
  name = "terraform-application-security"
  ingress {
    from_port   = "${var.from_port}"
    to_port     = "${var.to_port}"
    protocol    = "tcp"
    cidr_blocks = "${var.cidrs}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "application" {
   name               = "terraform-application-elb"
   availability_zones = ["us-east-1a"]
   security_groups    = ["${aws_security_group.elb_security.id}"]

   listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.from_port}"
    instance_protocol = "http"
   }

   health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.from_port}/"
   }
 } 


resource "aws_security_group" "elb_security" {
  name = "terraform-application-security-elb"

  ingress {
    from_port   = 80
    to_port     = 80
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