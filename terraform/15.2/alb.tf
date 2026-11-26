resource "yandex_vpc_security_group" "alb" {
  count      = var.enable_alb ? 1 : 0
  name       = "lamp-alb-listener"
  network_id = yandex_vpc_network.lab.id

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol          = "TCP"
    port              = 30080
    predefined_target = "loadbalancer_healthchecks"
  }

  egress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = yandex_vpc_subnet.public.v4_cidr_blocks
  }
}

resource "yandex_alb_backend_group" "lamp" {
  count = var.enable_alb ? 1 : 0
  name  = "lamp-http-backends"

  http_backend {
    name             = "lamp"
    port             = 80
    weight           = 1
    target_group_ids = [yandex_compute_instance_group.lamp["alb"].application_load_balancer[0].target_group_id]

    healthcheck {
      interval            = "5s"
      timeout             = "2s"
      healthy_threshold   = 2
      unhealthy_threshold = 2
      healthcheck_port    = 80

      http_healthcheck {
        path = local.health_path
      }
    }
  }
}

resource "yandex_alb_http_router" "lamp" {
  count = var.enable_alb ? 1 : 0
  name  = "lamp-http-router"
}

resource "yandex_alb_virtual_host" "lamp" {
  count          = var.enable_alb ? 1 : 0
  name           = "lamp"
  http_router_id = yandex_alb_http_router.lamp[0].id

  route {
    name = "lamp"

    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.lamp[0].id
      }
    }
  }
}

resource "yandex_alb_load_balancer" "lamp" {
  count              = var.enable_alb ? 1 : 0
  name               = "lamp-alb"
  network_id         = yandex_vpc_network.lab.id
  security_group_ids = [yandex_vpc_security_group.alb[0].id]

  allocation_policy {
    location {
      zone_id   = var.zone
      subnet_id = yandex_vpc_subnet.public.id
    }
  }

  listener {
    name = "http"

    endpoint {
      ports = [80]

      address {
        external_ipv4_address {}
      }
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.lamp[0].id
      }
    }
  }

  depends_on = [yandex_alb_virtual_host.lamp]
}

output "alb_url" {
  value = var.enable_alb ? "http://${yandex_alb_load_balancer.lamp[0].listener[0].endpoint[0].address[0].external_ipv4_address[0].address}" : null
}
