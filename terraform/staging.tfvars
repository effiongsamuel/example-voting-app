# Staging values. Use with:  terraform plan -var-file=staging.tfvars
# Give staging its OWN state key (for example voting-app/staging.tfstate),
# otherwise it would overwrite the dev stack in the shared state.
key_name             = "devop-aws-ssh"
ssh_private_key_path = "~/.ssh/devop-aws-ssh.pem"
create_key_pair      = false
ssh_user             = "ubuntu"
ssh_allowed_cidrs    = ["0.0.0.0/0"]

aws_region = "eu-north-1"

# GitHub user or organisation that owns the images built by .github/workflows/ci-cd.yml (ghcr.io/<owner>/...)
github_owner = "CHANGE_ME"
image_tag    = "latest" # first deployment only; CI deploys the commit SHA afterwards

# false = dedicated VPC (as before). true = the account's default VPC and a default subnet (capstone mode).
use_default_vpc = false
project_name    = "voting-app"
environment     = "staging"

vpc_cidr          = "10.1.0.0/16"
availability_zone = "eu-north-1a"
app_allowed_cidrs = ["0.0.0.0/0"]

deploy_method       = "k3s"
k3s_vote_nodeport   = 31000
k3s_result_nodeport = 31001

run_ansible = true

# ami_name_filter  = "ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-*"
ami_name_filter  = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" # cose postgres to fail to start
instance_type    = "m7i-flex.large"
root_volume_size = 20
