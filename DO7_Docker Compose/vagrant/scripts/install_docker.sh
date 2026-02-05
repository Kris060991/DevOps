#!/bin/bash
set -e  # ← Включить режим "выход при ошибке"

# Установка Docker
apt-get update
apt-get install -y docker.io docker-compose

# Добавляем пользователя vagrant в группу docker
usermod -aG docker vagrant

# Включаем Docker
systemctl enable --now docker