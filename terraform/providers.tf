terraform {
  required_version = ">=1.13.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.193.0"
    }
  }
}

provider "yandex" {
  # token                    = "НЕ ИСПОЛЬЗОВАТЬ"
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  service_account_key_file = file("~/.authorized_key.json")
}


