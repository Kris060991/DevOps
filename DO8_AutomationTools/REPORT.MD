## Part 1. Удаленное конфигурирование узла через Ansible 

1. Создать с помощью Vagrant три машины: manager, node01, node02. Не устанавливать с помощью shell-скриптов docker при создании машин на Vagrant! Прокинуть порты node01 на локальную машину для доступа к пока еще не развернутому микросервисному приложению. 
   - Vagrant init - создаем vagrantfile для создания трёх машин (manager, node1, node2) 
   ![vagrantfile](img/vagrantfile.png "vagrantfile") 
   - vagrant up - поднимаем виртуальные машины 
2. Подготовить manager как рабочую станцию для удаленного конфигурирования (помощь по Ansible в материалах).
   - Зайти на manager: vagrant ssh manager 
   - На manager проверить подключение к node01 через ssh по приватной сети. 
     - Зайти на node01, чтобы узнать ip a - 192.168.94.155 
     - На manager вводим ssh vagrant@192.168.94.155, пароль: vagrant 
   ![подключение к node01 через ssh](img/1.png "подключение к node01 через ssh") 
   - Сгенерировать ssh-ключ для подключения к node01 из manager (без passphrase): 
     - ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N "" 
      ![Генерируем ключ без пароля](img/key.png "Генерируем ключ без пароля") 
     - Копируем ключ на node01: ssh-copy-id -i ~/.ssh/id_rsa.pub vagrant@192.168.94.155, пароль: vagrant  
      ![Копируем ключ на node01](img/2.png "Копируем ключ на node01") 
     - Проверяем подключение: ssh vagrant@192.168.94.155 
      ![подключение node01](img/3.png "подключение node01") 
   - Скопировать на manager docker-compose файл и исходный код микросервисов. (Используй проект из папки src и docker-compose файл из предыдущей главы. Помощь по ssh в материалах.) 
     - В терминале на mac: cd src, vagrant upload docker-compose.yml /home/vagrant/ manager
      ![Копируем файл на manager](img/4.png "Копируем файл на manager") 
     - Проверяем на manager: ls -la /home/vagrant/docker-compose.yml 
      ![Проверяем на manager](img/5.png "Проверяем на manager") 
   - Установить Ansible на менеджер и создать папку ansible, в которой создать inventory-файл:
     - sudo apt update 
     - sudo apt install -y ansible 
     - mkdir ansible 
     - touch inventory.yml 
      ![Ansible](img/6.png "Ansible") 
      ![inventory.yml](img/7.png "inventory.yml") 
     - Создаем конфигурационный файл ansible.cfg: touch ansible.cfg 
      ![ansible.cfg](img/8.png "ansible.cfg") 
   - Использовать модуль ping для проверки подключения через Ansible: ansible all -m ping 
   ![ping через Ansible](img/9.png "ping через Ansible") 
3. Написать первый плейбук для Ansible, который выполняет apt update, устанавливает docker, docker-compose, копирует compose-файл из manager'а и разворачивает микросервисное приложение. 
   - На manager cd ansible/, touch deploy-app.yml, nano deploy-app.yml 
  ![плейбук для Ansible](img/10.png "плейбук для Ansible") 
  ![плейбук для Ansible](img/11.png "плейбук для Ansible") 
   - Запуск плейбука, для установки на node01: ansible-playbook deploy-app.yml --limit node01 
  ![Запуск плейбука](img/12.png "Запуск плейбука") 
  ![Запуск плейбука](img/13.png "Запуск плейбука") 
4. Прогнать заготовленные тесты через postman и удостовериться, что все они проходят успешно. В отчете отобразить результаты тестирования. 
   - меняем api_host на ip node01 и меняем порты 
  ![postman](img/14.png "postman") 
   - запускаем тесты 
  ![тесты postman](img/15.png "тесты postman") 
5. Сформировать три роли: 
   - роль application выполняет развертывание микросервисного приложения при помощи docker-compose; 
   - apache устанавливает и запускает стандартный apache сервер; 
   - postgres устанавливает и запускает postgres, создает базу данных с произвольной таблицей и добавляет в нее три произвольные записи. 
   - Назначить первую роль node01 и вторые две роли node02, проверить postman-тестами работоспособность микросервисного приложения, удостовериться в доступности postgres и apache-сервера. Для Apache веб-страница должна открыться в браузере. Что касается PostgreSQL, необходимо подключиться с локальной машины и отобразить содержимое ранее созданной таблицы с данными. 

   - node01 - роль application 
   - node02 - apache и postgres 
   ![роли](img/roles.png "роли")
   - Создаем директории 
     - mkdir -p roles/application/{tasks,files}  
     - mkdir -p roles/apache/tasks  
     - mkdir -p roles/postgres/{tasks,handlers,files}  
     - mkdir -p ~/ansible/roles/application/files/database  
   ![структура файлов](img/16.png "структура файлов")  
   - Копируем наши существующие файлы 
     - cp ~/docker-compose.yml ~/ansible/roles/application/files/  
     - cp ~/services/database/init.sql ~/ansible/roles/application/files/database/  
   - Переходим ~/ansible/roles/application/tasks   
   - Создаем файл main.yml: touch main.yml  
   ![main.yml](img/17.png "main.yml") 
   - Переходим ~/ansible/roles/postgres/files/ 
   - Создаем init.sql для тестовой базы данных: touch init.sql 
   ![init.sql](img/init.png "init.sql") 
   - Переходим ~/ansible/roles/postgres/tasks/ 
   - Создаем файл main.yml: touch main.yml  
   ![main.yml](img/18.png "main.yml") 
   - Переходим ~/ansible/roles/apache 
   - Создаем файл main.yml: touch main.yml 
   ![main.yml](img/19.png "main.yml") 
   - Запускаем: ansible-playbook playbook-roles.yml 
   ![Запускаем playbook-roles.yml](img/start_ansible.png "Запускаем playbook-roles.yml")  
   - Проверим postman-тестами работоспособность микросервисного приложения  
   ![тесты](img/tests.png "тесты")  
   - Удостовериться в доступности postgres и apache-сервера  
   ![apache](img/apache.png "apache") 
   ![postgres](img/db.png "postgres")  
6. Созданные в этом разделе файлы разместить в папке src\ansible01 в личном репозитории 

## Part 2. Service Discovery 

1. Написать два конфигурационных файла для consul (информация по consul в материалах): 
   - consul_server.hcl:  
     - настроить агент как сервер;  
     - указать в advertise_addr интерфейс, направленный во внутреннюю сеть Vagrant; 
   - consul_client.hcl:  
     - настроить агент как клиент;  
     - указать в advertise_addr интерфейс, направленный во внутреннюю сеть Vagrant.   
![consul_server.hcl](img/consul_server.png "consul_server.hcl") 
![consul_client.hcl](img/consul_client.png "consul_client.hcl") 
![consul_client.hcl](img/consul_client1.png "consul_client.hcl") 
2. Создать с помощью Vagrant четыре машины: consul_server, api, manager и db. 
Прокинуть порт 8082 с api на локальную машину для доступа к пока еще не развернутому api. 
Прокинуть порт 8500 с consul_server для доступа к ui consul.  
![vagrantfile](img/vagrantfile2.png "vagrantfile")  
![vagrantfile](img/vagrantfile2.1.png "vagrantfile")   
3. Написать плейбук для ansible и четыре роли: 
   - playbook-roles.yml  
    ![playbook-roles](img/playbook-roles.png "playbook-roles") 
   - структура файлов будет такой:  
    ![структура файлов](img/2.3.png "структура файлов")  
   - install_consul_server, которая: 
     - работает с consul_server; 
     - копирует consul_server.hcl; 
     - устанавливает consul и необходимые для consul зависимости; 
     - запускает сервис consul; 
    ![](img/main-yml.png "main.yml") 
    ![](img/main-yml1.png "main.yml") 
   - install_consul_client, которая: 
     - работает с api и db; 
     - копирует consul_client.hcl; 
     - устанавливает consul, envoy и необходимые для consul зависимости; 
     - запускает сервис consul и consul-envoy; 
    ![](img/main-yml2.png "main.yml") 
    ![](img/main-yml3.png "main.yml") 
    ![](img/main-yml4.png "main.yml") 
   - install_db, которая: 
     - работает с db; 
     - устанавливает postgres и запускает его; 
     - создает базу данных hotels_db; 
    ![](img/main-yml5.png "main.yml") 
   - install_hotels_service, которая: 
     - работает с api; 
     - копирует исходный код сервиса; 
     - устанавливает openjdk-8-jdk; 
     - создает глобальные переменные окружения: 
       - POSTGRES_HOST="127.0.0.1"; 
       - POSTGRES_PORT="5432"; 
       - POSTGRES_DB="hotels_db"; 
       - POSTGRES_USER="<имя пользователя>"; 
       - POSTGRES_PASSWORD="<пароль пользователя>"; 
     - запускает собранный jar-файл командой java -jar <путь до hotel-service>/hotel-service/target/<имя jar-файла>.jar.  
    ![](img/main-yml6.png "main.yml")  
    ![](img/main-yml7.png "main.yml")  
4. Ход выполнения после написания файлов 1-3: 
   - vagrant up - поднимаем виртуальные машины 
   - vagrant ssh manager - подключаемся к менеджеру 
   - проверяем ip и добавляем в inventory.yml, consul_client.hcl.j2, consul_server.hcl 
   - Копируем ключ на все машины с manager: ssh-copy-id -i ~/.ssh/id_rsa.pub vagrant@192.168.94. , пароль: vagrant 
   - С mac копируем папку - vagrant upload ansible02  /home/vagrant/ansible/ manager  
   - На manager проверяем - ansible all -m ping  
   - Запускаем ansible-playbook playbook-roles.yml   
  ![Запускаем ansible-playbook](img/2.4.png "Запускаем ansible-playbook") 
5. Проверить работоспособность CRUD-операций над сервисом отелей. В отчете отобразить результаты тестирования. Работает только create и read, т.к. приложение глюченное, Update и Delete не работают. 
   - Create (Создание) 
  ![Create](img/create.png "Create") 
   - Read (Чтение) 
  ![Read](img/read.png "Read") 
  ![Read](img/read1.png "Read") 
  ![Read](img/read2.png "Read") 
  - consul: http://192.168.94.205:8500 (http://ip consul_server:8500) 
  ![consul](img/2.5.png "consul") 
6. Созданные в этом разделе файлы разместить в папке src\ansible02 в личном репозитории.  
