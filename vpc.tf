# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "pvt_subnet" {
  vpc_id                  = "${aws_vpc.my_vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "private_subnet1"
  }
}

resource "aws_subnet" "pub_subnet" {
  vpc_id                  = "${aws_vpc.my_vpc.id}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "public_subnet1"
  }
}

resource "aws_eip" "gw_eip" {
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.gw_eip.id}"
  subnet_id     = "${aws_subnet.pub_subnet.id}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.my_vpc.id}"

  tags = {
    Name = "my_vpc_ig"
  }
}


resource "aws_route_table" "public_routetable" {
  vpc_id = "${aws_vpc.my_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "private_routetable" {
  vpc_id = "${aws_vpc.my_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
  }

  tags = {
    Name = "main"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${aws_subnet.pvt_subnet.id}"
  route_table_id = "${aws_route_table.private_routetable.id}"
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.pub_subnet.id}"
  route_table_id = "${aws_route_table.public_routetable.id}"
}