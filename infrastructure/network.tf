resource "aws_vpc" "production" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "production_public_1" {
  vpc_id = aws_vpc.production.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.availability_zones[0]
  tags = {
    Name = "production-public-1"
  }
}

resource "aws_subnet" "production_public_2" {
  vpc_id = aws_vpc.production.id
  cidr_block = "10.0.2.0/24"
  availability_zone = var.availability_zones[1]
  tags = {
    Name = "production-public-2"
  }
}

resource "aws_subnet" "production_private_1" {
  vpc_id = aws_vpc.production.id
  cidr_block = "10.0.3.0/24"
  availability_zone = var.availability_zones[0]
  tags = {
    Name = "production-private-1"
  }
}

resource "aws_subnet" "production_private_2" {
  vpc_id = aws_vpc.production.id
  cidr_block = "10.0.4.0/24"
  availability_zone = var.availability_zones[1]
  tags = {
    Name = "production-private-2"
  }
}

resource "aws_route_table" "production_public" {
  vpc_id = aws_vpc.production.id
}

resource "aws_route_table_association" "production_public_1" {
  route_table_id = aws_route_table.production_public.id
  subnet_id = aws_subnet.production_public_1.id
}

resource "aws_route_table_association" "production_public_2" {
  route_table_id = aws_route_table.production_public.id
  subnet_id = aws_subnet.production_public_2.id
}

resource "aws_route_table" "production_private" {
  vpc_id = aws_vpc.production.id
}

resource "aws_route_table_association" "production_private_1" {
  route_table_id = aws_route_table.production_private.id
  subnet_id = aws_subnet.production_private_1.id
}

resource "aws_route_table_association" "production_private_2" {
  route_table_id = aws_route_table.production_private.id
  subnet_id = aws_subnet.production_private_2.id
}

resource "aws_internet_gateway" "production" {
  vpc_id = aws_vpc.production.id
}

resource "aws_route" "production_internet_gateway" {
  route_table_id = aws_route_table.production_public.id
  gateway_id = aws_internet_gateway.production.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_eip" "production_nat_gateway" {
  vpc = true
  associate_with_private_ip = "10.0.0.5"
  depends_on = [aws_internet_gateway.production]
}

resource "aws_nat_gateway" "production" {
  subnet_id = aws_subnet.production_public_1.id
  allocation_id = aws_eip.production_nat_gateway.id
}

resource "aws_route" "production_nat_gateway" {
  route_table_id = aws_route_table.production_private.id
  nat_gateway_id = aws_nat_gateway.production.id
  destination_cidr_block = "0.0.0.0/0"
}
