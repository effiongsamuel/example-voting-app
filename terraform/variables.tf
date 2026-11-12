# ---------------------------------------------------------------------------
# General
# ---------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Short project name, used as a prefix for resource names."
  type        = string
  default     = "voting-app"
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

# ---------------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "use_default_vpc" {
  description = "true: run in the account's default VPC and a default subnet (no VPC, gateway or route table is created). false: build a dedicated VPC."
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "Availability zone for the public subnet and the server."
  type        = string
  default     = "eu-north-1a"
}

variable "app_allowed_cidrs" {
  description = "CIDRs allowed to open the vote and result pages."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs allowed to SSH to the server. GitHub Actions needs SSH too, so keep 0.0.0.0/0 while the pipeline deploys."
  type        = list(string)
  default     = []
}

# ---------------------------------------------------------------------------
# How the app is deployed
# ---------------------------------------------------------------------------
variable "deploy_method" {
  description = "compose = Docker Compose, k3s = the Helm chart in helm/voting-app on k3s, both = both side by side."
  type        = string
  default     = "compose"

  validation {
    condition     = contains(["compose", "k3s", "both"], var.deploy_method)
    error_message = "deploy_method must be compose, k3s or both."
  }
}

variable "grafana_nodeport" {
  description = "k3s: NodePort of Grafana (monitoring in the Helm chart). Passed to the chart as monitoring.grafana.service.nodePort."
  type        = number
  default     = 31002
}

variable "vote_port" {
  description = "Docker Compose: host port of the vote page."
  type        = number
  default     = 8080
}

variable "result_port" {
  description = "Docker Compose: host port of the result page."
  type        = number
  default     = 8081
}

variable "k3s_vote_nodeport" {
  description = "k3s: NodePort of the vote service. Passed to the chart as vote.service.nodePort."
  type        = number
  default     = 31000
}

variable "k3s_result_nodeport" {
  description = "k3s: NodePort of the result service. Passed to the chart as result.service.nodePort."
  type        = number
  default     = 31001
}

variable "github_owner" {
  description = "GitHub user or organisation whose GHCR packages hold the images built by .github/workflows/ci-cd.yml."
  type        = string

  validation {
    condition     = var.github_owner != "" && var.github_owner != "CHANGE_ME"
    error_message = "Set github_owner in terraform.tfvars to your GitHub user or organisation name."
  }
}

variable "image_tag" {
  description = "Image tag used for the first deployment (CI later deploys the commit SHA)."
  type        = string
  default     = "latest"
}

variable "vote_image" {
  description = "Docker Compose: full vote image reference. Empty = ghcr.io/<github_owner>/example-voting-app-vote:<image_tag>."
  type        = string
  default     = ""
}

variable "result_image" {
  description = "Docker Compose: full result image reference. Empty = the GHCR image built by CI."
  type        = string
  default     = ""
}

variable "worker_image" {
  description = "Docker Compose: full worker image reference. Empty = the GHCR image built by CI."
  type        = string
  default     = ""
}

variable "run_ansible" {
  description = "Run the Ansible playbook automatically once the server exists."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# Compute
# ---------------------------------------------------------------------------
variable "ami_name_filter" {
  description = "Name filter for the Canonical Ubuntu AMI."
  type        = string
  # default     = "ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-*"
  default = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
}

variable "instance_type" {
  description = "Instance type for the single server (2 vCPU / 4 GB RAM or more)."
  type        = string
  default     = "m7i-flex.large"
}

variable "root_volume_size" {
  description = "Root EBS volume size (GiB). Holds Docker images, k3s and the Postgres data."
  type        = number
  default     = 100
}

# ---------------------------------------------------------------------------
# SSH key
# ---------------------------------------------------------------------------
variable "key_name" {
  description = "EC2 key pair name (without .pem): an existing one, or the name to create when create_key_pair = true."
  type        = string
  default     = "devop-aws-ssh"
}

variable "create_key_pair" {
  description = "false: key_name already exists in AWS. true: create it from ssh_public_key_path."
  type        = bool
  default     = false
}

variable "ssh_public_key_path" {
  description = "Public key to upload when create_key_pair = true."
  type        = string
  default     = "~/.ssh/devop-aws-ssh.pub"
}

variable "ssh_private_key_path" {
  description = "Path to the .pem on the machine running terraform/ansible (chmod 400)."
  type        = string
  default     = "~/.ssh/devop-aws-ssh.pem"
}

variable "ssh_user" {
  description = "Login user of the Ubuntu AMI."
  type        = string
  default     = "ubuntu"
}
