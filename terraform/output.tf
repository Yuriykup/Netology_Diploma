resource "local_file" "inventory" {
  content  = <<-XYZ
  [all:vars]
  ansible_user=kupriyanov
  ansible_ssh_private_key_file=~/.ssh/id_ed25519
  ansible_ssh_common_args='-o ProxyCommand="ssh -p 22 -W %h:%p -q kupriyanov@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'

  application-load-balancer=${yandex_alb_load_balancer.alb-load-balancer.listener[0].endpoint[0].address[0].external_ipv4_address[0].address}:80

  bastion=${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}
  
  weba=${yandex_compute_instance.weba.network_interface.0.ip_address}
  webb=${yandex_compute_instance.webb.network_interface.0.ip_address}

  elasticsearch=${yandex_compute_instance.elasticsearch.network_interface.0.ip_address}

  zabbix-server=${yandex_compute_instance.zabbix-server.network_interface.0.nat_ip_address}

  kibana-server=${yandex_compute_instance.kibana-server.network_interface.0.nat_ip_address}


  [bastion]
  bastion-server ansible_host=bastion.ru-central1.internal

  [elasticsearch-server]
  elasticsearch ansible_host=elasticsearch.ru-central1.internal

  [kibana]
  kibana-server ansible_host=kibana-server.ru-central1.internal

  [hosts]
  weba ansible_host=weba.ru-central1.internal
  webb ansible_host=webb.ru-central1.internal
  
  [monitoring]
  zabbix-server ansible_host=zabbix-server.ru-central1.internal
  XYZ
  filename = "../ansible/hosts.ini"
}
