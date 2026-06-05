#ОС - оперсационная система
#ЖД - жесткий диск
#ВМ - виртуальная машина
#FQDN - полное доменное имя хоста

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "default-ru-central1-a"
}

# Данные об ОС Ubuntu 22.04
data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
} 

# Блок создания ВМ Бастион
# ЖД для bastion
resource "yandex_compute_disk" "bastion-disk" {
  name     = "bastion-disk" #Имя диска
  type     = "network-hdd" #Тип ЖД (бюджетный вариант)
  zone     = "default-ru-central1-a" #Зона доступности
  size     = "10" #Объем ЖД
  image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id #ОС Ubuntu 22.04 LTS, взятая из стандартного образа Yandex Cloud
} 
    
# Параметры для запуска ВМ Бастион
resource "yandex_compute_instance" "bastion" {
  name        = "bastion" #Имя ВМ в облаке Яндекс
  hostname    = "bastion" #Имя хоста для формирования FQDN
  platform_id = "standard-v3" # Платформа (аппаратная конфигурация) с процессорами Intel Ice Lake
  zone        = "default-ru-central1-a" #важно, чтобы зона ВМ совпадала с зоной subnet и диска — иначе подключение невозможно.

# Выделяемые вычислительные ресурсы для ВМ Бастион
  resources {
    cores         = 2 #2 виртуальных процессора (vCPU)
    memory        = 1 #1 ГБ оперативной памяти
    core_fraction = 20 #гарантированная доля производительности vCPU - 20%(бюджетная) от мощности физического ядра
  }
 Загрузочный диск ВМ Бастион
  boot_disk {
    auto_delete = true #автоматическое удалёние диска вместе с ВМ
    disk_id = yandex_compute_disk.bastion-disk.id #указано, какой именно диск будет использоваться как загрузочный.
  }

# Блок metadata задаёт два ключевых параметра для ВМ Бастион
  metadata = {
    user-data          = file("./cloud-init.yml") #ключ метаданных, распознаваемый Yandex Cloud. Ссылка на cloud‑init.yml
    serial-port-enable = 1 #ключ метаданных для активации последовательного порта. 1-включено
  }

# Политика планирования запуска и работы ВМ Бастион
  scheduling_policy { preemptible = false } # ВМ непрерываемая

# Сетевой интерфейс ВМ Бастион
  network_interface {
    subnet_id          = yandex_vpc_subnet.develop_a.id #Подсеть для подключена ВМ. Зона доступности zone ВМ должна совпадать с зоной subnet!
    nat                = true # Предоставляет для ВМ публичный (внешний) IP‑адрес
    security_group_ids = [yandex_vpc_security_group.bastion.id] #Группы безопасности, применяемые к сетевому интерфейсу ВМ Бастион
  }
}

