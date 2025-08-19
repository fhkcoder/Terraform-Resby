terraform {
  backend "s3" {
    bucket       = "resby-faisal-bucket0001"
    region       = "us-east-1"
    key          = "terraform.tfstate"
    encrypt      = true
    use_lockfile = true
  }
}
