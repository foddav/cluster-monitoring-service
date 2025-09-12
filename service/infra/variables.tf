variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "cluster_name" {
  type    = string
  default = "cv-monitoring-cluster"
}

variable "cluster_version" {
  type    = string
  default = "1.33"
}

variable "node_instance_type" {
  type    = string
  default = "t3.small"
}

variable "node_group_desired_capacity" {
  type    = number
  default = 1
}
