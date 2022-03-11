module "apigee-x-core" {
  source              = "github.com/apigee/terraform-modules//modules/apigee-x-core"

  project_id          = var.project_id
  ax_region           = var.ax_region
  network             = var.network
  apigee_environments = var.apigee_environments
  apigee_instances    = var.apigee_instances
  apigee_envgroups    = var.apigee_envgroups

}