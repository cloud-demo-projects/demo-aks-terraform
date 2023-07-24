# Demo-AKS-Terraform
Demo AKS Infra setup with terrafom modules

## Features
- Azure AD integration
- Private cluster with private DNS zone
- User Identity (with role assignment to RG and Private DNS)
- Node pools with auto-scale enabled and Availability Zones
- Azure Monitoring
- Azure CNI with calico
- Default Node pool with taints for critical add-ons only

## Software & Tools Used During Exercise
- Terraform v1.5.3
- Provider registry.terraform.io/hashicorp/azuread v2.40.0
- Provider registry.terraform.io/hashicorp/azurerm v3.66.0
- Kubectl Client Version: v1.25.4
- Visual Studio Code editor
- Lens Kubernests IDE
- Azure subscription with contributor rights
