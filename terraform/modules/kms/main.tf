resource "aws_kms_key" "paysecure" {
  description = "PaySecure CMK ${var.region}"
  deletion_window_in_days = 30
  enable_key_rotation = true
  tags = var.tags
}
resource "aws_kms_alias" "alias" { name = "alias/paysecure-${var.region}" target_key_id = aws_kms_key.paysecure.key_id }
variable "region" { type=string }
variable "tags" { type=map(string) default={} }
output "key_arn" { value=aws_kms_key.paysecure.arn }
output "key_id" { value=aws_kms_key.paysecure.key_id }
