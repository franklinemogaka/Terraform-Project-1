provider "aws" {
  region = "us-east-1"
  access_key = "AKIAVSU3ITXLL6RF3WM7"
  secret_key = "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"

}
#create VPC
resource "aws_vpc" "prod_vpc" {
  cidr_block = "10.0.0.0/16"
  tags ={
    name ="production"
  }
}

#create internet Gateway
resource "aws_internet_gateway" "prod_gateway" {
  vpc_id = aws_vpc.prod_vpc.id

}

#create custom Route Table
resource "aws_route_table" "prod_route_table" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
#set the a default route by using 0.0.0.0/0 meaning it will send all traffic whenever this route points   
    gateway_id = aws_internet_gateway.prod_gateway.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.prod_gateway.id
  }

  tags = {
    Name = "prod"
  }
}



#create a subnet
resource "aws_subnet" "prod_subnet" {
  vpc_id     = aws_vpc.prod_vpc.id
  cidr_block = "10.0.1.0/24"

#add Availability Zone
# availability_zone ="us_east_1a"
  tags = {
    Name = "my_subnet"
  }
}

#associate subnet with Route table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.prod_subnet.id
  route_table_id = aws_route_table.prod_route_table.id
}

#create security Group to allow port 22,80,44
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]


  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}


#create a network interface with an ip in the subnet that was created in step 4

resource "aws_network_interface" "web_server_nic" {
  subnet_id       = aws_subnet.prod_subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}
# assign an elastic ip to the network interface created in step 7
resource "aws_eip" "one" {
  vpc                    = true
  network_interface         = aws_network_interface.web_server_nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.prod_gateway]
}

#create ubuntu server and install/enable apache2
resource "aws_instance" "web_server_instance"{
ami = "ami-0261755bbcb8c4a84"
instance_type = "t2.micro"
# availability_zone = "us_east_1a"
key_name = "main-key"

network_interface{
    device_index =0
    network_interface_id = aws_network_interface.web_server_nic.id
}
}

# user_data = <<-EOF
#               #!/bin/bash
#               echo "Hello, World!" > /tmp/hello.txt
#               sudo apt update -y
#               sudo apt install apache2 -y
#               sudo systemct1 start apache2
#               sudo bash -c 'echo your very first web server > /var/www/html/index.html'
#             EOF
            
#  tags ={
#     name ="web-server"
#   }

