resource "aws_lb" "production" {
  name = "production"
  load_balancer_type = "application"
  internal = false
  security_groups = [aws_security_group.production_lb.id]
  subnets = [aws_subnet.production_public_1.id, aws_subnet.production_public_2.id]
}

resource "aws_lb_target_group" "production_backend" {
  name = "production-backend"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.production.id
  target_type = "ip"

  health_check {
    path = "/admin/"
    port = "traffic-port"
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 2
    interval = 5
    matcher = "302"
  }
}

resource "aws_lb_listener" "production_http" {
  load_balancer_arn = aws_lb.production.id
  port = "80"
  protocol = "HTTP"
  depends_on = [aws_lb_target_group.production_backend]

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.production_backend.arn
  }
}

resource "aws_security_group" "production_lb" {
  name = "production-lb"
  description = "Controls access to the ALB"
  vpc_id = aws_vpc.production.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
