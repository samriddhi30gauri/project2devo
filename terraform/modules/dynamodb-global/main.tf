resource "aws_dynamodb_table" "idempotency" {
  name = "txn_idempotency"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "idempotency_key"
  range_key = "merchant_id"
  attribute { name="idempotency_key" type="S" }
  attribute { name="merchant_id" type="S" }
  ttl { attribute_name="ttl" enabled=true }
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  point_in_time_recovery { enabled=true }
  server_side_encryption { enabled=true kms_key_arn=var.kms_key_arn }
  replica { region_name=var.secondary_region kms_key_arn=var.kms_key_secondary propagate_tags=true }
  tags=var.tags
}
variable "kms_key_arn" {}
variable "kms_key_secondary" {}
variable "secondary_region" { default="ap-south-2" }
variable "tags" { default={} }
