terraform {
  backend "s3" {
    bucket       = "ts-academy-sam-state-file"
    key          = "tf-academy.tfstate"
    region       = "eu-north-1"
  }
}