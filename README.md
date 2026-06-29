# 🚀 Дипломная работа по профессии «Системный администратор»

> **Полноценное развертывание инфраструктуры в Yandex Cloud с использованием Terraform + Ansible**

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-purple)](https://www.terraform.io/)
[![Ansible](https://img.shields.io/badge/Ansible-2.16+-red)](https://www.ansible.com/)
[![Yandex Cloud](https://img.shields.io/badge/Yandex_Cloud-IaaS-blue)](https://cloud.yandex.ru/)

---

## 📋 Оглавление

- [Обзор проекта](#обзор-проекта)
- [Архитектура](#архитектура)
- [Технологический стек](#технологический-стек)
- [Структура проекта](#структура-проекта)
- [Компоненты инфраструктуры](#компоненты-инфраструктуры)

---

## 🎯 Обзор проекта

Данный проект демонстрирует **полностью автоматизированное развертывание production-инфраструктуры** в облаке Yandex Cloud с использованием принципов Infrastructure as Code (IaC). Реализована отказоустойчивая веб-инфраструктура с мониторингом и централизованным логированием.

### Ключевые возможности
- ✅ **Отказоустойчивость**: два веб-сервера в разных зонах доступности
- ✅ **Балансировка нагрузки**: Application Load Balancer с проверками здоровья
- ✅ **Централизованное логирование**: Elastic Stack (Elasticsearch, Kibana, Filebeat)
- ✅ **Мониторинг инфраструктуры**: Zabbix Server с агентным мониторингом
- ✅ **Безопасный доступ**: бастион-хост для контролируемого SSH-доступа
- ✅ **Инфраструктура как код**: полная автоматизация через Terraform
- ✅ **Управление конфигурациями**: Ansible плейбуки для автоматического развертывания
- ✅ **Динамический инвентарь**: автоматическая генерация Ansible inventory

---

## 🏗️ Архитектура

![Архитектура](https://github.com/Yuriykup/Netology_Diploma/blob/main/img/img-arch.jpg)


### Схема потоков данных
1. **Пользовательский трафик**: ALB распределяет HTTP-запросы между WebA и WebB
2. **Логи**: Filebeat собирает логи Nginx → отправляет в Elasticsearch → Kibana визуализирует
3. **Мониторинг**: Zabbix агенты собирают метрики → Zabbix Server обрабатывает → Дашборды

---

## 🛠️ Технологический стек

### Инфраструктура
| Инструмент | Назначение |
|------------|------------|
| **Terraform** v1.5+ | Инфраструктура как код |
| **Yandex Cloud** | Облачный провайдер |
| **Application Load Balancer** | Распределение трафика |
| **VPC** | Сетевая изоляция |
| **Security Groups** | Правила файрвола |

### Управление конфигурациями
| Инструмент | Назначение |
|------------|------------|
| **Ansible** v2.16+ | Автоматизация конфигураций |
| **Ansible Inventory** | Динамическое управление хостами |

### Сервисы
| Компонент | Версия | Назначение |
|-----------|--------|------------|
| **Ubuntu** | 22.04 LTS | Операционная система |
| **Nginx** | Latest | Веб-сервер |
| **Zabbix** | 7.0 | Мониторинг |
| **PostgreSQL** | Latest | База данных Zabbix |
| **Elasticsearch** | 7.x | Хранилище логов |
| **Kibana** | 7.x | Визуализация логов |
| **Filebeat** | 7.x | Сборщик логов |

---

### 📁 Структура проекта
```
├── terraform/ # Инфраструктура как код 
│ ├── main.tf # ВМ, диски, вычислительные ресурсы
│ ├── alb.tf # Application Load Balancer
│ ├── network.tf # VPC, подсети, маршрутизация
│ ├── security.tf # Группы безопасности
│ ├── output.tf # Генерация Ansible inventory
│ ├── cloud-init.yml # Создание пользователей и SSH-ключей
│ └── variables.tf # Переменные Terraform
│
├── ansible/ # Управление конфигурациями
│ ├── ansible.cfg # Конфигурация Ansible
│ ├── hosts.ini # Сгенерированный инвентарь
│ ├── vars/
│ │ └── main.yml # Переменные для плейбуков
│ ├── configs/ # Конфигурационные файлы сервисов
│ │ ├── elasticsearch/
│ │ │ └── config.yml  # 0Конфигурационные файлы для Elasticsearch
│ │ ├── kibana/
│ │ │ └── config.yml # Конфигурационные файлы для Kibana
│ │ └── filebeat/
│ │ ├── filebeat.yml # Конфигурационные файлы для Filebeat
│ │ └── nginx.yml
│ ├── weba_index/ # Приветственная страница WebA
│ │ └── index.nginx.html
│ ├── webb_index/ # Приветственная страница WebB
│ │ └── index.nginx.html
│ └── playbooks/
│ ├── zabbix-server.yml
│ ├── zabbix-agent.yml
│ ├── elasticsearch.yml
│ ├── kibana.yml
│ ├── filebeat.yml
│ ├── nginx_weba.yml
│ └── nginx_webb.yml
│
├── img/ # Скриншоты для проекта
└── README.md # Документация проекта
```

---

## 🔧 Компоненты инфраструктуры

### Виртуальные машины
| Имя хоста | Внутренний IP | Публичный IP | Зона | Назначение |
|-----------|---------------|--------------|------|------------|
| bastion | 10.10.1.x | 111.88.242.130 | a | SSH-шлюз |
| weba | 10.10.1.11 | - | a | Веб-сервер A |
| webb | 10.10.2.16 | - | b | Веб-сервер B |
| elasticsearch | 10.10.1.34 | - | a | Хранилище логов |
| kibana-server | - | 111.88.241.212 | a | Визуализация логов |
| zabbix-server | - | 111.88.247.195 | a | Мониторинг |

### Балансировщик нагрузки
- **Тип**: Application Load Balancer
- **Порт**: 80 (HTTP)
- **Целевая группа**: WebA + WebB
- **Проверка здоровья**: HTTP `/` с ожидаемым статусом 200
- **Алгоритм**: Round-robin

### Группы безопасности
| Группа | Разрешённый входящий трафик |
|--------|----------------------------|
| bastion-sg | SSH (22) отовсюду |
| web-sg | HTTP (80) от ALB |
| elasticsearch-sg | SSH (22), ES порты (9200,9300) |
| kibana-sg | SSH (22), Kibana (5601) |
| zabbix-sg | SSH (22), HTTP (80), Agent (10050) |

---

## 🚀 Запуск состовляющих проекта

### Terraform

![Terraform-version](https://github.com/Yuriykup/Netology_Diploma/blob/main/img/img-terraform.png)

### Ansible

![Ansible-version](https://github.com/Yuriykup/Netology_Diploma/blob/main/img/img-ansible.png)

### Yandex Cloud CLI

![YaCloud-dashboard](https://github.com/Yuriykup/Netology_Diploma/blob/main/img/img-yacloud.png)

### Развертывание инфраструктуры

![Terraform-apply](https://github.com/Yuriykup/Netology_Diploma/blob/main/img/img-terraform-up.png)

### Развертывание сервисов в правильном порядке
```
ansible-playbook zabbix-server.yml  # Сервер мониторинга
ansible-playbook elasticsearch.yml  # Хранилище логов
ansible-playbook kibana.yml         # Визуализация логов
ansible-playbook nginx_weba.yml     # Веб-сервер A
ansible-playbook nginx_webb.yml     # Веб-сервер B
ansible-playbook filebeat.yml       # Сборщик логов
ansible-playbook zabbix-agent.yml   # Агенты мониторинга
```
![Ansible-playbook-up](https://github.com/Yuriykup/Netology_Diploma/blob/main/img/img-ansible-up.png)

## Скриншоты рабочей инфраструктуры

### Zabbix Server Dashbord


### Web Server 1 и Web Server 2


### Elasticsearch. Логирование


### Snapshot


## Заключение.
📈 Заключение
В ходе выполнения дипломного проекта была полностью автоматизирована процедура развертывания отказоустойчивой веб-инфраструктуры в облаке Yandex Cloud с использованием Terraform и Ansible. Инфраструктура включает:

- Отказоустойчивость: два веб-сервера в разных зонах доступности
- Балансировку нагрузки: Application Load Balancer распределяет трафик между WebA и WebB
- Централизованное логирование: Elasticsearch + Filebeat + Kibana для сбора и визуализации логов
- Мониторинг: Zabbix Server и агенты для наблюдения за состоянием всех серверов
- Безопасность: бастион-хост и правильно настроенные группы безопасности

 🎉


