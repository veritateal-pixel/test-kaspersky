#!/bin/bash

set -e

echo "=== Деплой приложения в Яндекс клауд ==="

# Инициализация Terraform
echo "=== Запуск терраформ ==="
terraform init

# Применение Terraform
echo "=== Создание инстанса ==="
terraform apply -auto-approve

# Получение IP адреса
VM_IP=$(terraform output -raw external_ip)
echo "Белый айпишник ВМ: $VM_IP"

sleep 30

export VM_EXTERNAL_IP=$VM_IP
envsubst < ansible/inventory.yml > ansible/inventory_generated.yml

echo "Запуск ансибл"
cd ansible
ansible-playbook -i inventory_generated.yml site.yml

echo "=== Деплой завершен ==="
echo "Приложения доступно на: http://$VM_IP:8080"
echo "Метрики: http://$VM_IP:8080/metrics"