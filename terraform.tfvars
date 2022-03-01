project_id                = "apigee-nprod-ws004-prototype"
deploy_region             = "northamerica-northeast1"
ip_range                  = {range-a = "10.58.24.0/22"}  #Assumed second range of /cidr 28 added to end
network                   = "apigee-vpc"
analytics_region          = "us-east1"
runtime_region            = "northamerica-northeast1"
apigee_environments       = ["proto1", "proto2"]
apigee_envgroups          = {
                              prototype = {
                                environments = ["proto1", "proto2"]
                                hostnames    = ["prototype-apix.canadalife.com"]
                              }
                            }
cicd_cred_file             = "apigee-nprod-ws004-prototype.json"
terraform_service_account  = "apigee-nprod-ws004-tf-prod@cantech-terraformers.iam.gserviceaccount.com"
