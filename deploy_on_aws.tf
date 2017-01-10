provider "aws" {
  region = "eu-central-1"
}

variable "input_bucket" {
  default = "kkulakimages"
}

resource "aws_s3_bucket" "input" {
  bucket = "${var.input_bucket}"
  acl = "private"
}

resource "aws_s3_bucket" "output_cover" {
  bucket = "${var.input_bucket}cover"
  acl = "private"
}

resource "aws_s3_bucket" "output_profile" {
  bucket = "${var.input_bucket}profile"
  acl = "private"
}

resource "aws_s3_bucket" "output_thumbnail" {
  bucket = "${var.input_bucket}thumbnail"
  acl = "private"
}

resource "aws_iam_policy" "bucket_access_policy" {
  name = "lambda_access_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.input.bucket}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:*"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.output_cover.bucket}/*",
        "arn:aws:s3:::${aws_s3_bucket.output_profile.bucket}/*",
        "arn:aws:s3:::${aws_s3_bucket.output_thumbnail.bucket}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
  role = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.bucket_access_policy.arn}"
}

resource "aws_lambda_function" "image_resize" {
  filename = "image_resize.zip"
  function_name = "imageResize"
  handler = "image_resize.handler"
  runtime = "python2.7",
  timeout = 10
  role = "${aws_iam_role.iam_for_lambda.arn}"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id = "AllowExecutionFromS3Bucket"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.image_resize.arn}"
  principal = "s3.amazonaws.com"
  source_arn = "${aws_s3_bucket.input.arn}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.input.id}"
  lambda_function {
    lambda_function_arn = "${aws_lambda_function.image_resize.arn}"
    events = [
      "s3:ObjectCreated:*"]
  }
}
