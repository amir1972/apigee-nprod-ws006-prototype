project_id         = "apigee-nprod-ws004-prototype"  #Must be registered with Google to become a paid org

ax_region          = "us-east1"  #Analytics Region (and also KeyRing for Database Encryption)
network            = "projects/net-hub-infra/global/networks/int-cl-apigee-prototype-shared-vpc-1"

apigee_environments = ["proto1", "proto2"]

apigee_instances  = {
  #IP Ranges documented at https://spaces.gwl.ca/display/ECS/GCP+Projects+and+CIDR+Implementation
  na-ne1-instance = {
    region        = "northamerica-northeast1"  #And also for Disk Encryption Keyring
    ip_range      = "10.58.24.0/22"
    environments  = ["proto1", "proto2"]
  }
  # Example of second instance
  # na-ne2-instance = {
  #   region        = "europe-west2"
  #   ip_range      = "10.0.8.0/22"
  #   environments  = ["test1", "test2"]
  # }
}
apigee_envgroups    = {
            prototype = {
           environments = ["proto1", "proto2"]
           hostnames    = ["prototype-apix.canadalife.com", "prototype-api.canadalife.com"]
                        }
                      }
cicd_cred_file             = "apigee-nprod-ws004-prototype.json"
terraform_service_account  = "apigee-nprod-ws004-tf-prod@cantech-terraformers.iam.gserviceaccount.com"
