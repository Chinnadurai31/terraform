
terraform {
  backend "s3" {
    bucket       = "terraform-backend-chinna-123"
    key          = "terraform/terraform.tfstate"
    region       = "us-west-2"
    use_lockfile = true
  }
}