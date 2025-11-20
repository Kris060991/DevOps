#!/bin/bash

# Методы очистки

# По файлу журнала

clean_by_log() {
  local log_files=($(find_log_files))
  local log_file=""
    
  if [ ${#log_files[@]} -eq 0 ]; 
    then
      echo "Файлы журнала не найдены"
      return 1
  fi

  if [ ${#log_files[@]} -eq 1 ]; 
    then
      log_file="${log_files[0]}"
    else
      echo "Найдено несколько файлов журнала:"
      for i in "${!log_files[@]}"; 
        do
          echo "$((i+1))) ${log_files[i]}"
        done
        read -p "Выберите файл (1-${#log_files[@]}): " choice
        if [[ ! "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#log_files[@]} ]; 
          then
            echo "Неверный выбор"
            return 1
        fi
        log_file="${log_files[$((choice-1))]}"
  fi
    
  echo "Используется файл журнала: $log_file"

  # Извлекаем пути из лог-файла
  local paths_to_remove=()
  while IFS= read -r line; do
    if [[ "$line" =~ ^\[.*\]\ (DIR|FILE):\ (.*)(\ \|\ Size:.*)?$ ]]; 
      then
        local path="${BASH_REMATCH[2]}"
        paths_to_remove+=("$path")
    fi
  done < "$log_file"
    
  if [ ${#paths_to_remove[@]} -eq 0 ]; 
    then
      echo "В лог-файле не найдено записей о созданных файлах/папках."
      return 1
  fi

  # Показываем найденные объекты и запрашиваем подтверждение
  echo "Найдено объектов для удаления: ${#paths_to_remove[@]}"

  # Подтверждение удаления
  read -p "Удалить эти объекты? (y/n): " confirm
  if [[ ! "$confirm" =~ ^[YyДд]$ ]]; then
    echo "Отмена удаления"
    return 0
  fi
    
  # Удаляем в обратном порядке (сначала файлы, потом папки)
  local files_removed=0
  local dirs_removed=0
    
  # Сначала удаляем все файлы
  for path in "${paths_to_remove[@]}"; do
    if [ -f "$path" ]; 
      then
        safe_remove "$path" "file"
        ((files_removed++))
    fi
  done
    
  # Затем удаляем ВСЕ папки (в обратном порядке для вложенных структур)
  # Используем принудительное удаление с рекурсией для непустых папок
  for ((i=${#paths_to_remove[@]}-1; i>=0; i--)); do
    local path="${paths_to_remove[i]}"
    if [ -d "$path" ]; 
      then
        # Принудительно удаляем папку со всем содержимым
        if rm -rf "$path" 2>/dev/null; 
          then
            echo "Удалена папка: $path"
            ((dirs_removed++))
          else
            echo "Ошибка при удалении папки: $path"
        fi
    fi
  done
    
  echo "Удалено: $files_removed файлов, $dirs_removed папок"
    
  # Предлагаем удалить сам лог-файл
  read -p "Удалить файл журнала $log_file? (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; 
    then
      rm -f "$log_file"
      echo "Файл журнала удален"
  fi
}

# Очистка по дате и времени создания

clean_by_datetime() {
    echo "Выбран метод: Очистка по дате и времени создания"
    echo "Введите дату в формате ДД.ММ.ГГГГ ЧЧ:ММ (например: 20.10.2025 14:30)"

    local start_date=""
    local end_date=""

    # Ввод начальной даты
    while true; do
        read -p "Начальная дата и время: " start_date
        if [[ "$start_date" =~ ^[0-9]{2}\.[0-9]{2}\.[0-9]{4}\ [0-9]{2}:[0-9]{2}$ ]]; 
            then
                break
            else
            echo "Ошибка: используйте формат ДД.ММ.ГГГГ ЧЧ:ММ"
        fi
    done

    # Ввод конечной даты
    while true; do
        read -p "Конечная дата и время: " end_date
        if [[ "$end_date" =~ ^[0-9]{2}\.[0-9]{2}\.[0-9]{4}\ [0-9]{2}:[0-9]{2}$ ]]; 
            then
                break
            else
            echo "Ошибка: используйте формат ДД.ММ.ГГГГ ЧЧ:ММ"
        fi
    done

    # Конвертируем в timestamp
    local start_ts=$(date -d "$(echo "$start_date" | awk -F'[. ]' '{print $3"-"$2"-"$1" "$4}')" +%s 2>/dev/null)
    local end_ts=$(date -d "$(echo "$end_date" | awk -F'[. ]' '{print $3"-"$2"-"$1" "$4}')" +%s 2>/dev/null)

    if [ -z "$start_ts" ] || [ -z "$end_ts" ]; then
        echo "Ошибка конвертации даты"
        return 1
    fi

    echo "Поиск файлов созданных с $start_date по $end_date"

    # Поиск файлов и папок по шаблону имени
    local items_to_remove=()
    local search_paths=("/home/$USER" "/tmp" "/var/tmp")

    for path in "${search_paths[@]}"; do
        if [ -d "$path" ] && [ -r "$path" ]; then
            echo "Поиск в: $path"
            
            # Поиск файлов
            while IFS= read -r item; do
                if [ -n "$item" ] && [[ "$(basename "$item")" =~ ^[a-zA-Z]+_[0-9]{6}$ ]]; 
                    then
                        items_to_remove+=("$item")
                fi
            done < <(find "$path" -type d -name "*_*" 2>/dev/null)

            # Поиск папок
            while IFS= read -r item; do
                if [ -n "$item" ] && [[ "$(basename "$item")" =~ ^[a-zA-Z]+_[0-9]{6} ]]; 
                    then
                        items_to_remove+=("$item")
                fi
            done < <(find "$path" -type f -name "*_*" 2>/dev/null)
        fi
    done

    # Фильтруем по времени создания
    local filtered_items=()
    local found_count=0
    
    for item in "${items_to_remove[@]}"; do
        if [ -e "$item" ]; then
            local file_ts=$(stat -c %Y "$item" 2>/dev/null)
            if [ -n "$file_ts" ] && [ "$file_ts" -ge "$start_ts" ] && [ "$file_ts" -le "$end_ts" ]; then
                filtered_items+=("$item")
                ((found_count++))
            fi
        fi
    done

    items_to_remove=("${filtered_items[@]}")

    # Показываем найденные объекты
    echo "Найдено объектов: ${#items_to_remove[@]}"
    echo "Список найденных объектов:"
    for item in "${items_to_remove[@]}"; do
        local file_time=$(date -d "@$(stat -c %Y "$item" 2>/dev/null)" "+%d.%m.%Y %H:%M" 2>/dev/null || echo "неизвестно")
        if [ -f "$item" ]; then
            echo " ФАЙЛ: $item (изменен: $file_time)"
        elif [ -d "$item" ]; then
            echo " ПАПКА: $item (изменен: $file_time)"
        fi
    done

    # Подтверждение удаления
    read -p "Удалить эти объекты? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[YyДд]$ ]]; then
        echo "Отмена удаления"
        return 0
    fi

    # Удаление
    local removed_count=0
    for item in "${items_to_remove[@]}"; do
        if rm -rf "$item" 2>/dev/null; then
            echo "Удалено: $item"
            ((removed_count++))
        else
            echo "Ошибка удаления: $item"
        fi
    done

    echo "Всего удалено объектов: $removed_count"
}

# По маске имени (т. е. символы, подчеркивание и дата)
    
clean_by_name_mask() {
  echo "Введите маску имени (буквы используемые в названии)"
  echo "Пример: для файлов вида 'abcde_201121' введите 'abcde'"
    
  local name_chars=""
  while true; do
    read -p "Маска имени: " name_chars
    if [[ "$name_chars" =~ ^[a-zA-Z]{1,7}$ ]]; 
      then
        break
      else
        echo "Ошибка: маска должна содержать от 1 до 7 английских букв"
    fi
  done
    
  # Создаем шаблон для поиска
  local pattern="${name_chars}_[0-9][0-9][0-9][0-9][0-9][0-9]"
    
  echo "Поиск по шаблону: $pattern"
    
  # Поиск файлов и папок по шаблону
  local items_to_remove=()

   # Расширяем список путей для поиска
  local search_paths=(
    "/home/$USER"
    "/tmp"
    "/var/tmp"
    "$HOME"
  )
    
 for path in "${search_paths[@]}"; do
    if [ -d "$path" ] && [ -r "$path" ]; 
      then
        echo "Поиск в: $path"
            
        # Поиск файлов и папок
       while IFS= read -r -d '' item; do
            items_to_remove+=("$item")
        done < <(find "$path" \( -type f -name "${pattern}*" -o -type d -name "${pattern}" \) -print0 2>/dev/null)
    fi
  done
    
  # Убираем дубликаты
  local unique_items=()
  for item in "${items_to_remove[@]}"; do
    if [[ ! " ${unique_items[@]} " =~ " ${item} " ]] && [ -n "$item" ]; 
      then
        unique_items+=("$item")
    fi
  done
    
  items_to_remove=("${unique_items[@]}")
    
  if [ ${#items_to_remove[@]} -eq 0 ]; 
    then
      echo "Не найдено объектов для удаления по маске '$name_chars'"
      echo "Проверьте:"
      echo "1. Правильность введенной маски"
      echo "2. Что файлы/папки существуют"
      echo "3. Что у вас есть права на чтение в директориях"
      return 1
  fi
    
  echo "Найдено объектов: ${#items_to_remove[@]}"
  echo "Список найденных объектов:"
  for item in "${items_to_remove[@]}"; do
    if [ -f "$item" ]; 
      then
        echo "  ФАЙЛ: $item"
      elif [ -d "$item" ]; 
        then
          echo "  ПАПКА: $item"
    fi
  done
    
    # Подтверждение удаления с предупреждением о непустых папках
    local non_empty_folders=0
    for item in "${items_to_remove[@]}"; do
        if [ -d "$item" ] && [ -n "$(ls -A "$item" 2>/dev/null)" ]; then
            ((non_empty_folders++))
        fi
    done
    
    if [ $non_empty_folders -gt 0 ]; then
        echo "ВНИМАНИЕ: Будут удалены $non_empty_folders непустых папок со всем содержимым!"
    fi
    
    read -p "Удалить ${#items_to_remove[@]} объектов? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[YyДд]$ ]]; then
        echo "Отмена удаления"
        return 0
    fi
    
  # Удаление
    local removed_count=0
    local error_count=0

  # Сначала удаляем файлы
    for item in "${items_to_remove[@]}"; do
        if [ -f "$item" ]; then
            if rm -f "$item" 2>/dev/null; then
                echo "Удален файл: $item"
                ((removed_count++))
            else
                echo "Ошибка удаления файла: $item"
                ((error_count++))
            fi
        fi
    done
    
    # Затем папки 
    for ((i=${#items_to_remove[@]}-1; i>=0; i--)); do
        local item="${items_to_remove[i]}"
        if [ -d "$item" ]; then
            # удаляем папку со всем содержимым
            if rm -rf "$item" 2>/dev/null; then
                echo "Удалена папка: $item"
                ((removed_count++))
            else
                echo "Ошибка удаления папки: $item"
                ((error_count++))
            fi
        fi
    done
    
    echo "Всего удалено объектов: $removed_count"
    if [ $error_count -gt 0 ]; then
        echo "Ошибок при удалении: $error_count"
    fi
}