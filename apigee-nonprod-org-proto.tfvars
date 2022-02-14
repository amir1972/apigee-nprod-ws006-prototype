project_id                = "apigee-nprod-ws004-prototype"
deploy_region             = "northamerica-northeast1"
psn_ranges                = ["10.58.96.0/22" ]  #Second range of /cidr 28
cidr_mask                 = 22  #Adding explicitily 
network                   = "apigee-vpc"
analytics_region          = "northamerica-northeast1"
runtime_region            = "northamerica-northeast1"
apigee_environments       = ["proto1", "proto2"]
apigee_envgroups          = {
                              prototype = {
                                environments = ["proto1", "proto2"]
                                hostnames    = ["proto-x.api.canadalife.com"]
                              }
                            }
cicd_cred_file             = "apigee-nprod-ws004.json"
terraform_service_account  = "apigee-nprod-ws004-cicd-deploy@cantech-terraformers.iam.gserviceaccount.com"