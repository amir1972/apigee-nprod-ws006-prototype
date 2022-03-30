

resource "google_logging_organization_sink" "sink" {
  for_each         = var.logging_sinks
  name             = each.key
  org_id           = local.organization_id_numeric
  destination      = "${each.value.type}.googleapis.com/${each.value.destination}"
  filter           = each.value.filter
  include_children = each.value.include_children

  dynamic "bigquery_options" {
    for_each = each.value.bq_partitioned_table == true ? [""] : []
    content {
      use_partitioned_tables = each.value.bq_partitioned_table
    }
  }

  dynamic "exclusions" {
    for_each = each.value.exclusions
    iterator = exclusion
    content {
      name   = exclusion.key
      filter = exclusion.value
    }
  }
  depends_on = [
    google_organization_iam_binding.authoritative,
    google_organization_iam_member.additive,
    google_organization_iam_policy.authoritative,
  ]
}

resource "google_storage_bucket_iam_member" "storage-sinks-binding" {
  for_each = local.sink_bindings["storage"]
  bucket   = each.value.destination
  role     = "roles/storage.objectCreator"
  member   = google_logging_organization_sink.sink[each.key].writer_identity
}

resource "google_bigquery_dataset_iam_member" "bq-sinks-binding" {
  for_each   = local.sink_bindings["bigquery"]
  project    = split("/", each.value.destination)[1]
  dataset_id = split("/", each.value.destination)[3]
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_organization_sink.sink[each.key].writer_identity
}

resource "google_pubsub_topic_iam_member" "pubsub-sinks-binding" {
  for_each = local.sink_bindings["pubsub"]
  project  = split("/", each.value.destination)[1]
  topic    = split("/", each.value.destination)[3]
  role     = "roles/pubsub.publisher"
  member   = google_logging_organization_sink.sink[each.key].writer_identity
}

resource "google_project_iam_member" "bucket-sinks-binding" {
  for_each = local.sink_bindings["logging"]
  project  = split("/", each.value.destination)[1]
  role     = "roles/logging.bucketWriter"
  member   = google_logging_organization_sink.sink[each.key].writer_identity
  # TODO(jccb): use a condition to limit writer-identity only to this bucket
}

resource "google_logging_organization_exclusion" "logging-exclusion" {
  for_each    = var.logging_exclusions
  name        = each.key
  org_id      = local.organization_id_numeric
  description = "${each.key} (Terraform-managed)."
  filter      = each.value
}
