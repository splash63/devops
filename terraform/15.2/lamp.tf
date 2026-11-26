variable "lamp_image_id" {
  type    = string
  default = "fd827b91d99psvq5fjit"
}

variable "enable_alb" {
  type    = bool
  default = false
}

locals {
  lamp_groups = toset(concat(["nlb"], var.enable_alb ? ["alb"] : []))
  lamp_roles  = toset(concat(["compute.editor", "load-balancer.editor"], var.enable_alb ? ["alb.editor"] : []))
  health_path = "/healthz"
}

resource "yandex_iam_service_account" "lamp" {
  name      = "lamp-instance-groups"
  folder_id = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "lamp" {
  for_each  = local.lamp_roles
  folder_id = var.folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.lamp.id}"
}

resource "yandex_vpc_security_group" "lamp" {
  for_each   = local.lamp_groups
  name       = "lamp-${each.key}-vm"
  network_id = yandex_vpc_network.lab.id

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = each.key == "nlb" ? ["0.0.0.0/0"] : yandex_vpc_subnet.public.v4_cidr_blocks
  }

  ingress {
    protocol          = "TCP"
    port              = 80
    predefined_target = "loadbalancer_healthchecks"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_instance_group" "lamp" {
  for_each                     = local.lamp_groups
  name                         = "lamp-${each.key}"
  folder_id                    = var.folder_id
  service_account_id           = yandex_iam_service_account.lamp.id
  max_checking_health_duration = 300

  instance_template {
    platform_id = "standard-v3"
    hostname    = "lamp-${each.key}-{instance.short_id}"

    resources {
      cores         = 2
      memory        = 2
      core_fraction = 20
    }

    boot_disk {
      mode = "READ_WRITE"

      initialize_params {
        image_id = var.lamp_image_id
        type     = "network-hdd"
        size     = 20
      }
    }

    network_interface {
      network_id         = yandex_vpc_network.lab.id
      subnet_ids         = [yandex_vpc_subnet.public.id]
      security_group_ids = [yandex_vpc_security_group.lamp[each.key].id]
      nat                = false
    }

    metadata = {
      user-data = "#cloud-config\n${yamlencode({
        write_files = [{
          path        = "/var/www/html/index.html"
          owner       = "root:root"
          permissions = "0644"
          content     = templatefile("${path.module}/assets/index.html.tftpl", { picture_url = local.picture_url })
        }]
        runcmd = [["sh", "-ec", <<-BOOTSTRAP
          sed -i "s/__INSTANCE_HOSTNAME__/$(hostname)/g" /var/www/html/index.html
          rm -f /var/www/html/index.php
          systemctl enable --now apache2
          printf 'ok\n' > /var/www/html/healthz
        BOOTSTRAP
        ]]
      })}"
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.zone]
  }

  deploy_policy {
    max_unavailable  = 1
    max_expansion    = 0
    startup_duration = 60
  }

  health_check {
    interval            = 10
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 3

    http_options {
      port = 80
      path = local.health_path
    }
  }

  dynamic "load_balancer" {
    for_each = each.key == "nlb" ? [1] : []

    content {
      target_group_name    = "lamp-nlb-targets"
      ignore_health_checks = true
    }
  }

  dynamic "application_load_balancer" {
    for_each = each.key == "alb" ? [1] : []

    content {
      target_group_name    = "lamp-alb-targets"
      ignore_health_checks = true
    }
  }

  depends_on = [yandex_resourcemanager_folder_iam_member.lamp]
}

output "lamp_nlb_group_id" {
  value = yandex_compute_instance_group.lamp["nlb"].id
}
