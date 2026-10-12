resource "aws_rds_global_cluster" "paysecure" {
  global_cluster_identifier = "paysecure-global"
  engine = "aurora-postgresql"
  engine_version = "15.4"
  storage_encrypted = true
  deletion_protection = true
}
resource "aws_rds_cluster" "primary" {
  cluster_identifier = "paysecure-primary"
  global_cluster_identifier = aws_rds_global_cluster.paysecure.id
  engine = aws_rds_global_cluster.paysecure.engine
  engine_version = aws_rds_global_cluster.paysecure.engine_version
  database_name = "paysecure"
  master_username = var.master_username
  master_password = var.master_password
  db_subnet_group_name = var.db_subnet_group_primary
  vpc_security_group_ids = [var.sg_primary]
  kms_key_id = var.kms_key_primary
  backup_retention_period = 35
  preferred_backup_window = "03:00-04:00"
  storage_encrypted = true
  enabled_cloudwatch_logs_exports = ["postgresql"]
  deletion_protection = true
}
resource "aws_rds_cluster_instance" "primary" {
  count = 2
  identifier = "paysecure-primary-${count.index}"
  cluster_identifier = aws_rds_cluster.primary.id
  instance_class = "db.r6g.large"
  engine = aws_rds_cluster.primary.engine
  performance_insights_enabled = true
}
resource "aws_rds_cluster" "secondary" {
  cluster_identifier = "paysecure-secondary"
  global_cluster_identifier = aws_rds_global_cluster.paysecure.id
  engine = aws_rds_global_cluster.paysecure.engine
  engine_version = aws_rds_global_cluster.paysecure.engine_version
  db_subnet_group_name = var.db_subnet_group_secondary
  vpc_security_group_ids = [var.sg_secondary]
  kms_key_id = var.kms_key_secondary
  storage_encrypted = true
  deletion_protection = true
  source_region = var.primary_region
}
resource "aws_rds_cluster_instance" "secondary" {
  count = 2
  identifier = "paysecure-secondary-${count.index}"
  cluster_identifier = aws_rds_cluster.secondary.id
  instance_class = "db.r6g.large"
  engine = aws_rds_cluster.secondary.engine
}
variable "primary_region" {}
variable "master_username" {}
variable "master_password" { sensitive=true }
variable "db_subnet_group_primary" {}
variable "db_subnet_group_secondary" {}
variable "sg_primary" {}
variable "sg_secondary" {}
variable "kms_key_primary" {}
variable "kms_key_secondary" {}
