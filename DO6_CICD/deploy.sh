#!/bin/bash

set -e  # Выход при ошибках

# Настройки (переменные)
TARGET_USER="deploy" # Имя пользователя на удаленном сервере
TARGET_HOST="192.168.1.88" # IP-адрес сервера
TARGET_DIR="/usr/local/bin" # Куда копируем на сервере
ARTIFACT_PATH="code-samples/DO" # Что копируем (локальный файл)
 
# Проверяем, существует ли файл
if [ ! -f "$ARTIFACT_PATH" ]; then
  echo "ОШИБКА: Файл $ARTIFACT_PATH не найден!"
  exit 1
fi

# Копируем файл на сервер
scp "$ARTIFACT_PATH" "$TARGET_USER@$TARGET_HOST:$TARGET_DIR"

# Даем права на выполнение
ssh "$TARGET_USER@$TARGET_HOST" "chmod +x $TARGET_DIR/DO"

echo "Deployment completed successfully"

