terraform {
  backend "s3" {
    bucket       = "ts-academy-voting-single-server-file"
    key          = "voting-app1.tfstate"
    region       = "eu-north-1"
    encrypt      = true # state is encrypted at rest (it holds the generated database password)
    use_lockfile = true # S3-native state locking (Terraform 1.10 or newer), no DynamoDB table needed
  }
}
