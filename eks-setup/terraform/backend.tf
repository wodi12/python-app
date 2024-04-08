terraform {
  backend "s3" {
    bucket = "sprigs-terraform"
    key    = "terraform/aws/pythonapp-state/eks.state"
    region = "us-east-2"
  }
}
