resource "aws_s3_bucket" "cloudResume" {
  bucket = var.bucketName
  tags = {
    Description = "Maryam-Cloud-Resume"
  }
}

resource "aws_s3_bucket_website_configuration" "cloudResume-config" {
  bucket = aws_s3_bucket.cloudResume.bucket
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "cloudResume-bucket-policy" {
  bucket = aws_s3_bucket.cloudResume.id
  policy = templatefile("s3-bucket-policy.json", { bucket = var.bucketName })
}


