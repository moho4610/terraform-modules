# terraform foundation
This is a collection of repositories that demonstrates how we can use the the [Google Cloud security foundations guide](https://cloud.google.com/architecture/security-foundations).

Step 0 is manually executed.

## Service Account Creation
1. Added to the group_org_admins group to ensure they have `roles/resourcemanager.projectCreator` access.
   
1. Setup User: (michelle)
For the user who will run the procedures in this document, granted the following roles:
- The roles/resourcemanager.organizationAdmin role on the Google Cloud organization.
- The roles/billing.admin role on the billing account.
- The roles/resourcemanager.folderCreator role.

## POC Setup

### TF Cloud
- workspaces use the CLI workflow
- workspace execution mode is 'local'


```
organisation='michelle-ntt'
workspace='gcp-network-poc'

terraform {
  cloud {
    organization = "michelle-ntt"

    workspaces {
      name = "gcp-network-poc"
    }
  }
}

$env:TF_WORKSPACE="poc"
cd .\gcp-network\environments\poc
terraform init

```

### ADO
```bash
az devops login --organization 'https://dev.azure.com/oaktonbrisbane'
az devops project show --project 'Australian Retirement Trust - Wilderbeast'
az pipelines variable-group create --project 'Australian Retirement Trust - Wilderbeast' --name 'terraform-encryption' --variables 'terraformEncryptionSecret=$%$($'
```

### GCP
```bash
# get list of project ids
gcloud projects list --format='value(project_id)'
# set project by id
export PROJECT_ID="art-gcve-sandpit"
gcloud config set project $PROJECT_ID

# create service account in project
gcloud iam service-accounts create azure-pipelines-publisher --display-name "azure-pipelines-publisher" --project=$PROJECT_ID

# get full email id of new service account
export sa_devops=$(gcloud iam service-accounts list --filter="email:azure-pipelines-publisher" --format='value(email)')
#Add IAM role
gcloud projects add-iam-policy-binding $PROJECT_ID --role roles/owner --member serviceAccount:$sa_devops

# download key for service account
gcloud iam service-accounts keys create ~/azure-pipelines-publisher.json --iam-account $sa_devops





```


From step 1 onwards, the Terraform code is deployed by leveraging either Azure Devops Pipelines.


## Overview
This repo contains several distinct Terraform projects each within their own repository that must be applied separately, but in sequence.

Each of these Terraform projects are to be layered on top of each other, running in the following order.

### [0. bootstrap](./gcp-bootstrap/)

This stage executes the [CFT Bootstrap module](https://github.com/terraform-google-modules/terraform-google-bootstrap) which bootstraps an existing GCP organization, creating all the required GCP resources & permissions to start using the Cloud Foundation Toolkit (CFT).



The bootstrap process includes:
- Azure Devops Repos 
  - Create the azure devops repos
  - Create the azure devops pipeline
  - Create a gcp project `prj-b-seed` 
    - Service Account able to create / modify infrastructure
- Azure Pipelines Secure File `
- Azure Pipelines Variable Group named `terraform-encryption` 
  - Secret variable `terraformEncryptionSecret`
- Azure Pipelines Secure Files
-  `azure-pipelines-publisher.json` to host the gcp credentials key file
- `.terraformrc` to be used by terraform client to authenticate to terraform 
- Azure Pipelines Environments with required approval gates configured
- dev
- test
- prod
-  Terraform Cloud Subscription
   -  Workspaces
      - `gcp-org`
      - `gcp-network`
   -  Team Token to allow ADO to authenticate to terraform cloud. 
   -   This is to be placed in the .terraformrc and uploaded to ADO

```


```


### [1. org](./1-org/)

The purpose of this stage is to set up the common folder used to house projects which contain shared resources such as DNS Hub, Interconnect, SCC Notification, org level secrets, Network Hub and org level logging.

## GCP
This will create the following folder & project structure:

```
example-organization
└── fldr-common
    ├── prj-c-logging
    ├── prj-c-base-net-hub
    ├── prj-c-billing-logs
    ├── prj-c-dns-hub
    ├── prj-c-interconnect
    ├── prj-c-restricted-net-hub
    ├── prj-c-scc
    └── prj-c-secrets
```

## Azure
- Management Groups
- Polices
- Enterprise Scale Core Subscriptions such as Identity, Management and Connectivity
- `Management Subscription`  Services including log management, Azure monitor, System Centre COnfig Manager, Shared Image gallery, Monitor Alerts, third party management tools
- `Identity Subscription` for core platform such as domain control VM's AAD Services.
- `Connectivity` Azure Firewall, Hub VNET etc.
#### Logs

Among the eight projects created under the common folder, two projects (`prj-c-logging`, `prj-c-billing-logs`) are used for logging.
The first one for organization wide audit logs, and the latter for billing logs.
In both cases the logs are collected into BigQuery datasets which can then be used general querying, dashboarding & reporting. Logs are also exported to Pub/Sub and GCS bucket.

**Notes**:

- Log export to GCS bucket has optional object versioning support via `log_export_storage_versioning`.
- The various audit log types being captured in BigQuery are retained for 30 days.
- For billing data, a BigQuery dataset is created with permissions attached, however you will need to configure a billing export [manually](https://cloud.google.com/billing/docs/how-to/export-data-bigquery), as there is no easy way to automate this at the moment.

#### DNS Hub

Another project created under the common folder. This project will host the DNS Hub for the organization.

#### Interconnect

Another project created under the common folder. This project will host the Dedicated Interconnect [Interconnect connection](https://cloud.google.com/network-connectivity/docs/interconnect/concepts/terminology#elements) for the organization. In case of the Partner Interconnect this project is unused and the [VLAN attachments](https://cloud.google.com/network-connectivity/docs/interconnect/concepts/terminology#for-partner-interconnect) will be placed directly into the corresponding Hub projects.

#### SCC Notification

Another project created under the common folder. This project will host the SCC Notification resources at the organization level.
This project will contain a Pub/Sub topic and subscription, a [SCC Notification](https://cloud.google.com/security-command-center/docs/how-to-notifications) configured to send all new Findings to the topic created.
You can adjust the filter when deploying this step.

#### Secrets

Another project created under the common folder. This project is allocated for [GCP Secret Manager](https://cloud.google.com/secret-manager) for secrets shared by the organization.

Usage instructions are available for the org step in the [README](./1-org/README.md).

### [2. environments](./2-environments/)

The purpose of this stage is to set up the environments folders used to house projects which contain monitoring, secrets, networking projects.
This will create the following folder & project structure:

```
example-organization
└── fldr-development
    ├── prj-d-monitoring
    ├── prj-d-secrets
    ├── prj-d-shared-base
    └── prj-d-shared-restricted
└── fldr-non-production
    ├── prj-n-monitoring
    ├── prj-n-secrets
    ├── prj-n-shared-base
    └── prj-n-shared-restricted
└── fldr-production
    ├── prj-p-monitoring
    ├── prj-p-secrets
    ├── prj-p-shared-base
    └── prj-p-shared-restricted
```

#### Monitoring

Under the environment folder, a project is created per environment (`development`, `non-production` & `production`), which is intended to be used as a [Cloud Monitoring workspace](https://cloud.google.com/monitoring/workspaces) for all projects in that environment.
Please note that creating the [workspace and linking projects](https://cloud.google.com/monitoring/workspaces/create) can currently only be completed through the Cloud Console.
If you have strong IAM requirements for these monitoring workspaces, it is worth considering creating these at a more granular level, such as per business unit or per application.

#### Networking

Under the environment folder, two projects, one for base and another for restricted network, are created per environment (`development`, `non-production` & `production`) which is intended to be used as a [Shared VPC Host project](https://cloud.google.com/vpc/docs/shared-vpc) for all projects in that environment.
This stage only creates the projects and enables the correct APIs, the following [networks stage](./3-networks/) creates the actual Shared VPC networks.

#### Secrets

Under the environment folder, a project is created per environment (`development`, `non-production` & `production`), which is intended to be used by [GCP Secret Manager](https://cloud.google.com/secret-manager) for secrets shared by the environment.

Usage instructions are available for the environments step in the [README](./2-environments/README.md).

### [3. networks](./3-networks/)
--Platform Team

### [4. projects](./4-projects/)
--Application Teams
This step is focused on creating service projects with a standard configuration that are attached to the Shared VPC created in the previous step and application infrastructure pipelines.
Running this code as-is should generate a structure as shown below:

```
example-organization/
└── fldr-development
    ├── prj-bu1-d-env-secrets
    ├── prj-bu1-d-sample-floating
    ├── prj-bu1-d-sample-base
    ├── prj-bu1-d-sample-restrict
    ├── prj-bu1-d-sample-peering
    ├── prj-bu2-d-env-secrets
    ├── prj-bu2-d-sample-floating
    ├── prj-bu2-d-sample-base
    ├── prj-bu2-d-sample-restrict
    └── prj-bu2-d-sample-peering
└── fldr-non-production
    ├── prj-bu1-n-env-secrets
    ├── prj-bu1-n-sample-floating
    ├── prj-bu1-n-sample-base
    ├── prj-bu1-n-sample-restrict
    ├── prj-bu1-n-sample-peering
    ├── prj-bu2-n-env-secrets
    ├── prj-bu2-n-sample-floating
    ├── prj-bu2-n-sample-base
    ├── prj-bu2-n-sample-restrict
    └── prj-bu2-n-sample-peering
└── fldr-production
    ├── prj-bu1-p-env-secrets
    ├── prj-bu1-p-sample-floating
    ├── prj-bu1-p-sample-base
    ├── prj-bu1-p-sample-restrict
    ├── prj-bu1-p-sample-peering
    ├── prj-bu2-p-env-secrets
    ├── prj-bu2-p-sample-floating
    ├── prj-bu2-p-sample-base
    ├── prj-bu2-p-sample-restrict
    └── prj-bu2-p-sample-peering
└── fldr-common
    ├── prj-bu1-c-infra-pipeline
    └── prj-bu2-c-infra-pipeline
```

The code in this step includes two options for creating projects.
The first is the standard projects module which creates a project per environment, and the second creates a standalone project for one environment.
If relevant for your use case, there are also two optional submodules which can be used to create a subnet per project, and a dedicated private DNS zone per project.

Usage instructions are available for the projects step in the [README](./4-projects/README.md).

### [5. app-infra](./5-app-infra/)

The purpose of this step is to deploy a simple [Compute Engine](https://cloud.google.com/compute/) instance in one of the business unit projects using the infra pipeline set up in 4-projects.

Usage instructions are available for the app-infra step in the [README](./5-app-infra/README.md).

### Final View

Once all steps above have been executed your GCP organization should represent the structure shown below, with projects being the lowest nodes in the tree.

```
example-organization
└── fldr-common
    ├── prj-c-logging
    ├── prj-c-base-net-hub
    ├── prj-c-billing-logs
    ├── prj-c-dns-hub
    ├── prj-c-interconnect
    ├── prj-c-restricted-net-hub
    ├── prj-c-scc
    ├── prj-c-secrets
    ├── prj-bu1-c-infra-pipeline
    └── prj-bu2-c-infra-pipeline
└── fldr-development
    ├── prj-bu1-d-env-secrets
    ├── prj-bu1-d-sample-floating
    ├── prj-bu1-d-sample-base
    ├── prj-bu1-d-sample-restrict
    ├── prj-bu1-d-sample-peering
    ├── prj-bu2-d-env-secrets
    ├── prj-bu2-d-sample-floating
    ├── prj-bu2-d-sample-base
    ├── prj-bu2-d-sample-restrict
    ├── prj-bu2-d-sample-peering
    ├── prj-d-monitoring
    ├── prj-d-secrets
    ├── prj-d-shared-base
    └── prj-d-shared-restricted
└── fldr-non-production
    ├── prj-bu1-n-env-secrets
    ├── prj-bu1-n-sample-floating
    ├── prj-bu1-n-sample-base
    ├── prj-bu1-n-sample-restrict
    ├── prj-bu1-n-sample-peering
    ├── prj-bu2-n-env-secrets
    ├── prj-bu2-n-sample-floating
    ├── prj-bu2-n-sample-base
    ├── prj-bu2-n-sample-restrict
    ├── prj-bu2-n-sample-peering
    ├── prj-n-monitoring
    ├── prj-n-secrets
    ├── prj-n-shared-base
    └── prj-n-shared-restricted
└── fldr-production
    ├── prj-bu1-p-env-secrets
    ├── prj-bu1-p-sample-floating
    ├── prj-bu1-p-sample-base
    ├── prj-bu1-p-sample-restrict
    ├── prj-bu1-p-sample-peering
    ├── prj-bu2-p-env-secrets
    ├── prj-bu2-p-sample-floating
    ├── prj-bu2-p-sample-base
    ├── prj-bu2-p-sample-restrict
    ├── prj-bu2-p-sample-peering
    ├── prj-p-monitoring
    ├── prj-p-secrets
    ├── prj-p-shared-base
    └── prj-p-shared-restricted
└── fldr-bootstrap
    ├── prj-b-cicd
    └── prj-b-seed
```

### Branching strategy

There are three main named branches - `development`, `non-production` and `production` that reflect the corresponding environments. These branches should be [protected](https://docs.github.com/en/github/administering-a-repository/about-protected-branches). When the CI/CD pipeline (Jenkins/CloudBuild) runs on a particular named branch (say for instance `development`), only the corresponding environment (`development`) is applied. An exception is the `shared` environment which is only applied when triggered on the `production` branch. This is because any changes in the `shared` environment may affect resources in other environments and can have adverse effects if not validated correctly.

Development happens on feature/bugfix branches (which can be named `feature/new-foo`, `bugfix/fix-bar`, etc.) and when complete, a [pull request (PR)](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests) or [merge request (MR)](https://docs.gitlab.com/ee/user/project/merge_requests/) can be opened targeting the `development` branch. This will trigger the CI pipeline to perform a plan and validate against all environments (`development`, `non-production`, `shared` and `production`). Once code review is complete and changes are validated, this branch can be merged into `development`. This will trigger a CI pipeline that applies the latest changes in the `development` branch on the `development` environment.

Once validated in `development`, changes can be promoted to `non-production` by opening a PR/MR targeting the `non-production` branch and merging them. Similarly, changes can be promoted from `non-production` to `production`.

### Terraform-validator

This repo uses [terraform-validator](https://github.com/GoogleCloudPlatform/terraform-validator) to validate the terraform plans against a [library of GCP policies](https://github.com/GoogleCloudPlatform/policy-library).

The [Scorecard bundle](https://github.com/GoogleCloudPlatform/policy-library/blob/master/docs/bundles/scorecard-v1.md) was used to create the [policy-library folder](./policy-library) with [one extra constraint](https://github.com/GoogleCloudPlatform/policy-library/blob/master/samples/serviceusage_allow_basic_apis.yaml) added.

See the [policy-library documentation](https://github.com/GoogleCloudPlatform/policy-library/blob/master/docs/index.md) if you need to add more constraints from the [samples folder](https://github.com/GoogleCloudPlatform/policy-library/tree/master/samples) in your configuration based in your type of workload.

Step 1-org has instructions on the creation of the shared repository to host these policies.

### Optional Variables

Some variables used to deploy the steps have default values, check those **before deployment** to ensure they match your requirements. For more information, there are tables of inputs and outputs for the Terraform modules, each with a detailed description of their variables. Look for variables marked as **not required** in the section **Inputs** of these READMEs:

- Step 0-bootstrap: If you are using Cloud Build in the CICD pipeline, check the main [README](./0-bootstrap/README.md#Inputs) of the step. If you are using Jenkins, check the [README](./0-bootstrap/modules/jenkins-agent/README.md#Inputs) of the module `jenkins-agent`.
- Step 1-org: The [README](./1-org/envs/shared/README.md#Inputs) of the module `shared`.
- Step 2-environments: The README's of the environments [development](./2-environments/envs/development/README.md#Inputs), [non-production](./2-environments/envs/non-production/README.md#Inputs) and [production](./2-environments/envs/production/README.md#Inputs)
- Step 3-networks: The README's of the environments [development](./3-networks/envs/development/README.md#Inputs), [non-production](./3-networks/envs/non-production/README.md#Inputs) and [production](./3-networks/envs/production/README.md#Inputs)
- Step 4-projects: The README's of the environments [development](./4-projects/business_unit_1/development/README.md#Inputs), [non-production](./4-projects/business_unit_1/non-production/README.md#Inputs) and [production](./4-projects/business_unit_1/production/README.md#Inputs)


