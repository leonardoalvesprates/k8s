resource "aws_kms_key" "kms01" {
  description             = "KMS lprates lab"
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "kms_alias01" {
  name          = "alias/lprates-lab-mar-9-t3"
  target_key_id = aws_kms_key.kms01.key_id
}