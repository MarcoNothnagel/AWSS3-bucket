# Define the S3 bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "upload-bucket0000"
  acl    = "private"

  tags = {
    Name        = "upload-bucket"
    Environment = "Dev"
  }
}

# Define the SQS queue
resource "aws_sqs_queue" "upload_queue" {
  name                      = "upload-queue"
  delay_seconds             = 60
  max_message_size          = 8192
  message_retention_seconds = 172800
  receive_wait_time_seconds = 15

  tags = {
    Environment = "Dev"
  }
}

# Attach policy to SQS queue to allow S3 bucket to send messages
resource "aws_sqs_queue_policy" "upload_queue_policy" {
  queue_url = aws_sqs_queue.upload_queue.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "SQSPolicy",
  "Statement": [
    {
      "Sid": "Allow-S3-Events",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "SQS:SendMessage",
      "Resource": "${aws_sqs_queue.upload_queue.arn}",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "${aws_s3_bucket.bucket.arn}"
        }
      }
    }
  ]
}
EOF
}

# Define IAM policy document for S3 bucket notifications
data "aws_iam_policy_document" "notif_policy_doc" {
  statement {
    sid    = "1"
    effect = "Allow"

    actions = [
      "sqs:SendMessage"
    ]

    resources = [
      aws_sqs_queue.upload_queue.arn  # Reference to SQS queue ARN
    ]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        aws_s3_bucket.bucket.arn  # Reference to S3 bucket ARN
      ]
    }
  }
}

# Create IAM policy based on the policy document
resource "aws_iam_policy" "notif_policy" {
  name   = "notif_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.notif_policy_doc.json
}

# Attach the policy to the bucket
resource "aws_s3_bucket_notification" "bucket_notif" {
  bucket = aws_s3_bucket.bucket.id

  queue {
    queue_arn = aws_sqs_queue.upload_queue.arn
    events    = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_iam_policy.notif_policy,  # Ensure policy is created before configuring bucket notification
    aws_sqs_queue_policy.upload_queue_policy  # Ensure SQS queue policy is created before configuring bucket notification
  ]
}
