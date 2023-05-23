provider "aws" {
  region = "us-east-1" # Escolha a região da AWS que deseja usar
}

# Crie um VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "example-vpc"
  }
}

# Crie uma sub-rede
resource "aws_subnet" "example" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a" # Certifique-se de que esta zona de disponibilidade corresponda à região escolhida
  map_public_ip_on_launch = true

  tags = {
    Name = "example-subnet"
  }
}

# Crie uma sub-rede
resource "aws_subnet" "example2" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b" # Certifique-se de que esta zona de disponibilidade corresponda à região escolhida
  map_public_ip_on_launch = true

  tags = {
    Name = "example-subnet"
  }
}

# Crie um Security Group
resource "aws_security_group" "example" {
  name        = "example"
  description = "Example security group for ECS service"
  vpc_id      = aws_vpc.example.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb_sg" {
  name        = "elb_sg"
  description = "Allow inbound traffic from the internet and outbound traffic to the ECS tasks"
  vpc_id      = aws_vpc.example.id

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

  tags = {
    Name = "elb_sg"
  }
}


# Crie uma chave KMS
resource "aws_kms_key" "example" {
  description = "Example KMS key for secret encryption"
}

# Crie um segredo no AWS Secrets Manager
resource "aws_secretsmanager_secret" "example" {
  name       = "example-16-pwetty-please"
  kms_key_id = aws_kms_key.example.id
}

resource "aws_secretsmanager_secret_version" "example" {
  secret_id = aws_secretsmanager_secret.example.id

  secret_string = file("secrets.json")
}

resource "aws_secretsmanager_secret_policy" "example" {
  secret_arn = aws_secretsmanager_secret.example.arn
  policy     = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAccessToSecret",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.example.arn}"
      },
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "${aws_secretsmanager_secret.example.arn}"
    }
  ]
}
POLICY
}


# Crie uma Role para a tarefa do ECS
resource "aws_iam_role" "example" {
  name = "example-ecs-task-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Crie uma política para a Role
resource "aws_iam_policy" "example" {
  name        = "example-ecs-task-policy"
  description = "Example policy for accessing secret from ECS Fargate"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.example.arn
      },
      {
        Action = [
          "kms:Decrypt"
        ]
        Effect   = "Allow"
        Resource = aws_kms_key.example.arn
      }
    ]
  })
}

# resource "aws_iam_policy" "example" {
#   name        = "example-ecs-task-policy"
#   description = "Example policy that allows all actions on all resources"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action   = "*"
#         Effect   = "Allow"
#         Resource = "*"
#       }
#     ]
#   })
# }


# Associe a política à Role
resource "aws_iam_role_policy_attachment" "example" {
  policy_arn = aws_iam_policy.example.arn
  role       = aws_iam_role.example.name
}

# Crie um cluster do ECS
resource "aws_ecs_cluster" "example" {
  name = "example-cluster"
}

# Crie a definição da tarefa do ECS Fargate
resource "aws_ecs_task_definition" "example" {
  family                   = "example"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.example.arn
  task_role_arn            = aws_iam_role.example.arn

  container_definitions = <<DEFINITION
  [
    {
      "name": "example-container",
      "image": "r2909/my_hello_world",
      "cpu": 256,
      "memory": 512,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ],
      "secrets": [
        {
          "name": "EXAMPLE_SECRET_USERNAME",
          "valueFrom": "${aws_secretsmanager_secret.example.arn}"
        },
        {
          "name": "EXAMPLE_SECRET_PASSWORD",
          "valueFrom": "${aws_secretsmanager_secret.example.arn}"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/example",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
  DEFINITION
}

resource "aws_cloudwatch_log_group" "example" {
  name = "/ecs/example"
}


resource "aws_security_group" "ecs_tasks_sg" {
  name        = "ecs_tasks_sg"
  description = "Allow inbound traffic from the load balancer and outbound traffic to the internet"
  vpc_id      = aws_vpc.example.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.elb_sg.id] # assuming this is your ELB security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs_tasks_sg"
  }
}



# Crie um serviço do ECS
resource "aws_ecs_service" "example" {
  name            = "example-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn
  launch_type     = "FARGATE"

  desired_count = 1

  network_configuration {
    subnets          = [aws_subnet.example.id, aws_subnet.example2.id]
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.example.arn
    container_name   = "example-container"
    container_port   = 80
  }
}

# Crie um Load Balancer
resource "aws_lb" "example" {
  name               = "example-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb_sg.id]
  subnets            = [aws_subnet.example.id, aws_subnet.example2.id]
}

resource "aws_lb_target_group" "example" {
  name     = "example-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.example.id

  deregistration_delay = 300

  target_type = "ip"

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 5
    timeout             = 3
    interval            = 30
    path                = "/"
    matcher             = "200-399"
  }
}


resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }
}

resource "aws_main_route_table_association" "example" {
  vpc_id         = aws_vpc.example.id
  route_table_id = aws_route_table.example.id
}

output "elb_public_ip" {
  value       = aws_lb.example.dns_name
  description = "Public DNS name of the Load Balancer"
}
