output "id" {
  description = "The ID of the Storage Account"
  value       = google_storage_bucket.stg.id
}

output "name" {
  description = "The name of the Storage Account"
  value       = google_storage_bucket.stg.name
}

output "location" {
  description = "The location of the Storage Account"
  value       = var.location
}

output "project_name" {
  description = "The resource group name of the Storage Account"
  value       = var.project_name
}
