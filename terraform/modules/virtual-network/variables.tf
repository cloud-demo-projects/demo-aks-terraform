#declare variables
variable "name" {
  type = string
  default = "lab"
}

variable "address_space" {
  type = list(string)
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}
