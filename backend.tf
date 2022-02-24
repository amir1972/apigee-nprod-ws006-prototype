terraform {
  backend "consul" {
    address = "consul.cicd.canadalife.bz"
    scheme  = "https"
    path    = "terraform/state/ecs/gcp/apigee-nprod-ws004-prototype"
    gzip    = true
  }
}