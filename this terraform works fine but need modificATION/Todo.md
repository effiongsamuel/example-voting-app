# Terraform Class — TODO

A hands-on path from architecture design to a fully automated, CI/CD-driven
1-tier AWS deployment. Work through the phases in order — each one builds on
the last.

---

## Phase 1 — Design the AWS Architecture

Before writing any code, know what you're building and why.

- [ ] Draw a 1-tier AWS architecture diagram (Draw.io or Lucidchart)
- [ ] Identify the AWS services required (VPC, ALB, EC2, RDS, etc.)
- [ ] Identify public vs. private subnets
- [ ] Map security groups and network traffic flow between tiers
- [ ] Define how users will reach the application (entry point, DNS, ALB)

> 💡 **Why this matters:** a diagram forces you to decide *before* Terraform
> forces you to debug. Mistakes here are cheap; mistakes in `apply` aren't.

---

## Phase 2 — Learn Terraform Fundamentals

- [ ] Set up a Terraform project structure
- [ ] Configure the AWS provider
- [ ] Understand resources
- [ ] Understand variables
- [ ] Understand outputs
- [ ] Understand state
- [ ] Understand the core Terraform workflow

### The Terraform Workflow

| Command | What it does |
|---|---|
| `terraform init` | Initializes the project and downloads providers |
| `terraform fmt` | Formats configuration files consistently |
| `terraform validate` | Checks configuration syntax and internal consistency |
| `terraform plan` | Previews what changes will be made |
| `terraform apply` | Creates or modifies infrastructure |

> 💡 **Tip:** memorize this order — `init → fmt → validate → plan → apply`.
> You'll type it dozens of times this class, and it becomes muscle memory
> for every real-world Terraform project.

---

## Phase 3 — Build the Infrastructure with Terraform

### 3.1 Networking
- [ ] Create the VPC
- [ ] Create the Internet Gateway
- [ ] Create public subnets
- [ ] Create private subnets
- [ ] Create route tables
- [ ] Create the NAT Gateway
- [ ] Configure routes between subnets and gateways

### 3.2 Security
- [ ] Create security groups
- [ ] Configure inbound rules
- [ ] Configure outbound rules
- [ ] Understand how security groups control tier-to-tier communication

### 3.3 Application Tier
- [ ] Create an Application Load Balancer
- [ ] Create a target group
- [ ] Create EC2 instances
- [ ] Configure the application servers

### 3.4 Database Tier
- [ ] Create a DB subnet group
- [ ] Create a database security group
- [ ] Create the RDS database
- [ ] Verify the database is **not** publicly accessible

> ⚠️ **Checkpoint:** before moving on, confirm no security group allows
> `0.0.0.0/0` into the database tier. This is the #1 mistake in student
> projects.

---

## Phase 4 — Configure Remote Terraform State

- [ ] Create an S3 bucket for Terraform state
- [ ] Configure S3 as the backend
- [ ] Configure state locking
- [ ] Run `terraform init` to migrate state
- [ ] Verify state is stored in S3
- [ ] Explain **why** remote state matters
- [ ] Explain **why** state locking matters

---

## Phase 5 — Deploy Infrastructure to AWS

- [ ] `terraform init`
- [ ] `terraform fmt`
- [ ] `terraform validate`
- [ ] `terraform plan`
- [ ] Review the plan output carefully
- [ ] `terraform apply`
- [ ] Verify resources in the AWS Console
- [ ] Test application connectivity end-to-end
- [ ] Verify communication between all three tiers

---

## Phase 6 — GitHub Actions CI/CD

- [ ] Create a GitHub repository
- [ ] Push Terraform configuration to GitHub
- [ ] Create a GitHub Actions workflow
- [ ] Configure Terraform inside the workflow
- [ ] Configure AWS authentication (see best practices below)
- [ ] Run `terraform fmt` in CI
- [ ] Run `terraform validate` in CI
- [ ] Run `terraform plan` in CI
- [ ] Review the plan output in the workflow logs
- [ ] Run `terraform apply` in CI

---

## Phase 7 — Terraform Best Practices

- [ ] Use variables instead of hardcoded values
- [ ] Use outputs to expose useful values
- [ ] Use `.tfvars` files for environment-specific values
- [ ] Use meaningful, consistent resource names
- [ ] Use Terraform modules to organize code
- [ ] Use remote state
- [ ] Never commit `terraform.tfstate` to Git
- [ ] Never commit AWS credentials to Git
- [ ] Use GitHub OIDC instead of long-lived AWS credentials
- [ ] Always review `terraform plan` before applying
- [ ] Keep all Terraform configuration in version control

---

## Phase 8 — Clean Up Infrastructure

- [ ] Review everything Terraform created
- [ ] Run `terraform destroy`
- [ ] Confirm the destruction
- [ ] Verify resources are removed from the AWS Console
- [ ] Verify the Terraform state reflects the teardown
- [ ] Discuss when `terraform destroy` should — and shouldn't — be used

> ⚠️ **Reminder:** always destroy lab environments when you're done to avoid
> unexpected AWS charges.

---

