module "apigee-x-core" {
  source              = "github.com/apigee/terraform-modules//modules/apigee-x-core"

  project_id                = "apigee-nprod-ws004-prototype"
  #IP Ranges documented at https://spaces.gwl.ca/display/ECS/GCP+Projects+and+CIDR+Implementation
  ax_region         = "us-east1"  #Analytics Region (and also KeyRing for Database Encryption)
  network           = "int-cl-apigee-prototype-shared-vpc-1"
  apigee_instances  = {
    # Single instance only for eval, add a second instance for prod setups
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
                            hostnames    = ["prototype-apix.canadalife.com"]
                          }
                        }
  cicd_cred_file             = "apigee-nprod-ws004-prototype.json"
  terraform_service_account  = "apigee-nprod-ws004-tf-prod@cantech-terraformers.iam.gserviceaccount.com"
}