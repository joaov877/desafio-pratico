terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  s3_use_path_style = true

  endpoints {
    ec2 = "http://localhost:4566"
    s3  = "http://localhost:4566"
  }
}

resource "aws_vpc" "ecommerce" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "ecommerce-vpc"
    Project = "desafio-devops"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.ecommerce.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name    = "ecommerce-public-subnet"
    Project = "desafio-devops"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.ecommerce.id

  tags = {
    Name    = "ecommerce-internet-gateway"
    Project = "desafio-devops"
  }
}

# Tabela de rotas
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ecommerce.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name    = "ecommerce-public-route-table"
    Project = "desafio-devops"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "api" {
  name        = "ecommerce-api-security-group"
  description = "Permite acesso a API na porta 3000"
  vpc_id      = aws_vpc.ecommerce.id

  ingress {
    description = "Acesso HTTP para a API"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "ecommerce-api-security-group"
    Project = "desafio-devops"
  }
}

resource "aws_instance" "api" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.api.id
  ]

  tags = {
    Name    = "ecommerce-api"
    Project = "desafio-devops"
  }
}

resource "aws_s3_bucket" "assets" {
  bucket = "ecommerce-devops-assets"

  tags = {
    Name    = "ecommerce-assets"
    Project = "desafio-devops"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.ecommerce.id
}

output "instance_id" {
  description = "ID da instância EC2 simulada"
  value       = aws_instance.api.id
}

output "bucket_name" {
  description = "Nome do bucket S3"
  value       = aws_s3_bucket.assets.bucket
}