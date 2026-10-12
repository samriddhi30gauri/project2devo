module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "19.21.0"
  cluster_name = "paysecure-${var.region}"
  cluster_version = "1.29"
  vpc_id = var.vpc_id
  subnet_ids = var.private_subnets
  cluster_encryption_config = [{ provider_key_arn=var.kms_key_arn resources=["secrets"] }]
  eks_managed_node_groups = {
    primary = { min_size=6 max_size=20 desired_size=6 instance_types=["m5.xlarge"] ami_type="BOTTLEROCKET_x86_64" }
  }
  tags = var.tags
}
variable "region" {}
variable "vpc_id" {}
variable "private_subnets" { type=list(string) }
variable "kms_key_arn" {}
variable "tags" { default={} }
