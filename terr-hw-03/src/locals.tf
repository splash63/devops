locals {
  vm_names = {
    web = "netology-${var.vpc_name}-${var.default_zone}-web"
    db  = "netology-${var.vpc_name}-${var.vm_db_zone}-db"
  }
}