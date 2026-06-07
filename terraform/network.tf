#Облачная сеть develop-cloud
resource "yandex_vpc_network" "develop" {
  name = "develop-${var.flow}"
}

#Подсеть в зоне A
resource "yandex_vpc_subnet" "develop_a" {
  name           = "develop-${var.flow}-ru-central1-a" #Наименование подсети в Облаке
  zone           = "ru-central1-a" #Зона в Облаке
  network_id     = yandex_vpc_network.develop.id #Идентификатор подсети в облаке
  v4_cidr_blocks = ["10.10.1.0/24"] #Сеть на 255 хостов
  route_table_id = yandex_vpc_route_table.rt.id #Привязка таблицы маршрутизации к подсети в Яндекс.Облаке.
}

#Подсеть в zone B
resource "yandex_vpc_subnet" "develop_b" {
  name           = "develop-${var.flow}-ru-central1-b" #
  zone           = "ru-central1-b" #
  network_id     = yandex_vpc_network.develop.id #
  v4_cidr_blocks = ["10.10.2.0/24"] #
  route_table_id = yandex_vpc_route_table.rt.id #
}

#NAT для доступа в интернет
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "develop-${var.flow}-gateway"
  shared_egress_gateway {}
}

