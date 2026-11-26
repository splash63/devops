resource "yandex_lb_network_load_balancer" "lamp" {
  name      = "lamp-nlb"
  folder_id = var.folder_id

  listener {
    name        = "http"
    port        = 80
    target_port = 80

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.lamp["nlb"].load_balancer[0].target_group_id

    healthcheck {
      name                = "http"
      interval            = 5
      timeout             = 2
      healthy_threshold   = 2
      unhealthy_threshold = 2

      http_options {
        port = 80
        path = local.health_path
      }
    }
  }
}

output "nlb_url" {
  value = "http://${one(one(yandex_lb_network_load_balancer.lamp.listener).external_address_spec).address}"
}
