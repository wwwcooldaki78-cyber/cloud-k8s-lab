resource "aws_iam_policy" "splunk_cloudtrail_read" {
  name        = "splunk-cloudtrail-read"
  description = "Allow Splunk to retrieve CloudTrail logs from S3 and consume SQS notifications"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadCloudTrailLogs"
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/*"
      },
      {
        Sid    = "ListCloudTrailBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = aws_s3_bucket.cloudtrail_logs.arn
      },
      {
        Sid    = "ConsumeCloudTrailNotifications"
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:ChangeMessageVisibility",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:SendMessage"
        ]
        Resource = [
          aws_sqs_queue.cloudtrail_queue.arn,
          aws_sqs_queue.cloudtrail_dlq.arn
        ]
      },
      {
        Sid      = "ListSQSQueues"
        Effect   = "Allow"
        Action   = "sqs:ListQueues"
        Resource = "*"
      }
    ]
  })
  tags = {
    Name        = "splunk-cloudtrail-read"
    Environment = "Lab"
    Purpose     = "Splunk CloudTrail ingestion"
  }
}
