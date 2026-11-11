terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = "ap-southeast-2"
  profile = "default"
  default_tags {
    tags = {
      Project = "detection-lab"
      Tool    = "terraform"
    }
  }
}
# ==============================================================================
# 01. VPC and Subnets
# ==============================================================================
resource "aws_vpc" "vpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "dl-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "pub_subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "dl-public-subnet-01"
  }
}
resource "aws_subnet" "pub_subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.168.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "dl-public-subnet-02"
  }
}
resource "aws_subnet" "pri_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "192.168.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "dl-private-subnet-01"
  }
}
# ==============================================================================
# 02. Gateway
# ==============================================================================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "dl-igw"
  }
}
# ==============================================================================
# 03. EIP
# ==============================================================================
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "dl-nat-eip"
  }
}
resource "aws_eip" "nlb_eip" {
  domain = "vpc"
  tags = {
    Name = "dl-nlb-eip"
  }
}
# ==============================================================================
# 04. NAT Gateway
# ==============================================================================
resource "aws_nat_gateway" "nat" {
  allocation_id     = aws_eip.nat_eip.id
  subnet_id         = aws_subnet.pub_subnet_1.id
  connectivity_type = "public"
  availability_mode = "zonal"
  tags = {
    Name = "dl-nat-gateway"
  }
  depends_on = [aws_internet_gateway.igw]
}
# ==============================================================================
# 04. Route Tables - Both private and public
# ==============================================================================
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "dl-public-rt"
  }
}
resource "aws_route" "access_to_public" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
resource "aws_route_table_association" "pub_rou_tab_ass_1" {
  subnet_id      = aws_subnet.pub_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "pub_rou_tab_ass_2" {
  subnet_id      = aws_subnet.pub_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}
# ==============================================================================
resource "aws_route_table" "privat_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "dl-private-rt"
  }
}
resource "aws_route" "access_to_private" {
  route_table_id         = aws_route_table.privat_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
resource "aws_route_table_association" "pri_rou_tab_ass_1" {
  subnet_id      = aws_subnet.pri_subnet_1.id
  route_table_id = aws_route_table.privat_rt.id
}