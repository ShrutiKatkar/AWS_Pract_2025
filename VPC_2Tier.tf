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
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "test_public_subnet_A"
  }
}
resource "aws_subnet" "test_private_subnet1" {
  vpc_id     = aws_vpc.test_vpc.id
  cidr_block = "10.0.2.0/24"
   availability_zone = "ap-south-1a"
  tags = {
    Name = "test_private_subnet_A"
  }
}

#create a public and private Subnet in another AZ
resource "aws_subnet" "test_public_subnet2" {
  vpc_id     = aws_vpc.test_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "Test_public_subnet_B"
  }
}
resource "aws_subnet" "test_private_subnet2" {
  vpc_id     = aws_vpc.test_vpc.id
  cidr_block = "10.0.4.0/24"
   availability_zone = "ap-south-1b"
  tags = {
    Name = "test_private_subnet_B"
  }
}

# Creating Route tables for Public Subnets
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# associating route table with Public subnet 1
resource "aws_route_table_association" "publicA" {
  subnet_id      = aws_subnet.test_public_subnet1.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "publicB" {
  subnet_id      = aws_subnet.test_public_subnet2.id
  route_table_id = aws_route_table.public_route.id
}

# Creating Route tables for Private Subnets
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.test_vpc.id

  # route {
  #   cidr_block = "0.0.0.0/0"
  #   nat_gateway_id = aws_nat_gateway.nat1.id
  # }
}

# associating route table with Public subnet 1
resource "aws_route_table_association" "privateA" {
  subnet_id      = aws_subnet.test_private_subnet1.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route_table_association" "PrivateB" {
  subnet_id      = aws_subnet.test_private_subnet2.id
  route_table_id = aws_route_table.private_route.id
}

# launch an ec2 instance in private subnet of us-east-1a
resource "aws_instance" "instance1" {
  ami           = "ami-03d500615acf7869a"
  instance_type = "t2.micro"               
  key_name      = "DemoUser1_KeyPair"
  subnet_id     = aws_subnet.test_private_subnet1.id
  vpc_security_group_ids = [aws_security_group.allow_ec2.id]
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
  vpc_security_group_ids = [aws_security_group.allow_ec2.id]
  tags = {
    Name = "Private 1b"
  }
}

#Creating Security Groups for EC2
resource "aws_security_group" "allow_ec2" {
  name        = "allow_ec2"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.test_vpc.id
 
  tags = {
    Name = "allow_ec2_tls"
  }
}

#assigning ingress rules for "allow tls" security group
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_ec2.id
  #cidr_ipv4         = aws_vpc.main.cidr_block
  cidr_ipv4         = "0.0.0.0/0"
  #from_port         = 443
  ip_protocol       = "-1"
  #to_port           = 443
}
 
resource "aws_vpc_security_group_ingress_rule" "allows_RDP" {
  security_group_id = aws_security_group.allow_ec2.id 
  #cidr_ipv4         = aws_vpc.main.cidr_block
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allows_HttpEC2" {
  security_group_id = aws_security_group.allow_ec2.id 
  #cidr_ipv4         = aws_vpc.main.cidr_block
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "TCP"
  to_port           = 80
}

# creating security group for ALB
resource "aws_security_group" "allow_ALB" {
  name        = "allow_all"
  description = "Allow ALL inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.test_vpc.id
 
  tags = {
    Name = "allow_all"
  }
}

#assigning ingress rules for allow_all security group
resource "aws_vpc_security_group_ingress_rule" "allows_HttpALB" {
  security_group_id = aws_security_group.allow_ALB.id
  #cidr_ipv4         = aws_vpc.main.cidr_block
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "TCP"
  to_port           = 80
}

#creating Inetrnet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.test_vpc.id

  tags = {
    Name = "Test_IGW"
  }
}

# creating an ALB in Public Subnet 1
resource "aws_lb" "ALB1" {
  name               = "test1-lb-tf"
  #internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_ALB.id]
  subnets            = [aws_subnet.test_public_subnet1.id,aws_subnet.test_public_subnet2.id]
  #subnets            = [for subnet in aws_subnet.public : subnet.id]


  enable_deletion_protection = false
}

#Creating Target groups
resource "aws_lb_target_group" "test_targetgroup" {
  name     = "tf-test-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.test_vpc.id
}

#creating Listener in ALB
resource "aws_lb_listener" "listener_front_end" {
  load_balancer_arn = aws_lb.ALB1.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test_targetgroup.arn
  }
}

#attaching instances to Target Group
resource "aws_lb_target_group_attachment" "test_attachment1" {
  target_group_arn = aws_lb_target_group.test_targetgroup.arn
  target_id        = aws_instance.instance1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "test_attachment2" {
  target_group_arn = aws_lb_target_group.test_targetgroup.arn
  target_id        = aws_instance.instance2.id
  port             = 80
}

# #creating an elastic ip for NAT gateway
#  resource "aws_eip" "nat_eip1" {
# #   instance = aws_instance.instance1.id
# #   #domain   = "vpc"
#  }
#  resource "aws_eip" "nat_eip2" {
# #   instance = aws_instance.instance2.id
# #   #domain   = "vpc"
#  }


# #creating a NAT Gateway
# resource "aws_nat_gateway" "nat1" {
#   allocation_id = aws_eip.nat_eip1.id
#   subnet_id     = aws_subnet.test_public_subnet1.id

#   tags = {
#     Name = "NAT gw1"
#   }
# }

# resource "aws_nat_gateway" "nat2" {
#   allocation_id = aws_eip.nat_eip2.id
#   subnet_id     = aws_subnet.test_public_subnet1.id

#   tags = {
#     Name = "NAT gw2"
#   }
# }

