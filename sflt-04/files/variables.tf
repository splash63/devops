
variable "flow" {
  type    = string
  default = "44"
}

variable "conf_vms" {
  type = map(number)
  default = {
    cores         = 2
    memory        = 2
    core_fraction = 100
  }
}