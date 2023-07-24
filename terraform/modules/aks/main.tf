
resource "azurerm_log_analytics_workspace" "lws" {
    name                = var.log_analytics_workspace_name
    location            = var.log_analytics_workspace_location
    resource_group_name = var.resource_group_name
    sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                    = var.name
  location                = var.location
  resource_group_name     = var.resource_group_name
  dns_prefix              = var.dns_prefix
  kubernetes_version      = var.kubernetes_version
  private_cluster_enabled = var.private_cluster_enabled
  private_dns_zone_id     = var.private_dns_zone_id
  node_resource_group     = var.node_resource_group

  default_node_pool {
    name                 = var.default_pool_name
    node_count           = var.node_count
    vm_size              = "Standard_D2_v2"
    orchestrator_version = var.orchestrator_version
    enable_auto_scaling  = var.enable_auto_scaling
    max_pods             = var.max_pods
    min_count            = var.min_count
    max_count            = var.max_count
    type                 = "VirtualMachineScaleSets"
    zones                = ["1", "2", "3"]
    only_critical_addons_enabled = var.only_critical_addons_enabled
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      var.user_assigned_identity_id
    ]
  }

  azure_active_directory_role_based_access_control {
    managed = var.enable_azure_active_directory
    admin_group_object_ids = var.rbac_aad_admin_group_object_ids
    azure_rbac_enabled = var.rbac_aad_managed
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.lws.id
  }

  network_profile {
    network_plugin = var.network_plugin
    network_policy = var.network_policy
  }

  tags = var.tags
}


resource "azurerm_kubernetes_cluster_node_pool" "nodepool" {

  for_each = {for np in var.node_pools : np.name => np}

  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  node_count            = each.value.node_count
  vm_size               = "Standard_DS2_v2"
  orchestrator_version  = var.orchestrator_version
  zones                 = each.value.availability_zones
  max_pods              = each.value.max_pods
  priority              = each.value.priority
  eviction_policy       = each.value.priority == "Spot" ? each.value.eviction_policy : null
  spot_max_price        = each.value.priority == "Spot" ? each.value.spot_max_price : null
  node_labels           = each.value.priority == "Spot" ? each.value.node_labels : null
  node_taints           = each.value.priority == "Spot" ? each.value.node_taints : null
  enable_auto_scaling   = each.value.enable_auto_scaling != null ? each.value.enable_auto_scaling : false
  min_count             = each.value.enable_auto_scaling == true ? each.value.min_count : null
  max_count             = each.value.enable_auto_scaling == true ? each.value.max_count : null
}