#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
import socket
import os
import time
from prometheus_client import Counter, Gauge, generate_latest, REGISTRY

# Prometheus метрики
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP Requests', ['method', 'endpoint'])
HOST_TYPE = Gauge('host_type', 'Type of host (0=VM, 1=Container, 2=Physical)', ['type'])
SYSTEM_UPTIME = Gauge('system_uptime_seconds', 'System uptime in seconds')

def detect_host_type():
    # Проверяем, запущены ли мы в контейнере
    if os.path.exists('/.dockerenv'):
        return 'container'
    
    # Проверяем, является ли система виртуальной машиной
    try:
        with open('/sys/class/dmi/id/product_name', 'r') as f:
            product_name = f.read().strip().lower()
            if any(vm_indicator in product_name for vm_indicator in ['vmware', 'virtualbox', 'kvm', 'qemu', 'yandex', 'vk-cloud', 'proxmox']):
                return 'virtual_machine'
    except:
        pass
    
    # Если ничего не подошло, считаем физическим сервером
    return 'physical'

class MicroserviceHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/metrics':
            REQUEST_COUNT.labels(method='GET', endpoint='/metrics').inc()
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            self.wfile.write(generate_latest(REGISTRY))
        else:
            REQUEST_COUNT.labels(method='GET', endpoint='/').inc()
            self.send_response(200)
            self.send_header('Content-Type', 'text/html')
            self.end_headers()
            self.wfile.write(b'''
                <html>
                    <body>
                        <h1>Python app is running!</h1>
                        <p>Visit <a href="/metrics">/metrics</a> for metrics</p>
                    </body>
                </html>
            ''')

def main():
    # Определяем тип хоста и устанавливаем метрику
    host_type = detect_host_type()
    host_type_mapping = {'virtual_machine': 0, 'container': 1, 'physical': 2}
    HOST_TYPE.labels(type=host_type).set(host_type_mapping.get(host_type, 2))
    
    # Устанавливаем время запуска
    start_time = time.time()
    SYSTEM_UPTIME.set_function(lambda: time.time() - start_time)
    
    print(f"Starting python-metrics-app on port 8080...")
    print(f"Detected host type: {host_type}")
    
    server = HTTPServer(('0.0.0.0', 8080), MicroserviceHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("Turn off app...")
        server.shutdown()

if __name__ == '__main__':
    main()