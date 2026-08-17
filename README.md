# Week 06 – Example 1: Provisioning Azure Infrastructure Using Terraform

## Objective

In this example, you will provision the Azure infrastructure required to deploy the KoalaTech University microservices application using **Terraform**.

Instead of manually creating Azure resources through the Azure Portal or Azure CLI, you will define the infrastructure as code and allow Terraform to provision the required resources automatically.

After the infrastructure has been created successfully, you will deploy the application by following a similar process to that used in __Week 05 – Example 2__.

## Learning Outcomes

After completing this example, you will be able to:

- Explain the concept of Infrastructure as Code (IaC).
- Configure the AzureRM Terraform provider.
- Create reusable Terraform configurations using variables.
- Provision Azure resources using Terraform.
- Validate and apply Terraform configurations.
- View Terraform outputs.
- Destroy Azure infrastructure using Terraform.
- Deploy an existing Kubernetes application to Terraform-provisioned infrastructure.


## System Architecture

The application is deployed to **Azure Kubernetes Service (AKS)** and consists of six application components and five PostgreSQL databases. Each microservice has its own dedicated database to ensure service isolation and independent data management.

The React frontend communicates with an Nginx reverse proxy, which routes incoming requests to the appropriate backend microservice using Kubernetes ClusterIP services. All backend services communicate with their respective PostgreSQL databases through the Kubernetes internal network. Each database stores its data on an Azure managed disk using a Persistent Volume Claim (PVC), ensuring data persists even if a pod is restarted.

The frontend is exposed externally using a Kubernetes **LoadBalancer** service, allowing users to access the application through the public IP address assigned by Azure.

> **Architecture Diagram**
>
> ![AKS Architecture](architecture.png)


## Prerequisites

Before starting this example, ensure the following software is installed:

- Terraform
- Azure CLI
- Docker Desktop
- kubectl
- Git
- Python 3.12 or later

Verify your installation using:

```bash
terraform --version
az --version
docker --version
kubectl version --client
python --version
git --version
```

If all commands return version information without errors, your development environment is ready for this example.


## Running Unit Tests

Before deploying the application, verify that each microservice is functioning correctly by running its unit tests. Repeat the steps as done in `week05/example02`.

## Running the Application with Docker Compose

Before deploying the application to Kubernetes, verify that the complete system is functioning correctly using Docker Compose.

## Configure Terraform Variables

Before creating the infrastructure, open the `terraform.tfvars` file and update the values to match your Azure environment.

At a minimum, update the following variables:

- Azure Container Registry name
- Azure Storage Account name
- AKS cluster name

> **Important:** Azure Storage Account names and Azure Container Registry names must be globally unique.

## Provision Azure Infrastructure

### Step 1: Initialize, Plan and Apply Terraform

Initialize the Terraform working directory, review the execution plan, and apply the configuration as demonstrated in the seminar. 

Terraform will create:

- Resource Group
- Azure Kubernetes Service (AKS)
- Azure Container Registry (ACR)
- Azure Storage Account
- Two Blob Storage containers:
  - `student-profile-photo`
  - `lecturer-profile-photo`
- Required role assignments between AKS and ACR

### Step 2: Verify the Infrastructure

Verify that all Azure resources have been created successfully using either:

- Azure Portal
- Azure CLI, i.e., using the command:

  ```bash
  az resource list \
    --resource-group <resource-group-name> \
    -o table
  ```

## Deploy the Application

Once the infrastructure has been created successfully, deploy the application using a modified version of the process from __Week 05 – Example 2__.

Before starting the deployment:

1. Create and populate the `.env` files in the `student-service` and `lecturer-service` directories with the `AZURE_STORAGE_CONNECTION_STRING` value.

    The connection string can be obtained from the Azure Portal or by using the command:
    
    ```bash
    az storage account show-connection-string \
      --name <storage-account-name> \
      --resource-group <resource-group-name> \
      --query connectionString \
      --output tsv
    ```
2. Build the Docker images for each service.

3. Tag and push the images to the Azure Container Registry (ACR) created by Terraform.
 
4. In the `./kubernetes` directory, update the _Kubernetes deployment manifests_ for both: 
    * The _application secret_ for the `AZURE_STORAGE_CONNECTION_STRING` field; and
    * The _container repository_ references so they point to your Azure Container Registry (i.e., the `<azure-container-registry-url>` field).
 
5. Deploy the application using the process described in __Week 05 – Example 2__.


## Cleaning Up Azure Resources

When you have finished the practical, attempt to destroy all Azure resources created by Terraform:

```bash
terraform destroy
```

Review the execution plan and type "_yes_" when prompted.

> __NOTE on CloudLabs Limitation__: Terraform may report errors when destroying Azure role assignments because student accounts do not have permission to delete RBAC assignments. This does not necessarily indicate that the deployment failed. Verify resource cleanup using the Azure Portal or `az resource list`. If you experience this, try removing the resource from the Terraform State __before__ destroy:
> ```bash
> terraform state rm azurerm_role_assignment.acr_pull
> 
> terraform destroy
> ```
> Terraform will no longer attempt to delete the role assignment. The role assignment will be automatically removed when the _AKS cluster_ is deleted. 