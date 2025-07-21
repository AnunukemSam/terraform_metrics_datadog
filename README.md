# Provisioning AKS with Metrics Server and Datadog using Terraform + Helm

## 📌 Project Overview

This project automates the provisioning of an **Azure Kubernetes Service (AKS)** cluster and the deployment of observability tools using **Terraform** and **Helm**. The project is part of a DevOps assessment and includes the following key components:

* AKS Cluster provisioned using Terraform
* Metrics Server deployed via Helm (Terraform-managed)
* Datadog Agent deployed via Helm (Terraform-managed)
* Secure secret handling for Datadog API key
* Best practices in infrastructure as code and Kubernetes monitoring

---

## 🧰 Tools Used

| Tool      | Purpose                       |
| --------- | ----------------------------- |
| Terraform | Infrastructure automation     |
| Azure CLI | Authentication and AKS access |
| kubectl   | Kubernetes interaction        |
| Helm      | Kubernetes package manager    |
| Datadog   | Cloud observability           |

---

## 📁 Folder Structure

```
devops-assessment/
└── task-1-kubernetes/
    ├── provider.tf
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── terraform.tfvars             # Contains sensitive API key (NOT pushed to GitHub)
    ├── .gitignore
    ├── README.md
    └── helm/
        ├── metrics_server.tf
        ├── datadog_agent.tf
        ├── metrics-values.yaml
        └── datadog-values.yaml.tpl
```

---

## 🚀 Step-by-Step Setup Instructions

### 🔐 1. Prerequisites

* Azure CLI installed and logged in (`az login`)
* Terraform installed
* Helm installed
* kubectl installed
* Datadog account with an API key

---

### ⚙️ 2. Provider Configuration – `provider.tf`

```hcl
provider "azurerm" {
  features {}
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
```

---

### 📦 3. Declare Variables – `variables.tf`

```hcl
variable "location" {
  default = "East US"
}

variable "resource_group_name" {
  default = "aks-devops-rg"
}

variable "vnet_name" {
  default = "aks-vnet"
}

variable "subnet_name" {
  default = "aks-subnet"
}

variable "datadog_api_key" {
  description = "Datadog API key"
  sensitive   = true
}
```

---

### 🧱 4. Define Infrastructure – `main.tf`

```hcl
resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/8"]
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.240.0.0/16"]
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "devops-aks-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "devops-aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  kubernetes_version = "1.29.2"

  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "standard"
  }

  tags = {
    environment = "dev"
  }
}
```

---

### 🧾 5. Output Values – `outputs.tf`

```hcl
output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}
```

---

### 📌 6. Sensitive Info – `terraform.tfvars`

```hcl
datadog_api_key = "your_real_api_key_here"
```

> ⚠️ Add this file to `.gitignore`

---

### 🧰 7. Install Metrics Server – `helm/metrics_server.tf`

```hcl
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.12.1"

  namespace = "kube-system"
  create_namespace = false

  values = [
    file("${path.module}/metrics-values.yaml")
  ]

  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
}
```

### 🧾 `metrics-values.yaml`

```yaml
args:
  - --kubelet-insecure-tls
  - --kubelet-preferred-address-types=InternalIP
```

📍 **Note:** In our case, Metrics Server was already installed in the cluster by AKS. We confirmed it using:

```bash
kubectl top nodes
```

---

### 🐶 8. Install Datadog Agent – `helm/datadog_agent.tf`

```hcl
resource "helm_release" "datadog" {
  name       = "datadog"
  repository = "https://helm.datadoghq.com"
  chart      = "datadog"
  version    = "3.63.0"
  namespace  = "datadog"
  create_namespace = true

  values = [
    templatefile("${path.module}/datadog-values.yaml.tpl", {
      datadog_api_key = var.datadog_api_key
    })
  ]

  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
}
```

### 🧾 `datadog-values.yaml.tpl`

```yaml
datadog:
  apiKey: "${datadog_api_key}"
  site: datadoghq.com

  logs:
    enabled: true

  apm:
    enabled: true

  processAgent:
    enabled: true

agents:
  enabled: true
```

---

## ✅ Verifying Setup

### 🌐 Connect to Cluster:

```bash
az aks get-credentials --resource-group aks-devops-rg --name devops-aks-cluster
```

### 📈 Metrics Server Check:

```bash
kubectl top nodes
```

### 🐾 Datadog Check:

```bash
kubectl get pods -n datadog
```

Log into [https://app.datadoghq.com](https://app.datadoghq.com) and verify your agent is sending metrics.

---

## 🛡️ .gitignore Example

```gitignore
.terraform/
terraform.tfstate*
*.tfvars
*.yaml.tpl
```

---

## ✅ Task Complete!

You've:

* Provisioned a fully working AKS cluster with Terraform
* Validated Metrics Server setup
* Deployed the Datadog agent with secure API key injection
* Followed best practices for secrets, structure, and automation

> 📁 Push only the safe, necessary files to GitHub. Document your API key handling carefully.


# terraform_metrics_datadog
