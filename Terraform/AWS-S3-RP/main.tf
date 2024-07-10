resource "aws_s3_bucket" "finance" {
  bucket = "finance-26012022"
  tags = {
    Description = "Finance and Payroll"
  }
}

resource "aws_s3_bucket_object" "finance-2022" {
  content = "/s3-bucket-content/finance-2022.doc"
  key = "finance-2022.doc"
  bucket = aws_s3_bucket.finance.id
}

data "aws_iam_user" "finance-analysts-user" {
  user_name = "biemislam"
}

output "user_arn" {
  value = "${data.aws_iam_user.finance-analysts-user.arn}"
}

output "aws_s3_id" {
  value = aws_s3_bucket.finance.arn
}

resource "aws_s3_bucket_policy" "finance-policy" {
  bucket = aws_s3_bucket.finance.id
  policy = <<EOF
  {
    "Version":"2012-10-17",
    "Statement":[
        {
            "Sid":"Statement1",
            "Principal":{
                "AWS": "${data.aws_iam_user.finance-analysts-user.arn}"
             },
            "Effect":"Allow",
            "Action":"*",
            "Resource":"arn:aws:s3:::${aws_s3_bucket.finance.id}/*"
        }
     ]
  } 
  EOF

}

# create S3 buckets from module using for_each meta argument

module "for_each_S3-buckets" {
  source = "./modules/for_each_module" 
  for_each = var.for_each_bucket_names
  for_bucket_names = "${each.value}.iac"
}

# create S3 buckets form module using count met argument

module "count_S3_buckets" {
  source = "./modules/count_module"
}
