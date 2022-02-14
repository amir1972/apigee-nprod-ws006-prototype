terraform {
  backend "gcs" {
    bucket = "cft-tfstate-ec3c"
    prefix = "terraform/apigee/apigee-nprod-ws004-prototype/state"
  }
}