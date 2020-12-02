resource "aws_vpc" "terra_vpc" {

  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames="true"
  
}
resource "aws_subnet" "terra_public_sub1" {

  vpc_id     = aws_vpc.terra_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone="us-east-1a"
  map_public_ip_on_launch="true"

}

resource "aws_subnet" "terra_private_sub2" {

  vpc_id     = aws_vpc.terra_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone="us-east-1b"
  map_public_ip_on_launch="true"
}

resource "aws_internet_gateway" "terra_igw" {
  vpc_id = "${aws_vpc.terra_vpc.id}"
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "terra_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.terra_public_sub1.id
}

resource "aws_route_table" "terra_public_rt1" {
  vpc_id = "${aws_vpc.terra_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.terra_igw.id}"
  }
}

resource "aws_route_table_association" "a" {
  route_table_id = "${aws_route_table.terra_public_rt1.id}"
  subnet_id      = "${aws_subnet.terra_public_sub1.id}"
}

resource "aws_route_table" "terra_private_rt2" {
  vpc_id = "${aws_vpc.terra_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.terra_gw.id}"
  }
}

resource "aws_route_table_association" "b" {
  route_table_id = "${aws_route_table.terra_private_rt2.id}"
  subnet_id      = "${aws_subnet.terra_private_sub2.id}"
}

resource "aws_security_group" "terra_sg" {
  name        = "security group"
  description = "Allow http inbound traffic"
  vpc_id      = "${aws_vpc.terra_vpc.id}"
  
}

resource "aws_instance" "webservers" {
        count="2"
	ami = "ami-096fda3c22c1c990a"
	instance_type = "t2.micro"
	subnet_id = "${aws_subnet.terra_public_sub1.id}"
}
