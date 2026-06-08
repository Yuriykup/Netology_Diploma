#Application Load Balancer - сетевого балансировщика

#Целевая группа для ALB. Определены IP адреса WEB серверов
resource "yandex_alb_target_group" "web_target_group" {  # Создание ресурса "целевая группа" с локальным именем web_target_group
  name = "target-group"  # Отображаемое имя целевой группы в облаке

  target {  
    subnet_id          = yandex_vpc_subnet.develop_a.id  # ID подсети, в которой находится первая ВМ (зона А)
    ip_address         = yandex_compute_instance.weba.network_interface.0.ip_address  # Внутренний IP адрес ВМ weba
  }

  target {  
    subnet_id          = yandex_vpc_subnet.develop_b.id  # ID подсети, в которой находится вторая ВМ (зона Б)
    ip_address         = yandex_compute_instance.webb.network_interface.0.ip_address  # Внутренний IP адрес ВМ webb
  }
}

# Создание ресурса "бэкенд группа"
resource "yandex_alb_backend_group" "web_backend_group" {  
  name  =  "backend-group"  # Отображаемое имя бэкенд группы в облаке

  http_backend {
    name                = "http-backend"  # Имя этого бэкенда
    port                = 80  # Порт на целевых ВМ, на который будет направляться трафик (HTTP)
    target_group_ids    = ["${yandex_alb_target_group.web_target_group.id}"]  # ID целевой группы, в которую входят веб-сервера
    
    healthcheck {
      timeout           = "10s"  # Таймаут ожидания ответа от ВМ при проверке здоровья (10 секунд)
      interval          = "5s"  # Интервал между проверками здоровья (каждые 5 секунд)
      healthcheck_port  = 80  # Порт, на котором проверяется здоровье ВМ (HTTP порт 80)
      http_healthcheck {
        path = "/"  # Путь URL для проверки здоровья (корневой путь "/")
      } 
    }
  }
}

# HTTP роутер - правила маршрутизации запросов
resource "yandex_alb_http_router" "web_router" {  
  name = "web-router"  # Отображаемое имя HTTP роутера в облаке
}

# Виртуальный хост - настройки для домена
resource "yandex_alb_virtual_host" "web_vhost" {
  name           = "web-vhost"  # Отображаемое имя виртуального хоста в облаке
  http_router_id = yandex_alb_http_router.web_router.id  # ID HTTP роутера, к которому привязывается этот виртуальный хост
  
  route {
    name = "default-route"  # Имя маршрута
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web_backend_group.id  # ID бэкенд группы, на которую направлять трафик
        timeout          = "5s"  # Таймаут ожидания ответа от бэкенда (5 секунд)
      }
    }
  }
}

# Создание ресурса "Application Load Balancer"
resource "yandex_alb_load_balancer" "alb-load-balancer" {
  name = "alb-load-balancer"  # Отображаемое имя балансировщика в облаке
  network_id = yandex_vpc_network.develop.id  # ID сети, в которой будет размещён балансировщик
  security_group_ids = [yandex_vpc_security_group.alb-load-balancer-sg.id]  # Список ID групп безопасности для балансировщика

  allocation_policy {  #в каких зонах работать
    location {
      zone_id = "ru-central1-a"  # Зона доступности А
      subnet_id = yandex_vpc_subnet.develop_a.id  # ID подсети в зоне А для размещения балансировщика
    }

    location {
      zone_id = "ru-central1-b"  # Зона доступности Б
      subnet_id = yandex_vpc_subnet.develop_b.id  # ID подсети в зоне Б для размещения балансировщика
    } 
  } 

  listener {  #точки входа трафика
    name = "listener"  # Имя слушателя
    endpoint {
      address {
        external_ipv4_address {  # Использовать внешний IPv4 адрес (публичный IP)
        } 
      }
      ports = [80]  # Список портов, на которых принимается трафик (порт 80 - HTTP)
    }
    http { 
      handler {
        http_router_id = yandex_alb_http_router.web_router.id  # ID HTTP роутера, который будет обрабатывать входящие запросы
      } 
    } 
  } 
} 
