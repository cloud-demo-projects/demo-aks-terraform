
resource "azuread_group" "k8sadmins" {
  display_name = "Kubernetes Admins"
  members = [
    data.azuread_user.aad.object_id,
  ]
  # mandatory attribute addition
  security_enabled = true
}

module "rg" {
  source  = "./modules/resource-group"

  name     = "rg-${var.identifier}-example"
  location = var.location
}

resource "azurerm_user_assigned_identity" "main" {
  resource_group_name = module.rg.name
  location            = module.rg.location

  name = "identity-${var.identifier}-example"
}

module "vnet" {
  source  = "./modules/virtual-network"

  resource_group_name = module.rg.name
  name                = "vnet-${var.identifier}-example"
  address_space       = ["10.30.0.0/16"]
  # mandatory attribute addition
  location            = module.rg.location

  depends_on = [module.rg]
}

module "subnet" {
  source  = "./modules/subnet"

  name                 = "snet-${var.identifier}-example"
  resource_group_name  = module.rg.name
  virtual_network_name = module.vnet.name
  address_prefixes     = ["10.30.0.0/21"]
}

resource "azurerm_private_dns_zone" "main" {
  # updated file extension to io as per latest guidelines
  name                = "privatelink.westeurope.azmk8s.io"
  resource_group_name = module.rg.name
}

resource "azurerm_role_assignment" "network" {
  scope                = module.rg.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

resource "azurerm_role_assignment" "dns" {
  scope                = azurerm_private_dns_zone.main.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

module "aks" {
  source = "./modules/aks"

  name                = "aks${var.identifier}"
  resource_group_name = module.rg.name
  dns_prefix          = "kaiko-lab"

  default_pool_name = "default"

  user_assigned_identity_id = azurerm_user_assigned_identity.main.id

  enable_azure_active_directory   = true
  rbac_aad_managed                = true
  rbac_aad_admin_group_object_ids = [azuread_group.k8sadmins.object_id]

  private_dns_zone_id = azurerm_private_dns_zone.main.id

  node_resource_group = "aks-${var.identifier}-example"

  private_cluster_enabled = true

  availability_zones   = ["1", "2", "3"]
  enable_auto_scaling  = true
  max_pods             = 100
  orchestrator_version = "1.26.3"
  vnet_subnet_id       = module.subnet.id
  max_count            = 3
  min_count            = 1
  node_count           = 1

  enable_log_analytics_workspace = true

  network_plugin = "azure"
  network_policy = "calico"

  kubernetes_version = "1.26.3"

  only_critical_addons_enabled = true

  node_pools = [
    {
      # modilefied name: the "name" must begin with a lowercase letter, contain only lowercase letters and numbers and be between 1 and 12 characters in length
      name                 = "genericapps"
      availability_zones   = ["1", "2", "3"]
      enable_auto_scaling  = true
      max_pods             = 100
      orchestrator_version = "1.26.3"
      priority             = "Regular"
      max_count            = 3
      min_count            = 1
      node_count           = 1
    },
    {
      # modilefied name: the "name" must begin with a lowercase letter, contain only lowercase letters and numbers and be between 1 and 12 characters in length
      name                 = "genericspot"
      max_pods             = 100
      orchestrator_version = "1.26.3"
      priority             = "Spot"
      eviction_policy      = "Delete"
      spot_max_price       = 0.5 # note: this is the "maximum" price
      node_labels = {
        "kubernetes.azure.com/scalesetpriority" = "spot"
      }
      node_taints = [
        "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
      ]
      node_count = 1
    }
  ]

  tags = {
    "ManagedBy" = "Terraform"
  }

  depends_on = [
    module.rg,
    azurerm_role_assignment.dns,
    azurerm_role_assignment.network
  ]
}