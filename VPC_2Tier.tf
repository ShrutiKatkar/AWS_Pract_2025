#create a VPC
resource "aws_vpc" "test_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
 
  tags = {
    Name = "test_vpc"
  }
}

#create a public and privatee subnet in 1 AZ 
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
  tags = {
    Name = "Private 1b"
  }
}
 