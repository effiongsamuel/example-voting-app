terraform {
  backend "s3" {
    bucket       = "ts-academy-voting-single-server-file"
    key          = "voting-app1.tfstate"
    region       = "eu-north-1"
  }
}