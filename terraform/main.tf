variable "aws_region" {
  default = "us-north-1"
}

variable "ecr_image_uri" {
  description = "ECR image URI for the web app"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "web_app" {
  ami           = "ami-0c55b159cbfafe1f0" # Ubuntu 20.04 LTS
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnet.default.id

  vpc_security_group_ids = [aws_security_group.web_app.id]
  key_name               = "web-app-key"

  user_data = <<-EOF
              #!/bin/bash
              mkdir -p /home/ubuntu/app
              EOF

  tags = {
    Name = "WebAppInstance"
  }
}

resource "aws_security_group" "web_app" {
  name        = "web-app-sg"
  description = "Allow web and SSH traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "${var.aws_region}a"
  default_for_az    = true
}

output "instance_public_ip" {
  value = aws_instance.web_app.public_ip
}
