
terraform {
  backend "consul" {
    address = "consul.cicd.canadalife.bz"
    scheme  = "https"
    path    = "terraform/state/ecs/gcp/apigee-nprod-ws006-prototype"
    gzip    = true
  }
}
