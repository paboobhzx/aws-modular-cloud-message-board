resource "aws_dynamodb_table" "messages" {
    name = "Starman_Messages"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "MessageId"

    attribute { 
        name = "MessageId"
        type = "S"
    }
}

resource "aws_dynamodb_table_item" "welcome" { 
    table_name = aws_dynamodb_table.messages.name
    hash_key = aws_dynamodb_table.messages.hash_key
    item = <<ITEM
{
  "MessageId": {"S": "1"},
  "Content": {"S": "Hello! This text is coming directly from DynamoDB via a VPC Endpoint."}
}
ITEM
}
