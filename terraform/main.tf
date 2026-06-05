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

data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}


resource "yandex_compute_disk" "bastion-disk" {
  name     = "bastion-disk"   
  type     = "network-hdd" 
  zone     = "ru-central1-a" 
  size     = "15"
  image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id 

resource "yandex_compute_instance" "bastion" {
  name        = "bastion" 
  hostname    = "bastion" 
  platform_id = "standard-v3" 
  zone        = "ru-central1-a"

 resources {
    cores         = 2 
    memory        = 1 
    core_fraction = 20
  }

  boot_disk {
    auto_delete = true
    disk_id = yandex_compute_disk.bastion-disk.id 
  }

  metadata = {
    user-data          = file("./cloud-init.yml") 
    serial-port-enable = 1 
  }

  scheduling_policy { preemptible = false } 

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop_a.id 
    nat                = true 
    security_group_ids = [yandex_vpc_security_group.bastion.id] 
  }
}

