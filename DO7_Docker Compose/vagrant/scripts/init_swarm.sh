#!/bin/bash
set -e  # ← Включить режим "выход при ошибке"

# Ждем установки Docker
sleep 15

# Создаем Swarm
docker swarm init --advertise-addr 192.168.195.100

# Сохраняем токен для воркеров
docker swarm join-token -q worker > /vagrant/swarm_token