## Part 1. Запуск нескольких Docker-контейнеров с использованием Docker Compose
1. Напиши Dockerfile для каждого отдельного микросервиса. Необходимые зависимости описаны в материалах. В отчете отобрази размер собранных образов любого сервиса различными способами. 
  - Используем Multi-stage сборку в Docker, чтобы сократить объем финального образа. 
  - Dockerfile структура: 
    - Сборка приложения. Maven - инструмент для сборки Java-проектов 
      FROM arm64v8/maven:3.8.6-openjdk-8 AS build  
    - Создаем папку /app. Все команды (COPY, RUN) будут работать из этой папки 
      WORKDIR /app  
    - Копируем файлы проекта. pom.xml - файл с описанием зависимостей (как package.json). src/ - папка с исходным кодом Java  
      COPY pom.xml . 
      COPY src ./src  
    - Собираем приложение:
      mvn - команда Maven.   
      clean - очистить предыдущие сборки.  
      package - собрать проект. 
      -DskipTests - пропустить тесты.  
      -B - "batch mode" (без лишних вопросов). 
      --no-transfer-progress - меньше логов о загрузке.   
      Результат: в папке /app/target/ появится файл *.jar  
      RUN mvn clean package -DskipTests -B --no-transfer-progress  
    - Финальный образ. А теперь возьмем другой, легкий образ - только Java для запуска.  
      Alpine - очень маленький Linux       
      Первый образ тяжелый мы используем только для сборки, а запускаем на легком.  
      FROM arm64v8/openjdk:8-jre-alpine
      WORKDIR /app
    - Копируем собранный JAR из этапа сборки: 
      --from=build - берем файлы из первого этапа.  
      /app/target/*.jar - оттуда берем собранный JAR.  
      app.jar - сюда копируем и переименовываем. 
      COPY --from=build /app/target/*.jar app.jar 
    - Копируем и настраиваем wait-for-it скрипт
      COPY wait-for-it.sh /app/wait-for-it.sh. 
      RUN apk add --no-cache bash && chmod +x /app/wait-for-it.sh   
    - Открываем порт сервиса. 
      EXPOSE 8081 
    - Запускаем с ожиданием PostgreSQL: 
      /bin/sh -c - запускает shell 
      /app/wait-for-it.sh postgres:5432 - ждет доступности базы 
      -- - разделитель 
      java -jar app.jar - запускает Java-приложение 
      ENTRYPOINT ["/bin/sh", "-c", "/app/wait-for-it.sh postgres:5432 -- java -jar app.jar"] 
  - Dockerfile для session-service
  ![session-service Dockerfile](img/session-service:Dockerfile.png "session-service Dockerfile") 
  Собираю: docker build -t session-service:1.0 .
  ![session-service docker build](img/session-service:Build.png "session-service docker build]") 
  - Dockerfile для booking-service 
  ![booking-service Dockerfile](img/booking-service:Dockerfile.png "booking-service Dockerfile")   
  Собираю: docker build -t booking-service:1.0 .  
  ![booking-service build](img/booking-service:build.png "booking-service build")  
  - Dockerfile для gateway-service
  ![gateway-service Dockerfile](img/gateway-service:Dockerfile.png "gateway-service Dockerfile")  
  Собираю: docker build -t gateway-service:1.0 .  
  ![gateway-service build](img/gateway-service:build.png "gateway-service build")  
  - Dockerfile для hotel-service
  ![hotel-service Dockerfile](img/hotel-service:Dockerfile.png "hotel-service Dockerfile") 
  Собираю: docker build -t hotel-service:1.0 . 
  ![hotel-service build](img/hotel-service:build.png "hotel-service build") 
  - Dockerfile для loyalty-service 
  ![loyalty-service Dockerfile](img/loyalty-service:Dockerfile.png "loyalty-service Dockerfile") 
  Собираю: docker build -t loyalty-service:1.0 .  
  ![loyalty-service build](img/loyalty-service:build.png "loyalty-service build") 
  - Dockerfile для payment-service 
  ![payment-service Dockerfile](img/payment-service:Dockerfile.png "payment-service Dockerfile") 
  Собираю: docker build -t payment-service:1.0 .  
  ![payment-service build](img/payment-service:build.png "payment-service build") 
  - Dockerfile для report-service 
  ![report-service Dockerfile](img/report-service:Dockerfile.png "report-service Dockerfile") 
  Собираю: docker build -t report-service:1.0 .  
  ![report-service build](img/report-service:build.png "report-service build")  
  - Pазмер собранных образов: docker images 
  ![Pазмер собранных образов](img/1.png "Pазмер собранных образов")  

2. Напиши Docker Compose файл, который осуществляет корректное взаимодействие сервисов. Пробрось порты для доступа к gateway service и session service из локальной машины. Помощь по Docker Compose ты найдешь в материалах.
![Docker Compose файл](img/1.2.1.png "Docker Compose файл") 
![Docker Compose файл](img/1.2.2.png "Docker Compose файл") 
![Docker Compose файл](img/1.2.3.png "Docker Compose файл") 
![Docker Compose файл](img/1.2.4.png "Docker Compose файл") 
![Docker Compose файл](img/1.2.5.png "Docker Compose файл") 

3. Собери и разверни веб-сервис с помощью написанного Docker Compose файла на локальной машине. 
   - Запускаем без сборки, так как все необходимые образы у нас уже созданы и готовы к работе: docker-compose up -d  
  ![Запускаем docker-compose](img/1.3.1.png "Запускаем docker-compose") 
   - Проверяем статус: docker-compose ps 
  ![статус docker-compose](img/1.3.2.png "статус docker-compose") 

4. Прогони заготовленные тесты через postman и удостоверься, что все они проходят успешно. Инструкцию по запуску тестов можно найти в материалах. В отчете отобрази результаты тестирования.
  - Проверим, что сервис работает, введем команду, например: curl http://localhost:8087/api/v1/gateway/hotels
  ![Проверим, что сервис работает](img/1.4.1.png "Проверим, что сервис работает") 
  - Скачиваем и устанавливаем postman: https://www.postman.com/downloads/
  - Импортирую коллекцию src/application_tests.postman_collection.json 
  ![Импортирую коллекцию](img/1.4.2.png "Импортирую коллекцию") 
  - Все тесты прошли успешно 
  ![тесты прошли успешно ](img/1.4.3.png "тесты прошли успешно ")

## Part 2. Создание виртуальных машин

1. Установи и инициализируй Vagrant в корне проекта. Напиши Vagrantfile для одной виртуальной машины. Перенеси исходный код веб-сервиса в рабочую директорию виртуальной машины. Помощь по vagrant ты найдешь в материалах. 
   - Скачиваем и установливаем Vagrant с официального сайта HashiCorp Developer https://developer.hashicorp.com/vagrant/install 
   - Проверяем установку: vagrant -v и создаем рабочую директорию для Vagrant и переходим в нее: mkdir Vagrant, cd Vagrant 
  ![Vagrant](img/2.1.1.png "Vagrant")  
   - Далее создается Vagrantfile с помощью команды vagrant init 
  ![vagrant init](img/2.1.2.png "vagrant init")  
   - Теперь напишем Vagrantfile для одной виртуальной машины и перенесем исходный код веб-сервиса в ее рабочую директорию 
     - define в Vagrant используется для именования виртуальной машины и создания сложных конфигураций 
  ![Vagrantfile](img/vagrantfile.png "Vagrantfile")
   - Теперь запускаем виртуальную машину: vagrant up --provider=vmware_desktop hotel-booking
  ![запускаем виртуальную машину](img/2.1.3.png "запускаем виртуальную машину")  
   - Проверяем статус машины: vagrant status
  ![Проверяем статус машины](img/2.1.4.png "Проверяем статус машины") 

2. Зайди через консоль внутрь виртуальной машины и удостоверься, что исходный код встал, куда нужно. Останови и уничтожь виртуальную машину.
   - Далее, чтобы зайти в машину выполняем команду: vagrant ssh hotel-booking 
  ![заходим в машину](img/2.2.1.png "заходим в машину") 
   - Далее проверяим, что все папки с исходниками сервисов скопировались: 
  ![папки скопировались](img/2.2.2.png "папки скопировались")  
   - Выходим: exit
   - Останавливаем машину: vagrant halt hotel-booking  
   - Уничтожаем: vagrant destroy hotel-booking  
   - Проверяем статус: vagrant status 
  ![Уничтожаем машину](img/2.2.3.png "Уничтожаем машину")  

## Part 3. Создание простейшего Docker Swarm 

1. Модифицируй Vagrantfile для создания трех машин: manager01, worker01, worker02. Напиши shell-скрипты для установки Docker внутрь машин, инициализации и подключения к Docker Swarm. Помощь с Docker Swarm ты найдешь в материалах.  
   - Создадим папку scripts 
   - Создадим скрипт install_docker.sh (установка Docker на все машины) 
  ![install_docker.sh](img/install_docker.png "install_docker.sh")  
   - Создадим скрипт инициализации Swarm на manager init_swarm.sh (только для менеджера) 
  ![init_swarm.sh](img/init_swarm.png "init_swarm.sh") 
   - Создадим скрипт подключения worker‑ов к Swarm join_swarm.sh (для воркеров) 
  ![join_swarm.sh](img/join_swarm.png "join_swarm.sh") 
   - Теперь модифицируем наш Vagrantfile для создания трех машин: manager01, worker01, worker02 (копируя services/ на все машины, скрипты установки Docker и Docker-Compose - в каждую, manager_init_swarm.sh - только в manager01, а worker_join_swarm.sh - в оба worker'а, и задавая IP-адреса статически), где вместо трех отдельных блоков config.vm.define, напишем один цикл, использующий заданный ассоциативный массив IPS, сопоставляющий имена виртуальных машин их адреса  
  ![Vagrantfile](img/vagrantfile2.png "Vagrantfile")  
2. Загрузи собранные образы на Docker Hub и модифицируй Docker Compose файл для подгрузки расположенных на Docker Hub образов. 
   - Заходим в Docker Hub из терминала: docker login 
  ![docker login](img/docker_login.png "docker login")  
   - Тегирование образов: для каждого образа выполняем docker tag ЛОКАЛЬНЫЙ_ОБРАЗ:ТЕГ yourusername/ИМЯ_ОБРАЗА:ТЕГ  
    docker tag loyalty-service:1.0 ollyvala/loyalty-service:1.0
    docker tag payment-service:1.0 ollyvala/payment-service:1.0
    docker tag report-service:1.0 ollyvala/report-service:1.0
    docker tag hotel-service:1.0 ollyvala/hotel-service:1.0
    docker tag gateway-service:1.0 ollyvala/gateway-service:1.0
    docker tag booking-service:1.0 ollyvala/booking-service:1.0
    docker tag session-service:1.0 ollyvala/session-service:1.0
  ![docker tag](img/docker_tag.png "docker tag") 
   - Загрузим каждый образ на Docker Hub: 
    docker push ollyvala/loyalty-service:1.0 
    docker push ollyvala/payment-service:1.0 
    docker push ollyvala/report-service:1.0 
    docker push ollyvala/hotel-service:1.0 
    docker push ollyvala/gateway-service:1.0 
    docker push ollyvala/booking-service:1.0 
    docker push ollyvala/session-service:1.0 
  ![docker push](img/docker_push.png "docker push")  
  ![docker push](img/docker_push1.png "docker push") 
    - Зайдем на Docker Hub и проверим, что все образы были загружены в мой репозиторий 
  ![Docker Hub](img/docker_hub.png "Docker Hub") 
    - Модификацируем Docker Compose файл. Было локальные образы, заменим на образы с docker hub. А так же заменим в postgres относительный путь на абсолютный 
  ![Модификацируем Docker Compose](img/3.2.1.png "Модификацируем Docker Compose") 
  ![Модификацируем Docker Compose](img/3.2.2.png "Модификацируем Docker Compose") 
  ![Модификацируем Docker Compose](img/3.2.3.png "Модификацируем Docker Compose") 
  ![Модификацируем Docker Compose](img/3.2.4.png "Модификацируем Docker Compose")  
3. Подними виртуальные машины и перенеси на менеджер Docker Compose файл. Запусти стек сервисов, используя написанный Docker Compose файл. 
   - Поднимем виртуальные машины: vagrant up 
   - Убедимся, что машины были успешно созданы и запустились: vagrant status 
  ![vagrant status](img/3.3.1.png "vagrant status")  
   - Теперь зайдем на каждую виртуальную машину, и проверим:
     - IP
     - версию установленных Docker и Docker-Compose
     - перенос папки services/ на все машины
     - сами ноды и инициализацию Swarm (с менеджера)
   - Зайдем на manager01: vagrant ssh manager01 и выполним команду ip a 
  ![ip manager](img/manager01_ip_a.png "ip manager")  
    Далее проверим версии docker -v и docker-compose -v 
  ![версия docker](img/docker_v_manager.png "версия docker")  
    Далее проверим перенос папки с исходным кодом сервисов на менеджер 
  ![manager ls](img/manager_ls.png "manager ls")  
    Далее проверим успешное создание Swarm-кластера с одним manager'ом и, что worker'ы успешно к нему подключились, используя созданный токен: docker node ls
  ![docker node ls](img/docker_node_ls.png "docker node ls") 
    Выходим: exit
   - worker01 
  ![ip worker01](img/ip_worker01.png "ip worker01")  
  ![версия docker](img/docker_worker01.png "версия docker") 
  ![worker01 ls](img/worker01_ls.png "worker01 ls")  
   - worker02 
  ![ip worker02](img/ip_worker02.png "ip worker02") 
  ![версия docker](img/docker_worker02.png "версия docker")  
  ![worker02 ls](img/worker02_ls.png "worker02 ls") 
   - Теперь перенесем на машину-менеджера наш новый Docker Compose файл:
    cd vagrant , 
    vagrant upload docker-compose.yml /home/vagrant/ manager01
   - Теперь можно запускать стек сервисов, заходим на менеджера, проверяем доступность файла docker-compose.yml и запускаем деплой стэка с названием "hotel-app":
    vagrant ssh manager01
    ls -l /vagrant/ , 
    cd /vagrant/ , 
    docker stack deploy -c docker-compose.yml hotel-app
  ![запуск стек сервисов](img/docker_stack.png "запуск стек сервисов")  
   - Проверим, что все сервисы запустились, работают и имеют по одной реплике: docker service ls
  ![сервисы запустились](img/docker_service_ls.png "сервисы запустились") 
    Вывод команды означает, что контейнеры всех микросервисов и postgres успешно запущены и здоровы, Swarm смог поднять ровно по одной реплике каждого сервиса
4. Настрой прокси на базе nginx для доступа к gateway service и session service по оверлейной сети. Сами gateway service и session service сделай недоступными напрямую. 
   - Cоздадим конфиг nginx в общей папке проекта: cd /vagrant/, touch nginx.conf, ls
  ![vagrant@manager01 ls](img/3.4.1.png "vagrant@manager01 ls") 
  ![nginx](img/nginx.png "nginx")  
   - Далее модифицируем наш docker-compose.yml с nginx и overlay сетью. Добавляем driver: overlay для Swarm. Прописываем в настройках networks: net ко всем сервисам, чтобы они были в одной overlay‑сети. Убираем публикацию портов (раздел ports) у session-service и gateway-service, остальные можно оставить как есть. Добавляем nginx. 
  ![docker-compose](img/3.4.2.png "docker-compose")  
  ![docker-compose](img/3.4.3.png "docker-compose") 
  ![docker-compose](img/3.4.4.png "docker-compose") 
  ![docker-compose](img/3.4.5.png "docker-compose") 
  ![docker-compose](img/3.4.6.png "docker-compose") 
  ![docker-compose](img/3.4.7.png "docker-compose") 
  ![docker-compose](img/3.4.8.png "docker-compose") 
   - Перезапускаем стек на менеджере: удаляем старый docker stack rm hotel-app, запускаем новый docker stack deploy -c docker-compose.yml hotel-app 
  ![Перезапускаем стек на менеджере](img/3.4.9.png "Перезапускаем стек на менеджере")   
   - Проверяем: docker service ls
  ![Проверяем: docker service ls](img/3.4.10.png "Проверяем: docker service ls")  
5. Прогони заготовленные тесты через Postman и удостоверься, что все они проходят успешно. В отчете отобрази результаты тестирования. 
   - Открываем Postman (тесты у нас уже импортированы) и меняем IP на наш "менеджерский" - 192.168.94.10, потому что именно на нем опубликован порт nginx (80) и именно он проксирует запросы в overlay‑сеть Swarm (плюс порты на 80 меняем) 
  ![Postman settings](img/3.5.1.png "Postman settings") 
   - Запускаем тесты 
  ![Postman tests](img/3.5.2.png "Postman tests") 
6. Используя команды Docker, отобрази в отчете распределение контейнеров по узлам. 
   - Используем команду docker stack ps hotel-app | grep Running
  ![распределение контейнеров по узлам](img/3.6.png "распределение контейнеров по узлам") 
   - Количество запущенных сервисов на каждом узле:
     - manager01: 4 сервиса (booking, hotel, payment, session)
     - worker01: 4 сервиса (gateway, loyalty, nginx, rabbitmq)
     - worker02: 2 сервиса (postgres, report)
7. Установи отдельным стеком Portainer внутри кластера. В отчете отобрази визуализацию распределения задач по узлам с помощью Portainer. 
   - Portainer — это удобный веб-интерфейс для управления контейнерами, который упрощает работу с Docker, Docker Swarm, Kubernetes и ACI, позволяя администрировать контейнеры, образы, сети и тома через графический интерфейс вместо командной строки. 
   - Создаем docker-compose для Portainer: touch portainer-stack.yml
  ![portainer-stack.yml](img/3.7.1.png "portainer-stack.yml") 
   - Запускаем стэк и проверяем работу:
     - docker stack deploy -c portainer-stack.yml portainer
     - docker stack ps portainer
     - docker service ls
  ![portainer работает](img/3.7.2.png "portainer работает") 
   - Теперь открываем графическую версию в бразуере: http://192.168.195.100:9000 
   - Регистрируемся и перезапускаем portainer: docker service update --force portainer_portainer 
  ![перезапускаем portainer](img/3.7.3.png "перезапускаем portainer") 
   - Авторизовываемся, home, и жмем live connect 
   - Дашборд со всей информацией по нашему кластеру 
  ![Дашборд](img/3.7.4.png "Дашборд") 
   - Визуализация стека hotel-app: Stacks → hotel-app 
  ![Визуализация стека hotel-app](img/3.7.5.png "Визуализация стека hotel-app")
  ![Визуализация стека hotel-app](img/3.7.6.png "Визуализация стека hotel-app")