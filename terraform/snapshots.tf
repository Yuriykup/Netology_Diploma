# Файл для создания снимков дисков ВМ в Яндекс.Облаке
resource "yandex_compute_snapshot_schedule" "snapshots-my-infrastructure" {
  name        = "snapshots-my-infrastructure"
  description = "Daily snapshot schedule for critical infrastructure disks"

# Расписание для снимков
  schedule_policy {
    expression = "0 0 * * *"  # Ежедневно в 00:00 UTC
  }

# Количество хранимых снимков для кадого диска
  snapshot_count = 7  # последние 7 снимков

# Список идентификаторов дисков Yandex Compute Cloud. Должны соответсвовать наименованием ЖД в Яндекс.Облаке
  disk_ids = [
    yandex_compute_disk.bastion-disk.id,
    yandex_compute_disk.weba-disk.id,
    yandex_compute_disk.webb-disk.id,
    yandex_compute_disk.elasticsearch-disk.id,
    yandex_compute_disk.zabbix-disk.id,
    yandex_compute_disk.kibana-disk.id
  ]

# Метки для фильтрации и группировки ресурсов в консоли Yandex Cloud.
  labels = {
    environment = "production"
    managed_by = "terraform"
    purpose   = "daily-backups"
  }

# Гарантирует, что расписание создаётся только после успешного развёртывания всех дисков.
  depends_on = [
    yandex_compute_disk.bastion-disk,
    yandex_compute_disk.weba-disk,
    yandex_compute_disk.webb-disk,
    yandex_compute_disk.elasticsearch-disk,
    yandex_compute_disk.zabbix-disk,
    yandex_compute_disk.kibana-disk
  ]
}

