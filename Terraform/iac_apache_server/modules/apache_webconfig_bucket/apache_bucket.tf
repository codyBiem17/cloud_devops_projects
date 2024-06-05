# create S3 bucket to store webserver config and ansible playbook

resource "aws_s3_bucket" "apache_s3" {
  bucket = var.apache_webconfig_bucket
}

# create an S3 object to upload files in the bucket

resource "aws_s3_object" "apache_bucket_object" {
  bucket = aws_s3_bucket.apache_s3.id
  for_each = fileset("./bucket_files","*")
  key = each.value
  source = "./bucket_files/$each.value"
  etag = filemd5("./bucket_files/${each.value}")
}

