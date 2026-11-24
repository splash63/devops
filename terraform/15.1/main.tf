terraform {
  required_version = ">= 1.3"

  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  folder_id = var.folder_id
  zone      = var.zone
}

variable "folder_id" {
  type = string
}

variable "zone" {
  type    = string
  default = "ru-central1-a"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/authorized_keys"
}

variable "admin_cidr" {
  description = "Публичный IPv4 компьютера, с которого выполняется SSH, в формате x.x.x.x/32."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.admin_cidr)) && endswith(var.admin_cidr, "/32")
    error_message = "Укажите один публичный IPv4 в формате x.x.x.x/32."
  }
}

resource "yandex_vpc_network" "lab" {
  name = "nat-lab-vpc"
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = var.zone
  network_id     = yandex_vpc_network.lab.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = var.zone
  network_id     = yandex_vpc_network.lab.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.private.id
}

resource "yandex_vpc_route_table" "private" {
  name       = "private-via-nat"
  network_id = yandex_vpc_network.lab.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat.network_interface[0].ip_address
  }
}

locals {
  machines = {
    nat = {
      private_ip  = "192.168.10.254"
      external_ip = true
      ingress     = "192.168.20.0/24"
      protocol    = "ANY"
      port        = null
    }
    public = {
      private_ip  = "192.168.10.10"
      external_ip = true
      ingress     = var.admin_cidr
      protocol    = "TCP"
      port        = 22
    }
    private = {
      private_ip  = "192.168.20.10"
      external_ip = false
      ingress     = "192.168.10.10/32"
      protocol    = "TCP"
      port        = 22
    }
  }
}

resource "yandex_vpc_security_group" "vm" {
  for_each   = local.machines
  name       = "nat-lab-${each.key}"
  network_id = yandex_vpc_network.lab.id

  ingress {
    protocol       = each.value.protocol
    port           = each.value.port
    v4_cidr_blocks = [each.value.ingress]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

data "yandex_compute_image" "ubuntu" {
  family    = "ubuntu-2404-lts"
  folder_id = "standard-images"
}

resource "yandex_compute_instance" "nat" {
  name        = "nat-instance"
  zone        = var.zone
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
      type     = "network-hdd"
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    ip_address         = local.machines.nat.private_ip
    nat                = true
    security_group_ids = [yandex_vpc_security_group.vm["nat"].id]
  }

  metadata = {
    ssh-keys = "ubuntu:${trimspace(file(pathexpand(var.ssh_public_key_path)))}"
  }
}

resource "yandex_compute_instance" "vm" {
  for_each    = { for name, config in local.machines : name => config if name != "nat" }
  name        = "${each.key}-vm"
  zone        = var.zone
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type     = "network-hdd"
      size     = 20
    }
  }

  network_interface {
    subnet_id          = each.key == "public" ? yandex_vpc_subnet.public.id : yandex_vpc_subnet.private.id
    ip_address         = each.value.private_ip
    nat                = each.value.external_ip
    security_group_ids = [yandex_vpc_security_group.vm[each.key].id]
  }

  metadata = {
    user-data = "#cloud-config\n${yamlencode({
      users = [{
        name                = "ubuntu"
        shell               = "/bin/bash"
        ssh_authorized_keys = [trimspace(file(pathexpand(var.ssh_public_key_path)))]
      }]
    })}"
  }
}

output "public_vm_ip" {
  value = yandex_compute_instance.vm["public"].network_interface[0].nat_ip_address
}

output "private_vm_ip" {
  value = yandex_compute_instance.vm["private"].network_interface[0].ip_address
}

output "nat_public_ip" {
  value = yandex_compute_instance.nat.network_interface[0].nat_ip_address
}
