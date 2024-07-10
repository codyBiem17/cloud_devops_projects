# create multiple S3 buckets to use the 'count' meta-argument

resource "aws_s3_bucket" "s3_bucket_count" {
  count = length(var.buckets_count)
  bucket = "${var.buckets_count[count.index]}-count"
}
