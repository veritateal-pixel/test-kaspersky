#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
import os
from prometheus_client import Counter, Gauge, generate_latest, REGISTRY

# Prometheus метрики
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP Requests')
HOST_TYPE = Gauge('host_type', 'Type of host (0=VM, 1=Container, 2=Physical)')

def detect_host_type():
    # Проверяем контейнер
    if os.path.exists('/.dockerenv'):
        return 1
    
    # Проверяем cgroups для контейнеров
    try:
        with open('/proc/1/cgroup', 'r') as f:
            content = f.read()
            if any(x in content for x in ['docker', 'podman', 'containerd', 'kubepods']):
                return 1  # container
    except:
        pass
    
    # Проверяем виртуальную машину через системные файлы
    try:
        # Проверяем DMI информацию
        if os.path.exists('/sys/class/dmi/id/product_name'):
            with open('/sys/class/dmi/id/product_name', 'r') as f:
                product_name = f.read().lower()
                if any(x in product_name for x in ['vmware', 'virtualbox', 'kvm', 'qemu', 'hyper-v']):
                    return 0  # VM
    except:
        pass
    
    # Проверяем /proc/cpuinfo
    try:
        with open('/proc/cpuinfo', 'r') as f:
            cpuinfo = f.read().lower()
            if 'hypervisor' in cpuinfo:
                return 0  # VM
    except:
        pass
    
    # Если ничего не нашли - считаем физическим сервером
    return 2 

class MicroserviceHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        REQUEST_COUNT.inc()
        self.send_response(200)
        self.send_header('Content-Type', 'text/plain')
        self.end_headers()
        self.wfile.write(generate_latest(REGISTRY))

def main():
    host_type = detect_host_type()
    HOST_TYPE.set(host_type)
    
    print(f"Detected host type: {host_type} (0=VM, 1=Container, 2=Physical)")
    print("Server running on http://0.0.0.0:8080")
    
    server = HTTPServer(('0.0.0.0', 8080), MicroserviceHandler)
    server.serve_forever()

if __name__ == '__main__':
    main()