resource "yandex_compute_instance" "python-metrics-app_vm" {
  name        = "python-metrics-app-vm"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue6aagj7rb33b6" # Альма
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.python-metrics-app_subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "almalinux:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_vpc_network" "python-metrics-app_network" {
  name = "python-metrics-app-network"
}

resource "yandex_vpc_subnet" "python-metrics-app_subnet" {
  name           = "python-metrics-app-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.python-metrics-app_network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "external_ip" {
  value = yandex_compute_instance.python-metrics-app_vm.network_interface.0.nat_ip_address
}