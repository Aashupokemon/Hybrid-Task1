provider "aws" {
  region   = "ap-south-1"
  profile  = "Ayush"
}

resource "aws_key_pair" "task1" {
  key_name   = "task1-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41"
}

resource "aws_security_group" "task1-securitygroup" {
  name        = "task1-securitygroup"
  description = "Allow SSH AND HTTP"
  vpc_id      = "vpc-25f4e94d"


  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "task1-securitygroup"
  }
}

resource "aws_s3_bucket" "task1ayush" {
    bucket = "task1-ayush"
    acl    = "public-read"

    tags = {
	Name    = "task1ayush"
	Environment = "Dev"
    }
    versioning {
	enabled =true
    }
}

resource "aws_cloudfront_distribution" "imgcloudfront" {
    origin {
        domain_name = "task1ayush.s3.amazonaws.com"
        origin_id = "S3-task1ayush" 


        custom_origin_config {
            http_port = 80
            https_port = 80
            origin_protocol_policy = "match-viewer"
            origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"] 
        }
    }
       
    enabled = true


    default_cache_behavior {
        allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = "S3-task1ayush"


        # Forward all query strings, cookies and headers
        forwarded_values {
            query_string = false
        
            cookies {
               forward = "none"
            }
        }
        viewer_protocol_policy = "allow-all"
        min_ttl = 0
        default_ttl = 3600
        max_ttl = 86400
    }
    # Restricts who is able to access this content
    restrictions {
        geo_restriction {
            # type of restriction, blacklist, whitelist or none
            restriction_type = "none"
        }
    }


    # SSL certificate for the service.
    viewer_certificate {
        cloudfront_default_certificate = true
    }
}

resource "aws_ebs_volume" "task1" {
  availability_zone = "ap-south-1a"
  size              = 1

  tags = {
    Name = "Task1"
  }
}

resource "aws_volume_attachment" "task1" {
 device_name = "/dev/sdf"
 volume_id = aws_ebs_volume.task1.id
 instance_id = aws_instance.task1.id
}

variable "task1-key"{
      type = string
      default = "task1-key"
}
  
resource "aws_instance" "task1" {
  ami           = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name      = var.task1-key
  security_groups = [ "task1-securitygroup" ]
  user_data = <<-EOF
                #! /bin/bash
                sudo yum install httpd -y
                sudo systemctl start httpd
                sudo systemctl enable httpd
                sudo yum install git -y
                mkfs.ext4 /dev/xvdf1
                mount /dev/xvdf1 /var/www/html
                
                git clone https://github.com/Aashupokemon/Hybrid-Task1
		cd Hybrid-Task1
		cp index.html /var/www/html
             

  EOF

  tags = {
    Name = "task1"
  }
}