#!/bin/bash

PROGRAM="./code-samples/DO"

# Проверяем, существует ли программа
[ ! -f "$PROGRAM" ] && { echo "Error: $PROGRAM not found!"; exit 1; }

# Проверка, что программа исполняемая
[ ! -x "$PROGRAM" ] && { echo "Error: $PROGRAM not executable!"; exit 1; }

echo "Запуск интеграционных тестов..."

# Функция тестирования
# Параметры: входные_данные ожидаемый_вывод is_success (0=успех, 1=ошибка)
tests() {
  local input="$1"
  local expected_output="$2"
  local is_success="$3"  # 0 для успеха, 1 для ошибки
  
  if [ -z "$input" ]; then # -z проверяет, пустая ли строка
    # Запуск без аргументов
    result=$(./"$PROGRAM" 2>&1) # 2>&1 - перенаправляет stderr (ошибки) в stdout
    code=$? # сохраняет код возврата программы
  else
    # Запуск с аргументом
    result=$(./"$PROGRAM" "$input" 2>&1)
    code=$?
  fi
  
  if [ "$is_success" -eq 0 ]; then
    # Тест на успех: код должен быть 0
    if [ "$result" = "$expected_output" ] && [ $code -eq 0 ]; then
      echo "$input: OK"
      return 0
    else
      echo "$input: FAIL (success test)"
      echo "Expected: '$expected_output' (code: 0)"
      echo "Got: '$result' (code: $code)"
      exit 1
    fi
  else
    # Тест на ошибку: код должен быть не 0
    if [ "$result" = "$expected_output" ] && [ $code -ne 0 ]; then
      echo "$input: OK"
      return 0
    else
      echo "$input: FAIL (error test)"
      echo "Expected: '$expected_output' (code: ≠0)"
      echo "Got:      '$result' (code: $code)"
      exit 1
    fi
  fi
}

echo "Корректные тесты (ожидается код 0):"
tests "1" "Learning to Linux" 0
tests "2" "Learning to work with Network" 0
tests "3" "Learning to Monitoring" 0
tests "4" "Learning to extra Monitoring" 0
tests "5" "Learning to Docker" 0
tests "6" "Learning to CI/CD" 0

echo "Некорректные тесты (ожидается код ≠0):"
tests "" "Bad number of arguments!" 1
tests "0" "Bad number!" 1
tests "7" "Bad number!" 1
tests "abc" "Bad number!" 1
tests "-5" "Bad number!" 1
tests "999" "Bad number!" 1

echo "Все тесты пройдены!"