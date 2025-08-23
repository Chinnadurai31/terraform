provider "aws" {
    region = var.region
}

resource "aws_vpc" "test_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true   
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.test_vpc.id
    count = length(var.public_subnet_cidrs)
    cidr_block = var.public_subnet_cidrs[count.index]
    map_public_ip_on_launch = true
    availability_zone = element(var.availability_zones, count.index)
}

resource "aws_subnet" "private_subnet" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.test_vpc.id
    cidr_block = var.private_subnet_cidrs[count.index]
    map_public_ip_on_launch = false
    availability_zone = element(var.availability_zones, count.index)
}
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.test_vpc.id
    
}
resource "aws_eip" "nat_eip" {
    depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gw" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id = aws_subnet.public_subnet[0].id
    tags = {
        Name = "test_nat_gw"
    }
    depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.test_vpc.id
}

resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.test_vpc.id
}

resource "aws_route" "public_route" {
    route_table_id = aws_route_table.public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route" "private_route" {
    route_table_id = aws_route_table.private_rt.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "public_rt_assoc" {
    count = length(var.public_subnet_cidrs)
    subnet_id = aws_subnet.public_subnet[count.index].id
    route_table_id = aws_route_table.public_rt.id
} 

resource "aws_route_table_association" "private_rt_assoc" {
    count = length(var.private_subnet_cidrs)
    subnet_id = aws_subnet.private_subnet[count.index].id
    route_table_id = aws_route_table.private_rt.id
}

