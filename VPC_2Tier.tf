#create a VPC
resource "aws_vpc" "test_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
 
  tags = {
    Name = "test_vpc"
  }
}

#create a public and private subnet in 1 AZ 
resource "aws_subnet" "test_public_subnet1" {
  vpc_id     = aws_vpc.test_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "test_public_subnet"
  }
}
resource "aws_subnet" "test_private_subnet1" {
  vpc_id     = aws_vpc.test_vpc.id
  cidr_block = "10.0.1.0/24"
   availability_zone = "ap-south-1a"
  tags = {
    Name = "test_private_subnet"
  }
}

#create a public and private Subnet in another AZ
resource "aws_subnet" "test_public_subnet2" {
  vpc_id     = aws_vpc.test_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "test_public_subnet"
  }
}
resource "aws_subnet" "test_private_subnet2" {
  vpc_id     = aws_vpc.test_vpc.id
  cidr_block = "10.0.1.0/24"
   availability_zone = "ap-south-1b"
  tags = {
    Name = "test_private_subnet"
  }
}

# launch an ec2 instance in private subnet of us-east-1a
resource "aws_instance" "instance1" {
  ami           = "ami-03d500615acf7869a"
  instance_type = "t2.micro"               
  key_name      = "DemoUser1_KeyPair"
  subnet_id     = aws_subnet.test_private_subnet1.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  tags = {
    Name = "Private 1a"
  }
}

# launch an ec2 instance in private subnet of us-east-1b
resource "aws_instance" "instance2" {
  ami           = "ami-03d500615acf7869a"
  instance_type = "t2.micro"               
  key_name      = "DemoUser1_KeyPair"
  subnet_id     = aws_subnet.test_private_subnet2.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id,aws_security_group.allow_all.id]
  tags = {
    Name = "Private 1b"
  }
}

#Creating Security Groups
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.test_vpc.id
 
  tags = {
    Name = "allow_tls"
  }
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.test_vpc.id
 
  tags = {
    Name = "allow_all"
  }
}

#assigning ingress rules for "allow tls" security group
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  #cidr_ipv4         = aws_vpc.main.cidr_block
  cidr_ipv4         = "0.0.0.0/0"
  #from_port         = 443
  ip_protocol       = "-1"
  #to_port           = 443
}
 
resource "aws_vpc_security_group_ingress_rule" "allows_RDP" {
  security_group_id = aws_security_group.allow_tls.id  
  #cidr_ipv4         = aws_vpc.main.cidr_block
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3389
  ip_protocol       = "tcp"
  to_port           = 3389
}

# creating an ALB in Public Subnet 1

 