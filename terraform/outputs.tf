output "vote_url" {
  description = "Docker Compose: vote page."
  value       = local.use_compose ? "http://${aws_eip.voting.public_ip}:${var.vote_port}" : null
}

output "result_url" {
  description = "Docker Compose: result page."
  value       = local.use_compose ? "http://${aws_eip.voting.public_ip}:${var.result_port}" : null
}

output "k3s_vote_url" {
  description = "k3s: vote page (NodePort)."
  value       = local.use_k3s ? "http://${aws_eip.voting.public_ip}:${var.k3s_vote_nodeport}" : null
}

output "k3s_result_url" {
  description = "k3s: result page (NodePort)."
  value       = local.use_k3s ? "http://${aws_eip.voting.public_ip}:${var.k3s_result_nodeport}" : null
}

output "grafana_url" {
  description = "k3s: Grafana dashboards (user admin; password: see instruction.txt, PART 9). null when deploy_method = compose."
  value       = local.use_k3s ? "http://${aws_eip.voting.public_ip}:${var.grafana_nodeport}" : null
}

output "public_ip" {
  description = "Elastic IP of the server."
  value       = aws_eip.voting.public_ip
}

output "ssh_command" {
  description = "SSH into the server."
  value       = "ssh -i ${var.ssh_private_key_path} ${var.ssh_user}@${aws_eip.voting.public_ip}"
}

output "check_containers" {
  description = "List the running containers and pods on the server."
  value       = "ssh -i ${var.ssh_private_key_path} ${var.ssh_user}@${aws_eip.voting.public_ip} 'sudo docker ps; sudo k3s kubectl get pods 2>/dev/null'"
}

output "vpc_id" {
  description = "ID of the VPC."
  value       = local.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet."
  value       = local.subnet_id
}

output "security_group_id" {
  description = "ID of the server's security group."
  value       = aws_security_group.app.id
}

output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.voting_server.id
}

output "ami_name" {
  description = "Name of the resolved AMI."
  value       = data.aws_ami.ubuntu.name
}

output "deploy_method" {
  description = "Deployment method Terraform actually used."
  value       = var.deploy_method
}
