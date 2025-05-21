provider "aws" {
      region = "ap-southeast-1"
    }

    # IAM Policy for S3 Access
    resource "aws_iam_policy" "s3_access" {
      name        = "S3AccessForC2"
      description = "Allow full S3 access for C2 resources"
      policy      = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect   = "Allow"
            Action   = [
              "s3:GetObject",
              "s3:PutObject",
              "s3:ListBucket"
            ]
            Resource = [
              "arn:aws:s3:::redteam-artifacts",
              "arn:aws:s3:::redteam-artifacts/*"
            ]
          }
        ]
      })
    }

    # IAM Role for EC2
    resource "aws_iam_role" "ec2_s3_role" {
      name = "ec2-s3-access-role"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Principal = {
              Service = "ec2.amazonaws.com"
            }
            Action = "sts:AssumeRole"
          }
        ]
      })
    }

    # Attach Policy to Role
    resource "aws_iam_role_policy_attachment" "ec2_s3_attach" {
      role       = aws_iam_role.ec2_s3_role.name
      policy_arn = aws_iam_policy.s3_access.arn
    }

    # Instance Profile
    resource "aws_iam_instance_profile" "ec2_s3_profile" {
      name = "ec2-s3-access-profile"
      role = aws_iam_role.ec2_s3_role.name
    }

    # Team Server Instance
    resource "aws_instance" "team_server" {
      ami           = "ami-01938df366ac2d954" # Ubuntu 24.04 LTS
      instance_type = "t2.medium"
      key_name      = "redteam-key"
      security_groups = [aws_security_group.team_server_sg.name]
      iam_instance_profile = aws_iam_instance_profile.ec2_s3_profile.name

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
      iam_instance_profile = aws_iam_instance_profile.ec2_s3_profile.name

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