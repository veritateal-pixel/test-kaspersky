Тестовое задание Kaspersky

Проект автоматизирует развертывание микросервиса с Prometheus метриками на Yandex Cloud с использованием Terraform и Ansible.
Все бонусные задания выполнены

Предварительные требования

Yandex Cloud аккаунт
Terraform >= 1.0
Ansible >= 2.9
Установка и запуск

# Клонируйте репозиторий
git clone <repository-url>
cd microservice-deployment

# Запустите развертывание в режиме контейнера (Docker)

#######################################
sudo sh deploy.sh container
#######################################

![Container](./images/container.png)

# Запустите развертывание в режиме сервиса systemd

#######################################
sudo sh deploy.sh virtual
#######################################

![Container](./images/virt.png)

📁 Структура проекта

terraform/           # Инфраструктура как код
python-metrics-app/  # Исходный код приложения
ansible/             # Конфигурация и развертывание
ssh/                 # SSH ключи (генерируется автоматически, но нужен root) 
deploy.sh            # Основной скрипт развертывания

🔧 Функциональность

Prometheus метрики на порту 8080
Определение типа хоста (VM/Container/Physical)
Автоматизированное развертывание инфраструктуры
Конфигурация через Ansible

🗂️ Основные файлы

microservice/app.py - Python микросервис
terraform/main.tf - Конфигурация инфраструктуры
ansible/site.yml - Плейбук развертывания
deploy.sh - Автоматический деплой

📊 Метрики

http_requests_total - счетчик HTTP запросов
host_type - тип хоста:

0 = VM
1 = Container
2 = Physical
