#Блок основных параметров сети в облаке

#Основная сеть
resource "yandex_vpc_network" "develop" {
  name = "develop-${var.flow}"
}

#Подсеть в зоне A
resource "yandex_vpc_subnet" "develop_a" {
  name           = "develop-${var.flow}-ru-central1-a" #Наименование подсети в Облаке
  zone           = "ru-central1-a" #Зона А в Облаке
  network_id     = yandex_vpc_network.develop.id #Идентификатор подсети в облаке
  v4_cidr_blocks = ["10.10.1.0/24"] # Сеть на 255 хостов
  route_table_id = yandex_vpc_route_table.rt.id #Привязка таблицы маршрутизации к подсети в Яндекс.Облаке
}

#Подсеть в zone B
resource "yandex_vpc_subnet" "develop_b" {
  name           = "develop-${var.flow}-ru-central1-b" #аименование подсети в Облаке
  zone           = "ru-central1-b" # #Зона В в Облаке
  network_id     = yandex_vpc_network.develop.id #Идентификатор подсети в облаке
  v4_cidr_blocks = ["10.10.2.0/24"] # Сеть на 255 хостов
  route_table_id = yandex_vpc_route_table.rt.id #Привязка таблицы маршрутизации к подсети в Яндекс.Облаке
}

#NAT для доступа в интернет
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "develop-${var.flow}-gateway"
  shared_egress_gateway {}
}

#Маршрут для выхода в интернет через NAT
resource "yandex_vpc_route_table" "rt" {
  name       = "route-table-${var.flow}"
  network_id = yandex_vpc_network.develop.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

#Далее настройки сети для ВМ в облаке

#Настройки сети для Bastion. Подключение разрешено только по SSH, 22 порту 

#Создание группы безопасноти
resource "yandex_vpc_security_group" "bastion-sg" {
  name       = "bastion-sg-${var.flow}"
  network_id = yandex_vpc_network.develop.id

#Какой трафик можно принимать (ingress)
  ingress {
    description    = "Allow SSH"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
    port           = 22 #Подключения по SSH к бастиону по порту 22 
  }

#Какой трафик можно отправлять (egress). Диапазон портов от 0 до 65535 (ВСЕ порты).
  egress {
    description    = "Permit ANY"
    protocol       = "ANY" #Любым транспортным протоколом
    from_port      = 0 #начальный порт
    to_port        = 65535 #Конечный порт (максимальный номер порта)
    v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
  }
}

# Настройки сети для WEB A & B

#создание группы безопасноти
resource "yandex_vpc_security_group" "web_sg" {
  name       = "web-sg-${var.flow}"
  network_id = yandex_vpc_network.develop.id

#Какой трафик можно принимать (ingress)
  ingress {
    description    = "Allow SSH" #Для доступа к ВМ A & B через Бастион по SSH
    protocol       = "TCP"
    port           = 22 #Подключения по порту 22
    v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
  }

  ingress {
    description    = "Allow HTTPS" # для доступа к ВМ A & B по HTTPS
    protocol       = "TCP"
    port           = 443 #Подключения по порту 443
    v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
  }

  ingress {
    description    = "Allow HTTP" # для доступа к ВМ A & B по HTTP
    protocol       = "TCP"
    port           = 80 #Входящие HTTP-запросы на порт 80
    v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
  }

  ingress {
    description    = "Allow zabbix" #приём метрик от Zabbix-agent
    protocol       = "TCP"
    port           = 10050 #Подключения по порту 10050
    v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
  }

#Какой трафик можно отправлять (egress). Диапазон портов от 0 до 65535 (ВСЕ порты).
  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
   from_port      = 0 #начальный порт
    to_port        = 65535 #Конечный порт (максимальный номер порта)
    v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
  }
}

# Блок Elasticsearch-server

#создание группы безопасноти
resource "yandex_vpc_security_group" "elasticsearch-sg" {
  name       = "elasticsearch-sg-${var.flow}"
  network_id = yandex_vpc_network.develop.id

#Какой трафик можно принимать (ingress)
  ingress {
    description    = "Allow SSH" #Для доступа к ВМ через Бастион по SSH
    protocol       = "TCP" 
    port           = 22 #Подключения по порту 22
    v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
    
  }

  ingress {
    description    = "Allow Elasticsearch" #Доступ к API Elasticsearch по порту 9200
    protocol       = "TCP"
    port           = 9200 #Подключения по порту 9200
    v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
  }

#Какой трафик можно отправлять (egress). Диапазон портов от 0 до 65535 (ВСЕ порты).
  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    from_port      = 0 #начальный порт
    to_port        = 65535 #Конечный порт (максимальный номер порта)
    v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
  }
}

#Настройки сети ВМ Zabbix-server

#создание группы безопасноти
resource "yandex_vpc_security_group" "zabbix-sg" {
  name       = "zabbix-sg-${var.flow}"
  network_id = yandex_vpc_network.develop.id

#Какой трафик можно принимать (ingress)
  ingress {
      description    = "Allow SSH" #Для доступа к ВМ через Бастион по SSH
      protocol       = "TCP"
      port           = 22 #Подключения по порту 22
      v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
    }

  ingress {
    description    = "Allow HTTP" # для доступа к ВМ по HTTP
    protocol       = "TCP"
    port           = 80 #Подключения по порту 80
    v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
  }

  ingress {
    description    = "Allow HTTPS" # для доступа к ВМ по HTTPS
    protocol       = "TCP"
    port           = 443 #Подключения по порту 443
    v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
  }

  ingress {
    description    = "Allow ZABBIX" #приём метрик от Zabbix-agent
    protocol       = "TCP"
    port           = 10050 #Подключения по порту 10050
    v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
  }

#Какой трафик можно отправлять (egress). Диапазон портов от 0 до 65535 (ВСЕ порты).
  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    from_port      = 0 #начальный порт
    to_port        = 65535 #Конечный порт (максимальный номер порта)
    v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
  }
}

# Настройка сети Kibana-server

#создание группы безопасноти
resource "yandex_vpc_security_group" "kibana-sg" {
  name       = "kibana-sg-${var.flow}"
  network_id = yandex_vpc_network.develop.id

#Какой трафик можно принимать (ingress)
  ingress {
      description    = "Allow SSH" #Для доступа к ВМ через Бастион по SSH
      protocol       = "TCP"
      port           = 22 #Подключения по порту 22
      v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
    }

  ingress {
    description    = "Allow HTTP" # для доступа к ВМ по HTTP
    protocol       = "TCP"
    port           = 80 #Подключения по порту 80
    v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
  }

  ingress {
    description    = "Allow HTTPS" # для доступа к ВМ по HTTPS
    protocol       = "TCP"
    port           = 443 #Подключения по порту 443
    v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
  }

  ingress {
    description    = "Allow KIBANA" #доступ к веб-интерфейсу Kibana на стандартном порту 5601 
    protocol       = "TCP"
    port           = 5601 #Подключения по порту 5601
    v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
  }

#Какой трафик можно отправлять (egress). Диапазон портов от 0 до 65535 (ВСЕ порты).
  egress {
    description    = "Permit ANY"
    protocol       = "ANY"
    from_port      = 0 #начальный порт
    to_port        = 65535 #Конечный порт (максимальный номер порта)
    v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
  }
}

# Блок для Application Load Balancer

#создание группы безопасности
resource "yandex_vpc_security_group" "alb-load-balancer-sg" {
  name       = "alb-load-balancer-${var.flow}"
  network_id = yandex_vpc_network.develop.id

#Какой трафик можно принимать (ingress)
  ingress {
    description    = "Allow HTTP"
    protocol       = "TCP" #обмен по TCP
    port           = 80 #Входящие HTTP-запросы на порт 80
    v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
  }

  ingress {
    description    = "Allow different zone"
    protocol       = "TCP"
    port           = 30080 #Порт межзоновое взаимодействие для проверки узлов ALB
    v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
  }

#Какой трафик можно отправлять (egress). Диапазон портов от 0 до 65535 (ВСЕ порты).
  egress {
    description    = "Permit ANY"
    protocol       = "ANY" # Любым транспортным протоколом
    v4_cidr_blocks = ["0.0.0.0/0"] #Из любых IPv4-адресов
    from_port      = 0 #начальный порт
    to_port        = 65535 #Конечный порт (максимальный номер порта)
  }
}

