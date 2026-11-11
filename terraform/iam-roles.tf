data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "k8s_worker_splunk_role" {
  name               = "k8s-worker-splunk-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags = {
    Name        = "k8s-worker-splunk-role"
    Environment = "Lab"
    Purpose     = "Allow Splunk to access CloudTrail logs"
  }
}

resource "aws_iam_instance_profile" "k8s_worker_splunk_profile" {
  name = "k8s-worker-splunk-profile"
  role = aws_iam_role.k8s_worker_splunk_role.name
}

resource "aws_iam_role_policy_attachment" "splunk_cloudtrail_read" {
  role       = aws_iam_role.k8s_worker_splunk_role.name
  policy_arn = aws_iam_policy.splunk_cloudtrail_read.arn
}
