
/*
resource "random_string" "randomstring" {
  length      = 25
  min_lower   = 15
  min_numeric = 10
  special     = false
}
*/
locals {
  bucket_name = join("", [var.storage_bucket.name,"-", var.project_name])
}


resource "google_storage_bucket" "stg" {
  name          = local.bucket_name
  location      = var.location
  force_destroy = try(var.storage_bucket.force_destroy,false)
  project = var.project_name
}

resource "google_storage_bucket_object" "object" {
  for_each = try(var.storage_bucket.bucket_objects,{})
  name = each.value.target
  source = each.value.source
  bucket = google_storage_bucket.stg.name
}





/*

resource "null_resource" "dependency_setter" {
  depends_on = [
    google_storage_bucket.bootstrap,
    google_storage_bucket_object.config_full,
    google_storage_bucket_object.content_full,
    google_storage_bucket_object.license_full,
    google_storage_bucket_object.software_full,
    google_storage_bucket_object.config_empty,
    google_storage_bucket_object.content_empty,
    google_storage_bucket_object.license_empty,
    google_storage_bucket_object.software_empty,
  ]
}
*/