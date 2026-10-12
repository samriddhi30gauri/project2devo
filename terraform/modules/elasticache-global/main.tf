resource "aws_elasticache_global_replication_group" "paysecure" {
  global_replication_group_id_suffix = "paysecure"
  primary_replication_group_id = aws_elasticache_replication_group.primary.id
}
resource "aws_elasticache_replication_group" "primary" {
  replication_group_id = "paysecure-primary"
  description = "Primary"
  engine = "redis"
  engine_version = "7.0"
  node_type = "cache.r6g.large"
  num_cache_clusters = 3
  automatic_failover_enabled = true
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  kms_key_id = var.kms_key_primary
  subnet_group_name = var.subnet_group_primary
  security_group_ids = [var.sg_primary]
}
resource "aws_elasticache_replication_group" "secondary" {
  replication_group_id = "paysecure-secondary"
  description = "Secondary"
  global_replication_group_id = aws_elasticache_global_replication_group.paysecure.global_replication_group_id
  num_cache_clusters = 3
  automatic_failover_enabled = true
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  kms_key_id = var.kms_key_secondary
}
variable "kms_key_primary" {}
variable "kms_key_secondary" {}
variable "subnet_group_primary" {}
variable "sg_primary" {}
