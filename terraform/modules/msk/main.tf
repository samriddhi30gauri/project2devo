resource "aws_msk_cluster" "paysecure" {
  cluster_name = "paysecure-${var.region}"
  kafka_version = "3.6.0"
  number_of_broker_nodes = 3
  broker_node_group_info {
    instance_type = "kafka.m5.large"
    client_subnets = var.private_subnets
    security_groups = [var.sg_id]
    storage_info { ebs_storage_info { volume_size=1000 } }
  }
  encryption_info {
    encryption_at_rest_kms_key_arn = var.kms_key_arn
    encryption_in_transit { client_broker="TLS" in_cluster=true }
  }
  tags=var.tags
}
variable "region" {}
variable "private_subnets" { type=list(string) }
variable "sg_id" {}
variable "kms_key_arn" {}
variable "tags" { default={} }
