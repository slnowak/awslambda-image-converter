provider "aws" {
  region = "us-east-1"
  access_key = "yourkey"
  secret_key = "yoursecret"
}

variable "input_bucket" {
  default = "snowakserverlessimages"
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

resource "aws_lambda_function" "image_resize" {
  filename = "image_resize.zip"
  function_name = "imageResize"
  handler = "image_resize.handler"
  runtime = "python2.7"
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