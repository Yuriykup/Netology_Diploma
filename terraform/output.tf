resource "local_file" "inventory" {
  content = <<-XYZ
  # ============================================
  # ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
  # ============================================
  [all:vars]
  ansible_user=kupriyanov
  ansible_ssh_private_key_file=~/.ssh/id_ed25519
  ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

  # Адрес балансировщика
  alb_address=${yandex_alb_load_balancer.alb_load_balancer.listener[0].endpoint[0].address[0].external_ipv4_address[0].address}:80

  # IP-адреса хостов
  bastion_ip=${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}
  weba_ip=${yandex_compute_instance.weba.network_interface.0.ip_address}
  webb_ip=${yandex_compute_instance.webb.network_interface.0.ip_address}
  elasticsearch_ip=${yandex_compute_instance.elasticsearch.network_interface.0.ip_address}
  zabbix_ip=${yandex_compute_instance.zabbix-server.network_interface.0.nat_ip_address}
  kibana_ip=${yandex_compute_instance.kibana-server.network_interface.0.nat_ip_address}

  # ============================================
  # БАСТИОН
  # ============================================
  [bastion]
  bastion-server ansible_host=${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}

  # ============================================
  # ELASTICSEARCH
  # ============================================
  [elasticsearch_servers]
  elasticsearch ansible_host=${yandex_compute_instance.elasticsearch.network_interface.0.ip_address}

  # ============================================
  # KIBANA
  # ============================================
  [kibana_servers]
  kibana-server ansible_host=${yandex_compute_instance.kibana-server.network_interface.0.nat_ip_address}

  # ============================================
  # ВЕБ-СЕРВЕРЫ
  # ============================================
  [web_servers]
  weba ansible_host=${yandex_compute_instance.weba.network_interface.0.ip_address}
  webb ansible_host=${yandex_compute_instance.webb.network_interface.0.ip_address}

  # ============================================
  # ZABBIX
  # ============================================
  [zabbix_servers]
  zabbix-server ansible_host=${yandex_compute_instance.zabbix-server.network_interface.0.nat_ip_address}

  # ============================================
  # ПРОКСИ ЧЕРЕЗ БАСТИОН
  # ============================================
  [web_servers:vars]
  ansible_ssh_common_args='-o ProxyCommand="ssh -i ~/.ssh/id_ed25519 -W %h:%p -q kupriyanov@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

  [elasticsearch_servers:vars]
  ansible_ssh_common_args='-o ProxyCommand="ssh -i ~/.ssh/id_ed25519 -W %h:%p -q kupriyanov@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
  XYZ

  filename = "../ansible/hosts.ini"
}
