# ---------------------------------------------------------------------------
# One-tier deployment of the example voting app.
# ONE EC2 server in ONE public subnet. Terraform builds the network and the
# server; ansible.tf then runs Ansible, which installs Docker and deploys the
# app with Docker Compose and/or the Helm chart in helm/voting-app (k3s).
# ---------------------------------------------------------------------------
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

locals {
  name_prefix  = "${var.project_name}-${var.environment}"
  ssh_key_name = var.create_key_pair ? aws_key_pair.ssh[0].key_name : var.key_name

  use_compose = contains(["compose", "both"], var.deploy_method)
  use_k3s     = contains(["k3s", "both"], var.deploy_method)

  # Ports opened to the internet, depending on how the app is deployed.
  app_ports = {
    for name, port in {
      "compose-vote"   = var.vote_port
      "compose-result" = var.result_port
      "k3s-vote"       = var.k3s_vote_nodeport
      "k3s-result"     = var.k3s_result_nodeport
      "k3s-grafana"    = var.grafana_nodeport
    } : name => port if startswith(name, "compose") ? local.use_compose : local.use_k3s
  }

  # Own VPC (default) or the account's default VPC (use_default_vpc = true).
  vpc_id    = var.use_default_vpc ? data.aws_vpc.default[0].id : aws_vpc.main[0].id
  subnet_id = var.use_default_vpc ? data.aws_subnet.default[0].id : aws_subnet.public[0].id
}

data "aws_vpc" "default" {
  count   = var.use_default_vpc ? 1 : 0
  default = true
}

data "aws_subnet" "default" {
  count             = var.use_default_vpc ? 1 : 0
  vpc_id            = data.aws_vpc.default[0].id
  availability_zone = var.availability_zone
  default_for_az    = true
}

# ---------------------------------------------------------------------------
# Network: VPC, one public subnet, internet gateway, public route table
# ---------------------------------------------------------------------------
resource "aws_vpc" "main" {
  count                = var.use_default_vpc ? 0 : 1
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${local.name_prefix}-vpc" }
}

# The single server must be reachable from the internet, so its subnet hands out public IPs.
#trivy:ignore:AWS-0164
resource "aws_subnet" "public" {
  count                   = var.use_default_vpc ? 0 : 1
  vpc_id                  = aws_vpc.main[0].id
  availability_zone       = var.availability_zone
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  map_public_ip_on_launch = true

  tags = { Name = "${local.name_prefix}-public-subnet" }
}

resource "aws_internet_gateway" "igw" {
  count  = var.use_default_vpc ? 0 : 1
  vpc_id = aws_vpc.main[0].id

  tags = { Name = "${local.name_prefix}-igw" }
}

resource "aws_route_table" "public" {
  count  = var.use_default_vpc ? 0 : 1
  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }

  tags = { Name = "${local.name_prefix}-public-rt" }
}

resource "aws_route_table_association" "public" {
  count          = var.use_default_vpc ? 0 : 1
  subnet_id      = aws_subnet.public[0].id
  route_table_id = aws_route_table.public[0].id
}

# ---------------------------------------------------------------------------
# Security group: vote page, result page and SSH only.
# Redis (6379) and Postgres (5432) are never opened.
# ---------------------------------------------------------------------------
# Outbound traffic stays open: apt, Docker/GHCR image pulls and the k3s installer need it.
#trivy:ignore:AWS-0104
resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app-sg"
  description = "Voting app server: vote and result pages, SSH"
  vpc_id      = local.vpc_id

  dynamic "ingress" {
    for_each = local.app_ports
    content {
      description = "App port (${ingress.key})"
      protocol    = "tcp"
      from_port   = ingress.value
      to_port     = ingress.value
      cidr_blocks = var.app_allowed_cidrs
    }
  }

  dynamic "ingress" {
    for_each = length(var.ssh_allowed_cidrs) > 0 ? [1] : []
    content {
      description = "SSH from allowed CIDRs"
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      cidr_blocks = var.ssh_allowed_cidrs
    }
  }

  egress {
    description = "Outbound (apt, image pulls)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name_prefix}-app-sg" }
}

# ---------------------------------------------------------------------------
# SSH key pair (existing in AWS by default, or uploaded when create_key_pair)
# ---------------------------------------------------------------------------
resource "aws_key_pair" "ssh" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = var.key_name
  public_key = file(pathexpand(var.ssh_public_key_path))
}

# ---------------------------------------------------------------------------
# AMI + the single EC2 server + Elastic IP
# ---------------------------------------------------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = [var.ami_name_filter]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "voting_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = local.subnet_id
  vpc_security_group_ids = [aws_security_group.app.id]
  key_name               = local.ssh_key_name

  associate_public_ip_address = true

  metadata_options {
    http_tokens = "required" # IMDSv2
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = var.root_volume_size
  }

  # The server needs its route to the internet gateway before first boot.
  depends_on = [aws_route_table_association.public]

  tags = { Name = "${local.name_prefix}-voting-server" }
}

resource "aws_eip" "voting" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]

  tags = { Name = "${local.name_prefix}-eip" }
}

resource "aws_eip_association" "voting" {
  instance_id   = aws_instance.voting_server.id
  allocation_id = aws_eip.voting.id
}
