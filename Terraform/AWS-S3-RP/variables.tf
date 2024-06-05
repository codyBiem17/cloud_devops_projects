# variable declarations here

variable "for_each_bucket_names" {
  type = set(string)
  description = "create multiple S3 buckets"
  default = ["bucket1", "bucket2", "bucket3"]
}

