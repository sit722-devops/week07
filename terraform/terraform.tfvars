location            = "Australia East"
resource_group_name = "koalatech-week06-rg"

# Replace with a unique name for your Azure Container Registry 
acr_name             = "UNIQUE_ACR_NAME"

# Replace with a unique name for your Azure Storage Account
storage_account_name = "STORAGE_ACCOUNT_NAME"

# Replace with a unique name for your Azure Kubernetes Service cluster
aks_cluster_name = "AZURE_K8S_CLUSTER_NAME"
aks_dns_prefix   = "koalatech"

aks_node_count   = 2
aks_node_vm_size = "Standard_D2s_v3"

environment = "development"

tags = {
    Project    = "KoalaTech Course Platform"
    ManagedBy  = "Terraform"
    Practical  = "Week06"
    Environment = "Development"
}