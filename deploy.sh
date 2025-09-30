#!/bin/bash

set -e

echo "=== Deploy metrics application to yandex cloud ==="

# выбираем тип запуска (по умолчание бейр метал или вм, для запуска в контейнере напигите container)
MODE=${1:-vm}  

echo "=== Deploying Microservice to Yandex Cloud ($MODE mode) ==="

# Проверяем существование ключа и его валидность
if [ ! -f "ssh/id_rsa" ]; then
    echo "SSH key not found. Creating new SSH keys..."
    ssh-keygen -t rsa -b 4096 -f ssh/id_rsa -N "" -C "python-app-dynamic"
    chmod 600 ssh/id_rsa
    chmod 644 ssh/id_rsa.pub
    echo "New SSH keys created successfully!"
elif ! ssh-keygen -l -f ssh/id_rsa &>/dev/null; then
    echo "Existing SSH key is invalid. Creating new SSH keys..."
    rm -f ssh/id_rsa ssh/id_rsa.pub
    ssh-keygen -t rsa -b 4096 -f ssh/id_rsa -N "" -C "python-app-dynamic"
    chmod 600 ssh/id_rsa
    chmod 644 ssh/id_rsa.pub
    echo "New SSH keys created successfully!"
else
    echo "Using existing valid SSH key"
    chmod 600 ssh/id_rsa 2>/dev/null || true
    chmod 644 ssh/id_rsa.pub 2>/dev/null || true
fi

# Автоматически обновляем terraform.tfvars
echo "Updating Terraform configuration with public key..."
PUBLIC_KEY=$(cat ssh/id_rsa.pub)

# Создаем или обновляем terraform.tfvars (токен указать свой от яндекс облака)
cat > terraform/terraform.tfvars << EOF
yc_token        = "y0__xDsgbeHBBjB3RMgsMm10hOglD0a_3H8JXkYgRmi3b5HNu4WO..."
yc_cloud_id     = "b1gq0pdujlehihkrsabp"
yc_folder_id    = "b1gb83sjpa1v5pc9i826"
ssh_public_key  = "$PUBLIC_KEY"
EOF

echo "Terraform configuration updated with public key"

cd terraform

# Инициализация и применение Terraform
echo "Applying Terraform configuration..."
terraform init
terraform apply -auto-approve

# Получаем белый IP-адрес
VM_IP=$(terraform output -raw external_ip)
echo "VM created with IP: $VM_IP"

# Ждем инициализации VM
echo "Waiting for VM initialization..."
sleep 30

cd ../ansible

# Создаем инвентарь
cat > inventory_generated.yml << EOF
all:
  hosts:
    microservice-vm:
      ansible_host: $VM_IP
      ansible_user: almalinux
      ansible_ssh_private_key_file: ../ssh/id_rsa
      ansible_ssh_common_args: -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=60 -o ServerAliveInterval=60 -o ServerAliveCountMax=3 -o TCPKeepAlive=yes -o ConnectTimeout=30 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
EOF

# Запускаем плейбук

if [ "$MODE" = "container" ]; then
    echo "Running in docker"
    ansible-playbook -i inventory_generated.yml site.yml --extra-vars "container_mode=true"
elif [ "$MODE" = "virtual" ]; then
    echo "Running using virtualisation"
    ansible-playbook -i inventory_generated.yml site.yml --extra-vars "virtual_mode=true"
    # или явно: ansible-playbook -i inventory_generated.yml site.yml --extra-vars "container_mode=false"
fi

echo "=== deployment completed in $MODE mode ==="
echo "Microservice: http://$VM_IP:8080"
echo "Metrics:      http://$VM_IP:8080/metrics"