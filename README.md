# 🚀 DevOps Дипломный проект: Облачная инфраструктура как код с мониторингом и логированием

> **Полноценное развертывание инфраструктуры в Yandex Cloud с использованием Terraform + Ansible**

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-purple)](https://www.terraform.io/)
[![Ansible](https://img.shields.io/badge/Ansible-2.16+-red)](https://www.ansible.com/)
[![Yandex Cloud](https://img.shields.io/badge/Yandex_Cloud-IaaS-blue)](https://cloud.yandex.ru/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## 📋 Оглавление

- [Обзор проекта](#-обзор-проекта)
- [Архитектура](#-архитектура)
- [Технологический стек](#-технологический-стек)
- [Структура проекта](#-структура-проекта)
- [Компоненты инфраструктуры](#-компоненты-инфраструктуры)
- [Руководство по развертыванию](#-руководство-по-развертыванию)
- [После развертывания](#-после-развертывания)
- [Скриншоты](#-скриншоты)
- [Очистка ресурсов](#-очистка-ресурсов)
- [Устранение неполадок](#-устранение-неполадок)

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
┌─────────────────────────────────────────────────────────────────────────────┐
│ YANDEX CLOUD │
├─────────────────────────────────────────────────────────────────────────────┤
│ │
│ ┌─────────────────────────────────────────────────────────────────────┐ │
│ │ Application Load Balancer │ │
│ │ http://158.160.187.10:80 │ │
│ └──────────────────────────────┬──────────────────────────────────────┘ │
│ │ │
│ ┌──────────────┼──────────────┐ │
│ │ │ │ │
│ ▼ ▼ ▼ │
│ ┌────────────────────┐ ┌────────────────────┐ ┌────────────────────┐ │
│ │ WebA │ │ WebB │ │ Бастион │ │
│ │ 10.10.1.11 │ │ 10.10.2.16 │ │ 111.88.242.130 │ │
│ │ ┌──────────────┐ │ │ ┌──────────────┐ │ │ (SSH Proxy) │ │
│ │ │ Nginx │ │ │ │ Nginx │ │ └────────────────────┘ │
│ │ │ Filebeat │ │ │ │ Filebeat │ │ │
│ │ │ Zabbix Agent │ │ │ │ Zabbix Agent │ │ │
│ │ └──────────────┘ │ │ └──────────────┘ │ │
│ └────────────────────┘ └────────────────────┘ │
│ │ │ │ │
│ └──────────────┼──────────────┘ │
│ │ │
│ ┌──────────────┼──────────────┐ │
│ │ │ │ │
│ ▼ ▼ ▼ │
│ ┌────────────────────┐ ┌────────────────────┐ ┌────────────────────┐ │
│ │ Elasticsearch │ │ Kibana │ │ Zabbix Server │ │
│ │ 10.10.1.34 │ │ 111.88.241.212:5601│ │ 111.88.247.195 │ │
│ │ (Хранилище логов)│ │ (Визуализация) │ │ (Мониторинг) │ │
│ └────────────────────┘ └────────────────────┘ └────────────────────┘ │
│ │
└─────────────────────────────────────────────────────────────────────────────┘


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

## 📁 Структура проекта
.
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
│ │ │ └── config.yml
│ │ ├── kibana/
│ │ │ └── config.yml
│ │ └── filebeat/
│ │ ├── filebeat.yml
│ │ └── nginx.yml
│ ├── weba_index/ # Приветственная страница WebA
│ │ └── index.nginx-debian.html
│ ├── webb_index/ # Приветственная страница WebB
│ │ └── index.nginx-debian.html
│ └── playbooks/
│ ├── zabbix-server.yml
│ ├── zabbix-agent.yml
│ ├── elasticsearch.yml
│ ├── kibana.yml
│ ├── filebeat.yml
│ ├── nginx_weba.yml
│ └── nginx_webb.yml
│
├── screenshots/ # Скриншоты для документации
└── README.md # Документация проекта


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

## 🚀 Руководство по развертыванию

### Предварительные требования

# Установка необходимых инструментов
# Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Ansible
sudo apt install ansible

# Yandex Cloud CLI
curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash

1. Клонирование репозитория
bash
git clone https://github.com/yourusername/diploma-project.git
cd diploma-project

2. Настройка Yandex Cloud
bash
yc config set cloud-id <ваш-cloud-id>
yc config set folder-id <ваш-folder-id>
yc config set token <ваш-oauth-token>
3. Развертывание инфраструктуры
bash
cd terraform

# Инициализация Terraform
terraform init

# Просмотр планируемых изменений
terraform plan

# Развертывание инфраструктуры
terraform apply
Ожидаемый вывод (краткий):

text
Apply complete! Resources: 30+ added, 0 changed, 0 destroyed.
4. Применение конфигураций
bash
cd ../ansible

# Проверка доступности всех хостов
ansible all -i hosts.ini -m ping -f 1

# Развертывание сервисов в правильном порядке
ansible-playbook zabbix-server.yml      # Бэкенд мониторинга
ansible-playbook elasticsearch.yml       # Хранилище логов
ansible-playbook kibana.yml              # Визуализация логов
ansible-playbook nginx_weba.yml          # Веб-сервер A
ansible-playbook nginx_webb.yml          # Веб-сервер B
ansible-playbook filebeat.yml            # Сборщик логов
ansible-playbook zabbix-agent.yml        # Агенты мониторинга

5. Восстановление после сбоев
Если какой-либо плейбук завершился с ошибкой:

bash
# Повторный запуск (плейбуки идемпотентны)
ansible-playbook <имя_плейбука>.yml



