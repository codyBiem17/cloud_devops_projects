resource "aws_dynamodb_table" "cars" {
  name = "cars"
  hash_key = "VIN"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "VIN"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "car_items" {
  table_name = aws_dynamodb_table.cars.name
  hash_key = aws_dynamodb_table.cars.hash_key
  item = <<EOF
  {
    "Manufacturer": {"S": "Lexus"},
    "Year": {"N": "2022"},
    "Color": {"S": "burnt_orange"},
    "VIN": {"S": "b143i143e143m"}
  }
  EOF
}
