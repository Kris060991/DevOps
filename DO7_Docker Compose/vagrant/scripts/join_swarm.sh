#!/bin/bash
set -e  # ← Включить режим "выход при ошибке"

# Ждем пока менеджер создаст токен
sleep 45

# Читаем токен и присоединяемся к Swarm
TOKEN=$(cat /vagrant/swarm_token)
docker swarm join --token $TOKEN 192.168.195.100:2377