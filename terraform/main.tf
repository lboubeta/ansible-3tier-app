provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "three_tier_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "three-tier-vpc"
  }
}

# Create private subnets
resource "aws_subnet" "lb_tier_subnet" {
  vpc_id = aws_vpc.three_tier_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "lb-tier-subnet"
  }
}

resource "aws_subnet" "app_tier_subnet" {
  vpc_id = aws_vpc.three_tier_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "app-tier-subnet"
  }
}

resource "aws_subnet" "db_tier_subnet" {
  vpc_id = aws_vpc.three_tier_vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "db-tier-subnet"
  }
}

# Create security groups
resource "aws_security_group" "lb_tier_sg" {
  name_prefix = "lb-tier-sg-"
  vpc_id = aws_vpc.three_tier_vpc.id

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

resource "aws_security_group" "app_tier_sg" {
  name_prefix = "app-tier-sg-"
  vpc_id = aws_vpc.three_tier_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.lb_tier_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_tier_sg" {
  name_prefix = "db-tier-sg-"
  vpc_id = aws_vpc.three_tier_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.app_tier_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create instances
resource "aws_instance" "lb_tier_instance" {
  ami           = "ami-026ebd4cfe2c043b2"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.lb_tier_subnet.id
  vpc_security_group_ids = [aws_security_group.lb_tier_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "lb-tier-instance"
  }
}

resource "aws_instance" "app_tier_instance" {
  ami           = "ami-026ebd4cfe2c043b2"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.app_tier_subnet.id
  vpc_security_group_ids = [aws_security_group.app_tier_sg.id]

  tags = {
    Name = "app-tier-instance"
  }
}

resource "aws_instance" "db_tier_instance" {
  ami           = "ami-026ebd4cfe2c043b2"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.db_tier_subnet.id
  vpc_security_group_ids = [aws_security_group.db_tier_sg.id]

  tags = {
    Name = "db-tier-instance"
  }
}
