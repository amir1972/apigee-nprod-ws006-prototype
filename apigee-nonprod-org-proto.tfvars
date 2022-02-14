project_id = "apigee-nprod-ws004-prototype"
deploy_region = "northamerica-northeast1"

psn_ranges = ["10.58.96.0/20" ]  #Second range of /cidr 28
cidr_mask = 20  #Adding explicitily 
network = "apigee-vpc"
analytics_region = var.deploy_region
runtime_region = var.deploy_region
apigee_environments = ["proto1", "proto2"]
apigee_envgroups = {
  prototype = {
    environments = var.apigee_environments
    hostnames    = ["proto-x.api.canadalife.com"]
  }
}
cicd_cred_file = "apigee-nprod-ws004.json" 