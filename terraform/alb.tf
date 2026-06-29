# ============================================
# Application Load Balancer
# ============================================

# Целевая группа для ALB
resource "yandex_alb_target_group" "web_target_group" {
  name = "target-group"

  target {
    subnet_id  = yandex_vpc_subnet.develop_a.id
    ip_address = yandex_compute_instance.weba.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.develop_b.id
    ip_address = yandex_compute_instance.webb.network_interface.0.ip_address
  }
}

# Бэкенд группа
resource "yandex_alb_backend_group" "web_backend_group" {
  name = "backend-group"

  http_backend {
    name             = "http-backend"
    port             = 80
    target_group_ids = [yandex_alb_target_group.web_target_group.id]

    healthcheck {
      timeout  = "10s"
      interval = "5s"
      http_healthcheck {
        path              = "/"
        expected_statuses = [200]
      }
    }
  }
}

# HTTP роутер
resource "yandex_alb_http_router" "web_router" {
  name = "web-router"
}

# Виртуальный хост
resource "yandex_alb_virtual_host" "web_vhost" {
  name           = "web-vhost"
  http_router_id = yandex_alb_http_router.web_router.id

  route {
    name = "default-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web_backend_group.id
        timeout          = "5s"
      }
    }
  }
}

# Application Load Balancer
resource "yandex_alb_load_balancer" "alb_load_balancer" {
  name        = "alb-load-balancer"
  network_id  = yandex_vpc_network.develop.id
  security_group_ids = [yandex_vpc_security_group.alb-load-balancer-sg.id]

  depends_on = [
    yandex_alb_target_group.web_target_group,
    yandex_alb_backend_group.web_backend_group,
    yandex_alb_http_router.web_router,
    yandex_alb_virtual_host.web_vhost,
    yandex_compute_instance.weba,
    yandex_compute_instance.webb
  ]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.develop_a.id
    }

    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.develop_b.id
    }
  }

  listener {
    name = "listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web_router.id
      }
    }
  }

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }

  lifecycle {
    create_before_destroy = true
  }
}
