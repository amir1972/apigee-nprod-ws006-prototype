output "instance_endpoints" {
  description = "Map of instance name -> internal runtime endpoint IP address"
  value = tomap({
    for name, instance in module.apigee-x-instance : name => instance.endpoint
  })
}

output "project_id" {
  description = "Project ID containing the network. Use this when you need to create resources *after* the VPC is fully set up (e.g. subnets created, shared VPC service projects attached, Private Service Networking configured)."
  value       = var.project_id
}

output "email" {
  description = "Service account email."
  value       = local.resource_email_static
  depends_on = [
    local.service_account
  ]
}

output "iam_email" {
  description = "IAM-format service account email."
  value       = local.resource_iam_email_static
  depends_on = [
    local.service_account
  ]
}

output "key" {
  description = "Service account key."
  sensitive   = true
  value       = local.key
}

output "service_account" {
  description = "Service account resource."
  value       = local.service_account
}

output "service_account_credentials" {
  description = "Service account json credential templates for uploaded public keys data."
  value       = local.service_account_credential_templates
}
