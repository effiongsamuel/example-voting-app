# Default / dev values. Loaded automatically by `terraform plan|apply`.
# =============================================================================
#  SSH KEY - EDIT HERE
# =============================================================================
key_name             = "devop-aws-ssh"             # key pair name in AWS (no .pem)
ssh_private_key_path = "~/.ssh/devop-aws-ssh.pem"  # written by the GitHub workflow from the EC2_SSH_PRIVATE_KEY secret
create_key_pair      = false                       # false = key pair already exists in AWS (eu-north-1)
# ssh_public_key_path = "~/.ssh/devop-aws-ssh.pub" # only used when create_key_pair = true
ssh_user             = "ubuntu"
ssh_allowed_cidrs    = ["0.0.0.0/0"]               # GitHub Actions runners have changing IPs, so SSH stays open for the pipeline
# =============================================================================

aws_region   = "eu-north-1"
project_name = "voting-app"
environment  = "dev"

# Network
vpc_cidr          = "10.0.0.0/16"
availability_zone = "eu-north-1a"
app_allowed_cidrs = ["0.0.0.0/0"]

# How the app is deployed: "compose", "k3s" or "both"
deploy_method       = "both"
vote_port           = 8080
result_port         = 8081
k3s_vote_nodeport   = 31000
k3s_result_nodeport = 31001

# Images used by Docker Compose (swap for your own registry images if you build them)
vote_image   = "dockersamples/examplevotingapp_vote"
result_image = "dockersamples/examplevotingapp_result"
worker_image = "dockersamples/examplevotingapp_worker"

# Automatic deployment
run_ansible = true

# Compute
ami_name_filter  = "ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-*"
instance_type    = "m7i-flex.large"
root_volume_size = 100
