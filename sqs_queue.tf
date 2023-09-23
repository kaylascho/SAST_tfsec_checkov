# Create an SQS queue (events notification) for s3 bucket. You can also use SQS topic
resource "aws_sqs_queue" "my_queue" {
  name              = var.sqs_queue_queue_name
  kms_master_key_id = "arn:aws:kms:us-west-1:986114105941:key/92610e36-0cd6-4fc7-be9a-bfa7831db4b0"
}



