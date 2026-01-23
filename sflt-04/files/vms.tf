data "yandex_compute_image" "ubuntu_2404_lts" {
  family = "ubuntu-2404-lts-oslogin"
}

resource "yandex_compute_instance" "srv" {
  count = 2
  name        = "srv${count.index}"
  hostname    = "srv${count.index}"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = var.conf_vms.cores
    memory        = var.conf_vms.memory
    core_fraction = var.conf_vms.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2404_lts.image_id
      type     = "network-ssd"
      size     = 20
    }
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop_a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.LAN.id, yandex_vpc_security_group.web_sg.id]
  }
}