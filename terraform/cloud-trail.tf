resource "aws_cloudtrail" "lab_trail" {
  name                          = "dl-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  s3_key_prefix                 = "cloudtrail"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }
  tags = {
    Name        = "dl-cloudtrail"
    Environment = "Lab"
    Purpose     = "AWS management event auditing"
  }
  depends_on = [
    aws_s3_bucket_policy.cloudtrail_logs
  ]
}
