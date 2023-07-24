#declare variables
variable "name" {
  type = string
  default = "lab"
}

variable "resource_group_name" {
  type = string
}

variable "virtual_network_name" {
  type = string
}

variable "address_prefixes" {
    type = list(string)
}
