terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}
provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "lb-showcase-vpc"
  }
}

resource "aws_subnet" "subnet_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"
  map_public_ip_on_launch = true  # makes sure EC2 instances get public IPs

  tags = {
    Name = "subnet-1"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

# route table defines how traffic leaves or enters subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  # This allows for public subnets
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# A Route Table must be associated with a subnet to take effect
# subnet_1 : follow the instructions in route table public_rt !
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}
# subnet_2 : follow the instructions in route table public_rt !
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP"
  vpc_id      = aws_vpc.main_vpc.id

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
    Name = "web-sg"
  }
}



resource "aws_instance" "web1" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_1.id
  security_groups = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              amazon-linux-extras install -y nginx1
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Web Server 1 - AZ1</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "web1"
  }
}

resource "aws_instance" "web2" {
  ami           = data.aws_ami.amazon_linux_2.id # Alternative: "ami-0071fbe485985432e"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_2.id
  security_groups = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              amazon-linux-extras install -y nginx1
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Web Server 2 - AZ2</h1>" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name = "web2"
  }
}

resource "aws_lb" "app_lb" {
  name               = "lb-showcase"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [
    aws_subnet.subnet_1.id,
    aws_subnet.subnet_2.id
  ]

  tags = {
    Name = "app-lb"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  #  ensure only healthy EC2s receive traffic
  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "web-tg"
  }
}

# Register the EC2s whith the Target Group:

resource "aws_lb_target_group_attachment" "web1" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web2" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web2.id
  port             = 80
}

# Listener forwards traffic to our target group (which contains our EC2s)

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}
