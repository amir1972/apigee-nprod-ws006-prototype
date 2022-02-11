// my-x-eval.tfvars

psn_ranges = ["10.57.192.0/20"]  
network = "apigee-vpc"
analytics_region = "us-east1"
runtime_region = "us-central1"
apigee_environments = ["proto1", "proto2"]
apigee_envgroups = {
  prototype = {
    environments = ["proto1", "proto2"]
    hostnames    = ["proto.api.canadalife.com"]
  }
}
