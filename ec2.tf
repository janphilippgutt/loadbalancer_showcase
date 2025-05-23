# Using the latest amazon_linux_2 AMI

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazon's official AWS AMI account
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
