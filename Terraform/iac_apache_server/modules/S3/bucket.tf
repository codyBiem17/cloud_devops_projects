# create S3 bucket for backend terraform statefile

resource "aws_s3_bucket" "s3_backend"{
  bucket = "${var.bucket_name}"
#  lifecycle {
#    prevent_destroy = true
#  }
}

resource "aws_s3_bucket_versioning" "versioning_statefile_bucket" {
  bucket = aws_s3_bucket.s3_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_iam_user" "apache-s3-user" {
  user_name = "admin_b4maryan"
}

output "iam_user" {
  value = "${data.aws_iam_user.apache-s3-user.arn}"
}

resource "aws_s3_bucket_policy" "apaache-bucket-policy" {
  bucket = aws_s3_bucket.s3_backend.id
  policy = <<EOF
  {
    "Version":"2012-10-17",
    "Statement":[
        {
            "Sid":"Statement1",
            "Principal":{
                "AWS": "${data.aws_iam_user.apache-s3-user.arn}"
             },
            "Effect":"Allow",
            "Action":"*",
            "Resource":"arn:aws:s3:::${aws_s3_bucket.s3_backend.id}/*"
        }
     ]
  }
  EOF

}

