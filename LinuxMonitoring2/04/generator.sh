#!/bin/bash

generate_ip() {
	ip1=$(( RANDOM % 256))
	ip2=$(( RANDOM % 256))
	ip3=$(( RANDOM % 256))
	ip4=$(( RANDOM % 256))
	echo "$ip1.$ip2.$ip3.$ip4"
}

generate_code(){
    # 200: OK – Запрос выполнен успешно
    # 201: Created – Запрос успешно выполнен, ресурс создан
    # 400: Bad Request – Неверный запрос
    # 401: Unauthorized – Не авторизован
    # 403: Forbidden – Запрещено
    # 404: Not Found – Ресурс не найден
    # 500: Internal Server Error – Ошибка на сервере
    # 501: Not Implemented – Не реализовано
    # 502: Bad Gateway – Неверный шлюз
    # 503: Service Unavailable – Сервис недоступен
	HTTP_CODES=(200 201 400 401 403 404 500 501 502 503)
	echo "${HTTP_CODES[RANDOM % ${#HTTP_CODES[@]}]}"
}

generate_method(){
	METHODS=("GET" "POST" "PUT" "PATCH" "DELETE")
	echo "${METHODS[RANDOM % ${#METHODS[@]}]}"
}

generate_timestamp_for_day() {
    local target_date="$1"
    local start_of_day=$(date -d "$target_date 00:00:00" +%s)
    local end_of_day=$(date -d "$target_date 23:59:59" +%s)

    local random_time=$((start_of_day + RANDOM % (end_of_day - start_of_day + 1)))

    echo "$(date -d "@$random_time" +"%d/%b/%Y:%H:%M:%S +0000")"
}

generate_urls() {
	URLS=("/" "/index.html" "/about" "/contact" "/api/users" "/api/products" "/login" "/logout" "/profile" "/search?q=test" "/images/logo.png" "/css/style.css" "/js/app.js" "/404.html" "/admin")

    echo ${URLS[RANDOM % ${#URLS[@]}]}
}

generate_agents(){
	AGENTS=(
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0"
    "Opera/9.80 (X11; Linux i686; Ubuntu/14.10) Presto/2.12.388 Version/12.16"
    "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
    "curl/7.68.0"
    "Wget/1.20.3 (linux-gnu)"
    "python-requests/2.28.1")
	echo ${AGENTS[RANDOM % ${#AGENTS[@]}]}
}

generate_log_entry() {
    local ip
    local timestamp
    local method
    local url
    local code
    local agent

    ip=$(generate_ip)
    timestamp=$(generate_timestamp_for_day "$1")
    method="$(generate_method)"
    url="$(generate_urls)"
    code="$(generate_code)"
    agent="$(generate_agents)"

    local size=$((RANDOM % 10000))

    echo "$ip - - [$timestamp] \"$method $url HTTP/1.1\" $code $size \"-\" \"$agent\""
}