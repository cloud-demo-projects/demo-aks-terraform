# declare variables
variable "name" {
  type = string
}

variable "location" {
  type = string
  default = "westeurope"
}

variable "resource_group_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "default_pool_name" {
  type = string
}

variable "user_assigned_identity_id" {
  type = string
}

variable "enable_azure_active_directory" {
  type = bool
}

variable "rbac_aad_managed" {
  type = bool
}

variable "rbac_aad_admin_group_object_ids" {
  type = list(string)
}

variable "private_dns_zone_id" {
  type = string
}

variable "node_resource_group" {
    type = string
}

variable "private_cluster_enabled" {
    type = bool
}

variable "availability_zones" {
    type = list(string)
}

variable "enable_auto_scaling" {
    type = bool
}

variable "max_pods" {
    type = string
}

variable "orchestrator_version" {
    type = string
}

variable "max_count" {
    type = string
}

variable "min_count" {
    type = string
}

variable "node_count" {
    type = string
}

variable "vnet_subnet_id" {
  type = string
}

variable "enable_log_analytics_workspace" {
  type = bool
}

variable "network_plugin" {
  type = string
}

variable "network_policy" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "only_critical_addons_enabled" {
  type = bool
}

variable "log_analytics_workspace_name" {
  type = string
  default = "aks-log-analytics-workspace-lab"
}

variable "log_analytics_workspace_location" {
  type = string
  default = "westeurope"
}

variable "log_analytics_workspace_sku" {
  type = string
  default = "PerGB2018"
}


variable "node_pools" {
  type = list(object({
    name                 = string
    availability_zones   = optional(list(string))
    enable_auto_scaling  = optional(bool)
    max_pods             = number
    orchestrator_version = string
    priority             = string
    max_count            = optional(number)
    min_count            = optional(number)
    node_count           = number
    eviction_policy      = optional(string)
    spot_max_price       = optional(string)
    node_labels          = optional(map(string))
    node_taints          = optional(list(string))
  }))

  default = [{
      name = null
      availability_zones    = null
      enable_auto_scaling   = false
      max_pods              = null
      orchestrator_version  = null
      priority              = null
      min_count             = null
      max_count             = null
      node_count            = null
      eviction_policy       = null
      spot_max_price        = null
      node_labels           = null
      node_taints           = null
    }]
}

variable "tags" {
  type = map(string)
  default = {
    environment = "lab"
    costcenter = "it"
  }
}

