#ОС - оперсационная система
#ЖД - жесткий диск
#ВМ - виртуальная машина
#FQDN - полное доменное имя хоста

# Данные об ОС Ubuntu 22.04
data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}

# Блок создания ВМ Бастион
# ЖД для bastion
resource "yandex_compute_disk" "bastion-disk" {
  name     = "bastion-disk" #Имя диска
  type     = "network-hdd" #Тип ЖД (бюджетный вариант)
  zone     = "ru-central1-a" #Зона доступности
  size     = "10" #Объем ЖД
  image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id #ОС Ubuntu 22.04 LTS, взятая из стандартного образа Yandex Cloud
}

# Параметры для запуска ВМ Бастион
resource "yandex_compute_instance" "bastion" {
  name        = "bastion" #Имя ВМ в облаке Яндекс
  hostname    = "bastion" #Имя хоста для формирования FQDN
  platform_id = "standard-v3" # Платформа (аппаратная конфигурация) с процессорами Intel Ice Lake
  zone        = "ru-central1-a" #важно, чтобы зона ВМ совпадала с зоной subnet и диска — иначе подключение невозможно.

# Выделяемые вычислительные ресурсы для ВМ Бастион
  resources {
    cores         = 2 #2 виртуальных процессора (vCPU)
    memory        = 1 #1 ГБ оперативной памяти
    core_fraction = 20 #гарантированная доля производительности vCPU - 20%(бюджетная) от мощности физического ядра
  }

# Загрузочный диск ВМ Бастион
  boot_disk {
    auto_delete = true #автоматическое удалёние диска вместе с ВМ
    disk_id = yandex_compute_disk.bastion-disk.id #указано, какой именно диск будет использоваться как загрузочный.
  }

# Блок metadata для авторизации по SSH на ВМ Бастион
  metadata = {
    user-data          = file("./cloud-init.yml") ##В файле cloud‑init.yml указаны папраметры подключения по SSH на ВМ
    serial-port-enable = 1 #активации последовательного порта. 1-включено
  }

# Политика планирования запуска и работы ВМ Бастион
  scheduling_policy { preemptible = false } # ВМ непрерываемая

# Сетевой интерфейс ВМ Бастион
  network_interface {
    subnet_id          = yandex_vpc_subnet.develop_a.id #Подсеть для подключена ВМ. Зона доступности zone ВМ должна совпадать с зоной subnet!
    nat                = true # Предоставляет для ВМ публичный (внешний) IP‑адрес
    security_group_ids = [yandex_vpc_security_group.bastion-sg.id] #Группы безопасности, применяемые к сетевому интерфейсу ВМ Бастион
  }
}

# Блок для создания WEB сервера A
# ЖД для webA
resource "yandex_compute_disk" "weba-disk" {
  name     = "weba-disk" #Имя диска
  type     = "network-hdd" #Тип ЖД (бюджетный вариант)
  zone     = "ru-central1-a" #Зона доступности
  size     = "10" #Объем ЖД
  image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id #ОС Ubuntu 22.04 LTS, взятая из стандартного образа Yandex Cloud
}

# Параметры для запуска ВМ webA
resource "yandex_compute_instance" "weba" {
  name        = "weba" #Имя ВМ в облаке Яндекс
  hostname    = "weba" #Имя хоста для формирования FQDN
  platform_id = "standard-v3" #Платформа (аппаратная конфигурация) с процессорами Intel Ice Lake
  zone        = "ru-central1-a" #важно, чтобы зона ВМ совпадала с зоной subnet и диска — иначе подключение невозможно.

# Выделяемые вычислительные ресурсы для ВМ webA
  resources {
   cores         = 2 #2 виртуальных процессора (vCPU)
   memory        = 1 #1 ГБ оперативной памяти
   core_fraction = 20 #гарантированная доля производительности vCPU - 20%(бюджетная) от мощности физического ядра
  }

# Загрузочный диск ВМ webA
  boot_disk {
    auto_delete = true #автоматическое удалёние диска вместе с ВМ
    disk_id = yandex_compute_disk.weba-disk.id #указано, какой именно диск будет использоваться как загрузочный.
  }

# Блок metadata для авторизации по SSH на ВМ webA
  metadata = {
    user-data          = file("./cloud-init.yml") #В файле cloud‑init.yml указаны папраметры подключения по SSH на ВМ
    serial-port-enable = 1 #активации последовательного порта. 1-включено
  }

# Политика планирования запуска и работы ВМ webA
  scheduling_policy { preemptible = false }  #ВМ непрерываемая

# Сетевой интерфейс ВМ webA
  network_interface {
    subnet_id          = yandex_vpc_subnet.develop_a.id #Подсеть для подключена ВМ. Зона доступности zone ВМ должна совпадать с зоной subnet!
    nat                = false #ВМ не получит публичный (внешний) IP‑адрес
    security_group_ids = [yandex_vpc_security_group.web_sg.id] #Разрешить HTTP/HTTPS (порты 80/443), SSH (порт 22)
  }
}

# Блок для создания WEB сервера B
# Создаю диск для webB
  resource "yandex_compute_disk" "webb-disk" {
    name     = "webb-disk" #Имя диска
    type     = "network-hdd" #Тип ЖД (бюджетный вариант)
    zone     = "ru-central1-b" #Зона доступности. Важно! ВМ будет находится в другой подсети!
    size     = "10" #Объем ЖД
    image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id #ОС Ubuntu 22.04 LTS, взятая из стандартного образа Yandex Cloud
}

# Создаю ВМ webB
resource "yandex_compute_instance" "webb" {
  name        = "webb" #Имя ВМ в облаке Яндекс
  hostname    = "webb" #Имя хоста для формирования FQDN
  platform_id = "standard-v3" #Платформа (аппаратная конфигурация) с процессорами Intel Ice Lake
  zone        = "ru-central1-b" #Важно, чтобы зона ВМ совпадала с зоной subnet и диска — иначе подключение невозможно.

# Выделяемые вычислительные ресурсы для ВМ webB
  resources {
    cores         = 2 #2 виртуальных процессора (vCPU)
    memory        = 1 #1 ГБ оперативной памяти
    core_fraction = 20 #гарантированная доля производительности vCPU - 20%(бюджетная) от мощности физического ядра

# Загрузочный диск ВМ webB
  boot_disk {
    auto_delete = true #автоматическое удалёние диска вместе с ВМ
    disk_id = yandex_compute_disk.webb-disk.id #указано, какой именно диск будет использоваться как загрузочный.
  }

# Блок metadata для авторизации по SSH на ВМ webB
  metadata = {
    user-data          = file("./cloud-init.yml") #В файле cloud‑init.yml указаны папраметры подключения по SSH на ВМ
    serial-port-enable = 1 #активации последовательного порта. 1-включено
  }

# Политика планирования запуска и работы ВМ webB
  scheduling_policy { preemptible = false }  #ВМ непрерываемая

# Сетевой интерфейс ВМ webB
  network_interface {
    subnet_id          = yandex_vpc_subnet.develop_b.id #Подсеть для подключена ВМ. Зона доступности zone ВМ должна совпадать с зоной subnet!
    nat                = false #ВМ не получит публичный (внешний) IP‑адрес
    security_group_ids = [yandex_vpc_security_group.web_sg.id] #Разрешить HTTP/HTTPS (порты 80/443), SSH (порт 22)
  }
}

# Блок для создания серверв Elasticsearch
# ЖД для Elasticsearch
resource "yandex_compute_disk" "elasticsearch-disk" {
  name     = "elasticsearch-disk" #Имя диска
  type     = "network-hdd" #Тип ЖД (бюджетный вариант)
  zone     = "ru-central1-a" #Зона доступности
  size     = "10" #Объем ЖД
  image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id #ОС Ubuntu 22.04 LTS, взятая из стандартного образа Yandex Cloud
}

# Создаю ВМ Elasticsearch
resource "yandex_compute_instance" "elasticsearch" {
  name        = "elasticsearch" #Имя ВМ в облаке Яндекс
  hostname    = "elasticsearch" #Имя хоста для формирования FQDN
  platform_id = "standard-v3" #Платформа (аппаратная конфигурация) с процессорами Intel Ice Lake
  zone        = "ru-central1-a" #Важно, чтобы зона ВМ совпадала с зоной subnet и диска — иначе подключение невозможно.

# Выделяемые вычислительные ресурсы для ВМ Elasticsearch
  resources {
    cores         = 2 #2 виртуальных процессора (vCPU)
    memory        = 4 #4 ГБ оперативной памяти
    core_fraction = 20 #гарантированная доля производительности vCPU - 20%(бюджетная) от мощности физического ядра
  }

# Загрузочный диск ВМ Elasticsearch
  boot_disk {
    auto_delete = true #автоматическое удалёние диска вместе с ВМ
    disk_id = yandex_compute_disk.elasticsearch-disk.id #указано, какой именно диск будет использоваться как загрузочный.
  }

# Блок metadata для авторизации по SSH на ВМ Elasticsearch
  metadata = {
    user-data          = file("./cloud-init.yml") #В файле cloud‑init.yml указаны папраметры подключения по SSH на ВМ
    serial-port-enable = 1 #активации последовательного порта. 1-включено
  }

# Политика планирования запуска и работы ВМ Elasticsearch
  scheduling_policy { preemptible = false } #ВМ непрерываемая

# Сетевой интерфейс ВМ Elasticsearch
  network_interface {
    subnet_id          = yandex_vpc_subnet.develop_a.id #Подсеть для подключена ВМ. Зона доступности zone ВМ должна совпадать с зоной subnet!
    nat                = false #ВМ не получит публичный (внешний) IP‑адрес
    security_group_ids = [yandex_vpc_security_group.elasticsearch-sg.id] #Разрешить (HTTP API Elasticsearch) для любых IP (порты 9200/9300), SSH (порт 22)
  }
}

#Блок создания Zabbix Server
# ЖД для Zabbix Server
resource "yandex_compute_disk" "zabbix-disk" {
  name     = "zabbix-disk" #Имя диска
  type     = "network-hdd" #Тип ЖД (бюджетный вариант)
  zone     = "ru-central1-a" #Зона доступности
  size     = "10" #Объем ЖД
  image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id #ОС Ubuntu 22.04 LTS, взятая из стандартного образа Yandex Cloud
}

# Создаю ВМ Zabbix Server
resource "yandex_compute_instance" "zabbix-server" {
  name        = "zabbix-server" #Имя ВМ в облаке Яндекс
  hostname    = "zabbix-server" ##Имя хоста для формирования FQDN
  platform_id = "standard-v3" #Платформа (аппаратная конфигурация) с процессорами Intel Ice Lake
  zone        = "ru-central1-a" #Важно, чтобы зона ВМ совпадала с зоной subnet и диска — иначе подключение невозможно.

# Выделяемые вычислительные ресурсы для ВМ Zabbix Server
  resources {
    cores         = 2 #2 виртуальных процессора (vCPU)
    memory        = 1 #1 ГБ оперативной памяти
    core_fraction = 20 #гарантированная доля производительности vCPU - 20%(бюджетная) от мощности физического ядра
  }

# Загрузочный диск ВМ Zabbix Server
  boot_disk {
    auto_delete = true #автоматическое удалёние диска вместе с ВМ
    disk_id = yandex_compute_disk.zabbix-disk.id #указано, какой именно диск будет использоваться как загрузочный.
  }

# Блок metadata для авторизации по SSH на ВМ Zabbix Server
  metadata = {
    user-data          = file("./cloud-init.yml") #В файле cloud‑init.yml указаны папраметры подключения по SSH на ВМ
    serial-port-enable = 1 #активации последовательного порта. 1-включено
  }

# Политика планирования запуска и работы ВМ Zabbix Server
  scheduling_policy { preemptible = false } #ВМ непрерываемая

# Сетевой интерфейс ВМ 
  network_interface {
    subnet_id          = yandex_vpc_subnet.develop_a.id #Подсеть для подключена ВМ. Зона доступности zone ВМ должна совпадать с зоной subnet!
    nat                = true #ВМ получит!!! публичный (внешний) IP‑адрес
    security_group_ids = [yandex_vpc_security_group.zabbix-sg.id] #Разрешить порт 10050 (Zabbix Agent), порт 80 (HTTP), порт 443 (HTTPS), порт 22
(SSH)
  }
}

# Блок содания ВМ Kibana Server
# Создаю диск для ВМ Kibana Server
resource "yandex_compute_disk" "kibana-disk" {
  name     = "kibana-disk" #Имя диска
  type     = "network-hdd" #Тип ЖД (бюджетный вариант)
  zone     = "ru-central1-a" #Зона доступности
  size     = "10" #Объем ЖД
  image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id #ОС Ubuntu 22.04 LTS, взятая из стандартного образа Yandex Cloud
}

# Создаю ВМ Kibana Server
resource "yandex_compute_instance" "kibana-server" {
  name        = "kibana-server" #Имя ВМ в облаке Яндекс
  hostname    = "kibana-server" #Имя хоста для формирования FQDN
  platform_id = "standard-v3" #Платформа (аппаратная конфигурация) с процессорами Intel Ice Lake
  zone        = "ru-central1-a" #Важно, чтобы зона ВМ совпадала с зоной subnet и диска — иначе подключение невозможно.

# Выделяемые вычислительные ресурсы для ВМ Kibana Server
  resources {
    cores         = 2 #2 виртуальных процессора (vCPU)
    memory        = 4 #4 ГБ оперативной памяти
    core_fraction = 20 #гарантированная доля производительности vCPU - 20%(бюджетная) от мощности физического ядра
  }

# Загрузочный диск ВМ Kibana Server
  boot_disk {
    auto_delete = true #автоматическое удалёние диска вместе с ВМ
    disk_id = yandex_compute_disk.kibana-disk.id #указано, какой именно диск будет использоваться как загрузочный.
  }

# Блок metadata для авторизации по SSH на ВМ Kibana Server
  metadata = {
    user-data          = file("./cloud-init.yml") #В файле cloud‑init.yml указаны папраметры подключения по SSH на ВМ
    serial-port-enable = 1 #активации последовательного порта. 1-включено
  }

# Политика планирования запуска и работы ВМ Kibana Server
  scheduling_policy { preemptible = false } #ВМ непрерываемая

# Сетевой интерфейс ВМ Kibana Server
  network_interface {
    subnet_id          = yandex_vpc_subnet.develop_a.id #Подсеть для подключена ВМ. Зона доступности zone ВМ должна совпадать с зоной subnet!
    nat                = true #ВМ получит!!! публичный (внешний) IP‑адрес
    security_group_ids = [yandex_vpc_security_group.kibana-sg.id] # #Разрешает порт 5601 (веб‑интерфейс Kibana), порт 80 (HTTP), порт 443 (HTTPS), порт 22 (SSH)
  }
}

