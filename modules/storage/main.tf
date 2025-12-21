resource "aws_s3_bucket" "assets" {
    bucket_prefix = "starman-assets"
    force_destroy = true
}

resource "aws_s3_bucket_versioning" "assets" {
    bucket = aws_s3_bucket.assets.id
    versioning_configuration { 
        status = "Enabled"
    }
}