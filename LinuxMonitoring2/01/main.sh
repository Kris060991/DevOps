#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/validators.sh"
source "$SCRIPT_DIR/generator.sh"
source "$SCRIPT_DIR/logger.sh"

main() {

# Проверка количества параметров
if [ $# -ne 6 ]; 
  then
    echo "Ошибка: Неверное количество параметров, скрипт должен запускаться с 6 параметрами"
    echo "Использование: $0 <абсолютный_путь> <количество_папок> <буквы_папок> <количество_файлов> <буквы_файлов> <размер_файла>"
    echo "Пример: $0 /opt/test 4 az 5 az.az 3kb"
    exit 1
fi

# Параметры
local abs_path="$1"
local num_folders="$2"
local folder_chars="$3"
local num_files="$4"
local file_chars="$5"
local file_size_kb="$6"
    

# Валидация параметров
validate_absolute_path "$abs_path"
validate_number "$num_folders" "number of folders"
validate_folder_chars "$folder_chars"
validate_number "$num_files" "number of files"
validate_file_chars "$file_chars"
validate_file_size "$file_size_kb"

# Проверка свободного места
check_disk_space

# Создание целевой директории если не существует
create_directory "$abs_path"

# Инициализация логгера
init_logger "$abs_path"
    
# Генерация папок и файлов
generate_folders_and_files "$abs_path" "$num_folders" "$folder_chars" "$num_files" "$file_chars" "$file_size_kb"
    
echo "Генерация успешно завершена!"
echo "Файл журнала: ${abs_path}/generation_log.txt"
}

# Запуск основной функции
main "$@"
