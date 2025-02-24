output "mimir_bucket_id" {
    description = "value of the mimir bucket id"
    value = linode_object_storage_bucket.mimir-bucket.id
}

output "loki_bucket_id" {
    value = linode_object_storage_bucket.loki-bucket.id
}