terraform {
  backend "s3" {
    bucket         = "sirpi-terraform-states"
    key            = "states/sess_09e03f5cbf5a/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "sirpi-terraform-locks"
    encrypt        = true
  }
}

# State locking prevents concurrent terraform applies
# Versioning allows rollback to previous states
# Encryption protects sensitive data in state
