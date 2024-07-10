resource "aws_dynamodb_table" "iac_dynamodb" {
  name = var.dynamoDB_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
