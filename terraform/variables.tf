variable "hetzner_region" {
  description = "Hetzner Datacenter"
  type        = string
  default     = "fsn1-dc14"
}

variable "slaves_count" {
  description = "Number of instances to provision."
  type        = number
  default     = 2
}