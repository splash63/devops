module "vpc_dev" {
  source         = "./vpc"
  env_name       = "develop"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["10.0.1.0/24"]
}

module "vpc_stage" {
  source         = "./vpc"
  env_name       = "stage"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["10.0.2.0/24"]
}

locals {
  cloudinit_rendered = templatefile("${path.module}/cloud-init.yml", {
    ssh_key = var.public_key
  })
}

module "marketing" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name       = "develop"
  network_id     = module.vpc_dev.network_id
  subnet_zones   = ["ru-central1-a"]
  subnet_ids     = [module.vpc_dev.subnet_id]
  instance_name  = "webs"
  instance_count = 2
  image_family   = "ubuntu-2004-lts"
  public_ip      = false

  labels = {
    owner   = "i.ivanov",
    project = "marketing"
  }

  metadata = {
    user-data          = local.cloudinit_rendered
    serial-port-enable = 1
  }
}

module "analytics" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"
  env_name       = "stage"
  network_id     = module.vpc_stage.network_id
  subnet_zones   = ["ru-central1-a"]
  subnet_ids     = [module.vpc_stage.subnet_id]
  instance_name  = "web-stage"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = {
    project = "analytics"
  }

  metadata = {
    user-data          = local.cloudinit_rendered
    serial-port-enable = 1
  }
}