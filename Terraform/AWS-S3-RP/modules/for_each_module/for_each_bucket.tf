# create multiple S3 buckets to use the 'for_each' meta-argument


resource "aws_s3_bucket" "s3_buckets_create" {
  bucket = var.for_bucket_names
}

