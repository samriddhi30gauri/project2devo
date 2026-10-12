module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"
  name = "paysecure-${var.region}"
  cidr = var.cidr
  azs = ["${var.region}a","${var.region}b","${var.region}c"]
  private_subnets = [for i in range(3): cidrsubnet(var.cidr,4,i)]
  public_subnets = [for i in range(3,6): cidrsubnet(var.cidr,4,i)]
  database_subnets = [for i in range(6,9): cidrsubnet(var.cidr,4,i)]
  enable_nat_gateway = true
  single_nat_gateway = false
  enable_dns_hostnames = true
  tags = var.tags
}
variable "region" {}
variable "cidr" {}
variable "tags" { default={} }
output "vpc_id" { value=module.vpc.vpc_id }
output "private_subnets" { value=module.vpc.private_subnets }
output "database_subnets" { value=module.vpc.database_subnets }
