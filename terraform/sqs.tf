resource "aws_sqs_queue" "cloudtrail_dlq" {
  name                      = "cloudtrail-dlq"
  message_retention_seconds = 1209600 # 14 days
  sqs_managed_sse_enabled   = true
  tags = {
    Name        = "cloudtrail-dlq"
    Environment = "Lab"
    Purpose     = "Dead-letter queue for CloudTrail events"
  }
}

resource "aws_sqs_queue" "cloudtrail_queue" {
  name                       = "cloudtrail-queue"
  visibility_timeout_seconds = 300    # 5 minutes
  message_retention_seconds  = 345600 # 4 days
  delay_seconds              = 0
  receive_wait_time_seconds  = 0
  sqs_managed_sse_enabled    = true
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.cloudtrail_dlq.arn
    maxReceiveCount     = 5
  })
  tags = {
    Name        = "cloudtrail-queue"
    Environment = "Lab"
    Purpose     = "Receive CloudTrail S3 notifications"
  }
}

resource "aws_sqs_queue_policy" "cloudtrail_queue" {
  queue_url = aws_sqs_queue.cloudtrail_queue.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3ToSendMessages"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.cloudtrail_queue.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.cloudtrail_logs.arn
          }
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}
