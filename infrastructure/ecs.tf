resource "aws_ecs_cluster" "production" {
  name = "production"
}

resource "aws_ecs_task_definition" "production_backend_web" {
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512

  family = "backend-web"
  container_definitions = templatefile(
    "templates/backend_container.json.tpl",
    {
      region = var.region
      name = "production-backend-web"
      image = aws_ecr_repository.backend.repository_url
      command = ["gunicorn", "-w", "3", "-b", ":8000", "config.wsgi:application"]
      log_group = aws_cloudwatch_log_group.production_backend.name
      log_stream = aws_cloudwatch_log_stream.production_backend_web.name
    },
  )
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn = aws_iam_role.production_backend_task.arn
}

resource "aws_ecs_service" "production_backend_web" {
  name = "production-backend-web"
  cluster = aws_ecs_cluster.production.id
  task_definition = aws_ecs_task_definition.production_backend_web.arn
  desired_count = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent = 200
  launch_type = "FARGATE"
  scheduling_strategy = "REPLICA"

  load_balancer {
    target_group_arn = aws_lb_target_group.production_backend.arn
    container_name = "production-backend-web"
    container_port = 8000
  }

  network_configuration {
    security_groups = [aws_security_group.production_ecs_backend.id]
    subnets = [aws_subnet.production_private_1.id, aws_subnet.production_private_2.id]
    assign_public_ip = false
  }
}

resource "aws_security_group" "production_ecs_backend" {
  name = "production-ecs-backend"
  vpc_id = aws_vpc.production.id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = [aws_security_group.production_lb.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "production_backend_task" {
  name = "production-backend-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Effect = "Allow",
        Sid = ""
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "ecs-task-execution"

  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Action = "sts:AssumeRole",
          Principal = {
            Service = "ecs-tasks.amazonaws.com"
          },
          Effect = "Allow",
          Sid = ""
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "production_backend" {
  name = "production-backend"
  retention_in_days = var.ecs_prod_backend_retention_days
}

resource "aws_cloudwatch_log_stream" "production_backend_web" {
  name = "production-backend-web"
  log_group_name = aws_cloudwatch_log_group.production_backend.name
}