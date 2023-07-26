terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.24"
    }
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  region     = "eu-west-2"
  access_key = var.credentials.access_key
  secret_key = var.credentials.secret_key
}

## start of experiment
module "memory_db" {
  source = "terraform-aws-modules/memory-db/aws"

  # Cluster
  name        = "example"
  description = "Example MemoryDB cluster"

  engine_version             = "6.2"
  auto_minor_version_upgrade = true
  node_type                  = "db.t4g.small"
  num_shards                 = 2
  num_replicas_per_shard     = 2

  tls_enabled              = true
  security_group_ids       = ["sg-12345678"]
  maintenance_window       = "sun:23:00-mon:01:30"
  sns_topic_arn            = "arn:aws:sns:us-east-1:012345678910:example-topic"
  snapshot_retention_limit = 7
  snapshot_window          = "05:00-09:00"

  # Users
  users = {
    admin = {
      user_name     = "admin-user"
      access_string = "on ~* &* +@all"
      passwords     = ["YouShouldPickAStrongSecurePassword987!"]
      tags          = { User = "admin" }
    }
    readonly = {
      user_name     = "readonly-user"
      access_string = "on ~* &* -@all +@read"
      passwords     = ["YouShouldPickAStrongSecurePassword123!"]
      tags          = { User = "readonly" }
    }
  }

  # ACL
  acl_name = "example-acl"
  acl_tags = { Acl = "custom" }

  # Parameter group
  parameter_group_name        = "example-param-group"
  parameter_group_description = "Example MemoryDB parameter group"
  parameter_group_family      = "memorydb_redis6"
  parameter_group_parameters = [
    {
      name  = "activedefrag"
      value = "yes"
    }
  ]
  parameter_group_tags = {
    ParameterGroup = "custom"
  }

  # Subnet group
  subnet_group_name        = "example-subnet-group"
  subnet_group_description = "Example MemoryDB subnet group"
  subnet_ids               = ["subnet-1fe3d837", "subnet-129d66ab", "subnet-1211eef5"]
  subnet_group_tags = {
    SubnetGroup = "custom"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
## end of experiment


variable "credentials" {
  description = "The credentials for connecting to AWS."
  type = object({
    access_key = string
    secret_key = string
  })
  sensitive = true
}

output "region" {
  value = module.aws_s3.s3_bucket_region
}

