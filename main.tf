provider "aws" {
      region = "ap-southeast-1"
    }

    # Team Server Instance
    resource "aws_instance" "team_server" {
      ami           = "ami-01938df366ac2d954" # Ubuntu 24.04 LTS
      instance_type = "t2.medium"
      key_name      = "redteam-key"
      security_groups = [aws_security_group.team_server_sg.name]

      tags = {
        Name = "CobaltStrike-TeamServer"
      }
    }

    # Redirector Instances
    resource "aws_instance" "redirector" {
      count         = 2
      ami           = "ami-01938df366ac2d954"
      instance_type = "t2.micro"
      key_name      = "redteam-key"
      security_groups = [aws_security_group.redirector_sg.name]

      tags = {
        Name = "Redirector-${count.index}"
      }
    }

    # Security Group for Team Server
    resource "aws_security_group" "team_server_sg" {
      name        = "team-server-sg"
      description = "Allow redirector traffic"

      ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = [
          "${aws_instance.redirector[0].private_ip}/32",
          "${aws_instance.redirector[1].private_ip}/32"
        ]
      }

      ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = [
          "${aws_instance.redirector[0].private_ip}/32",
          "${aws_instance.redirector[1].private_ip}/32"
        ]
      }

      egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }

    # Security Group for Redirectors
    resource "aws_security_group" "redirector_sg" {
      name        = "redirector-sg"
      description = "Allow HTTP/HTTPS traffic"

      ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

      ingress {
        from_port   = 443
        to_port     = 443
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

    # Output Team Server IP
    output "team_server_ip" {
      value = aws_instance.team_server.public_ip
    }

    # Output Redirector IPs
    output "redirector_ips" {
      value = aws_instance.redirector[*].public_ip
    }