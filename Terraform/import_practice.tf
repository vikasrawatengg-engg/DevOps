resource "aws_s3_bucket" "my_imported_bucket" {
  bucket = "vikas-manually-built-bucket-2026" # Must match your real bucket name

  # Assignment Goal: Add new tags to the manually created bucket using code
  tags = {
    ManagedBy = "Terraform"
    Imported  = "22nd-May-Assignment"
    Owner     = "Vikas"
  }
}