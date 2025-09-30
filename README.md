Тестовое касперски

Проект автоматизирует развертывание микросервиса с Prometheus метриками на Yandex Cloud с использованием Terraform и Ansible. (все бонусные выполнены)

Предварительные требования

Yandex Cloud аккаунт
Terraform >= 1.0
Ansible >= 2.9

# Клонируйте репозиторий
git clone <repository-url>
cd microservice-deployment

# Запустите развертывание
sudo sh deploy.sh container # для запуска в режиме контейнера(докер)
sudo sh deploy.sh virtual # для запуска в режиме сервиса systemd


📁 Структура проекта

text
├── terraform/          # Инфраструктура как код
├── python-metrics-app/ # Исходный код приложения
├── ansible/            # Конфигурация и развертывание
├── ssh/                # SSH ключи (генерируется автоматически, но нужен root)
└── deploy.sh           # Основной скрипт развертывания
🔧 Функциональность



Prometheus метрики на порту 8080
Определение типа хоста (VM/Container/Physical)



🗂️ Основные файлы

microservice/app.py - Python микросервис
terraform/main.tf - Конфигурация инфраструктуры
ansible/site.yml - Плейбук развертывания
deploy.sh - Автоматический деплой

📊 Метрики

http_requests_total - счетчик HTTP запросов
host_type - тип хоста (0=VM, 1=Container, 2=Physical)