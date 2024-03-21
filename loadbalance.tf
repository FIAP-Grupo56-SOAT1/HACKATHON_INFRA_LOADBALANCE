##### Creating a VPC #####
# Provide a reference to your default VPC
resource "aws_default_vpc" "default_vpc" {
}

# Provide references to your default subnets
resource "aws_default_subnet" "default_subnet_a" {
  # Use your own region here but reference to subnet 1a
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  # Use your own region here but reference to subnet 1b
  availability_zone = "us-east-1b"
}

#resource "aws_default_subnet" "default_subnet_c" {
#  # Use your own region here but reference to subnet 1b
#  availability_zone = "us-east-1c"
#}


##### Implement a Load Balancer #####
resource "aws_alb" "application_load_balancer_hackathon" {
  name               = "load-balancer-${var.micro_servico}" #load balancer name
  load_balancer_type = "application"
  subnets = [ # Referencing the default subnets
    aws_default_subnet.default_subnet_a.id,
    aws_default_subnet.default_subnet_b.id,
    #aws_default_subnet.default_subnet_c.id
  ]
  # security group
  security_groups = [aws_security_group.load_balancer_security_group_hackathon.id]
}

##### Creating a Security Group for the Load Balancer #####
# Create a security group for the load balancer:
resource "aws_security_group" "load_balancer_security_group_hackathon" {
  vpc_id      = aws_default_vpc.default_vpc.id
  name = "load-balancer-security-group-${var.micro_servico}"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic in from all sources
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "service_security_group_hackathon" {
  name = "service-security-group-${var.micro_servico}"
  vpc_id = aws_default_vpc.default_vpc.id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = [aws_security_group.load_balancer_security_group_hackathon.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#CONFIGURAÇÃO DO BANCO DE DADOS
resource "aws_security_group" "service_ecs_security_group_db_hackathon" {
  vpc_id = aws_default_vpc.default_vpc.id
  name = "security-group-db-${var.micro_servico}"
  ingress {
    protocol        = "tcp"
    from_port       = var.containerDbPort
    to_port         = var.containerDbPort
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.load_balancer_security_group_hackathon.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.service_security_group_hackathon.id]
  }
}

#Log the load balancer app URL
output "app_url" {
  value = aws_alb.application_load_balancer_hackathon.dns_name
}


