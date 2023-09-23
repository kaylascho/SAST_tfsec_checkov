provider "aws" {
  region = "us-west-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}



# I decided to managed KMS key separately by creating via console and import it to a resource locally. 
# This will help to manage as IAC.
# I directly used the key arn in sqs queue.