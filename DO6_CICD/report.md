## Part 1. Настройка gitlab-runner 
1. Поднимаю виртуальную машину с Ubuntu Server 22.04 LTS 
2. Устанавливаю Gitlab Runner 
- Добавить репозиторий GitLab: curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash  
- Установить gitlab-runner: sudo apt-get install gitlab-runner  
![Установка Gitlab Runner](img/1.2.1.png "Установка Gitlab Runner")  
![Установка Gitlab Runner](img/1.2.2.png "Установка Gitlab Runner") 
3. Запусти gitlab-runner и зарегистрируй его для использования в текущем проекте (DO6_CICD) 
- Запустим службу: sudo systemctl start gitlab-runner  
- Включим автозапуск при загрузке: sudo systemctl enable gitlab-runner 
- Проверим статус: sudo systemctl status gitlab-runner --no-pager -l
![Запуск gitlab-runner](img/1.3.1.png "Запуск gitlab-runner") 
- Регистрируем gitlab-runner: sudo gitlab-runner register 
![Регистрируем gitlab-runner](img/1.3.2.png "Регистрируем gitlab-runner") 

## Part 2. Сборка
Если проект SimpleBashUtils не выполнен  
1. Напиши этап для CI по сборке приложения из папки code-samples DO. 
2. В файле .gitlab-ci.yml добавь этап запуска сборки через мейк файл из папки code-samples. 
3. Файлы, полученные после сборки (артефакты), сохрани в произвольную директорию со сроком хранения 30 дней. 
![содержимое gitlab-ci.yml](img/2.1.png "содержимое gitlab-ci.yml") 
4. Закомиттим и запушим изменения: 
- git add .gitlab-ci.yml
- git commit -m'task2'
- git push origin develop
5. Проверяем, что Runner отработал корректно: 
![Runner отработал корректно](img/2.5.png "Runner отработал корректно") 
![Runner отработал корректно](img/2.5.1.png "Runner отработал корректно") 
6. Проверим, что артефакты сохранились в code-samples: 
![артефакты в code-samples](img/2.6.png "артефакты в code-samples")  

## Part 3. Тест кодстайла 
1. Напиши этап для CI, который запускает скрипт кодстайла (clang-format). 
![clang-format](img/3.1.png "clang-format")
2. Применяем изменения: 
- git add .gitlab-ci.yml 
- git commit -m 'task3' 
- git push origin develop 
3. Если кодстайл не прошел, то «зафейли» пайплайн. 
![кодстайл не прошел](img/3.3.png "кодстайл не прошел") 
![кодстайл не прошел](img/3.3.1.png "кодстайл не прошел") 
4. скопируем .clang-format в code-samples/ и запустим с флагом -i (Изменить файл на месте): 
- cp materials/linters/.clang-format code-samples/
- clang-format -i code-samples/*.c3.4 
![отформатировали main.c с помощью clang-format](img/3.4.png "отформатировали main.c с помощью clang-format")
5. Применяем изменения, чтобы заново запустить пайплан: 
- git add .gitlab-ci.yml code-samples/main.c
- git commit -m 'task3end' 
- git push origin develop 
6. В пайплайне отобрази вывод утилиты clang-format. Проверка на стиль пройдена (отформатировали с флагом -i main.c) 
![пайплайн passed](img/3.6.png "пайплайн passed")
![Проверка на стиль пройдена](img/3.6.1.png "Проверка на стиль пройдена")
7. Далее собирается build 
![собирается build](img/3.7.png "собирается build") 

## Part 4. Интеграционные тесты
1. Для проекта из папки code-samples напиши интеграционные тесты. Тесты должны вызывать собранное приложение для проверки его работоспособности на разных случаях. 
![интеграционные тесты](img/4.1.png "интеграционные тесты") 
![интеграционные тесты](img/4.1.1.png "интеграционные тесты") 
2. Добавляем в файл .gitlab-ci.yml этап integration_test, в которой скрипт будет интегрирован в пайплайн как отдельный этап и будет запускаться только после успешного прохождения этапов clang-format (проверка кодстайла) и build (сборка) 
![интеграционные тесты в .gitlab-ci.yml](img/4.2.png "интеграционные тесты в .gitlab-ci.yml") 
3. Применяем изменения в Git:
- git add .gitlab-ci.yml src/integration_test.sh
- git commit -m "task4"
- git push origin develop
4. Проверяем 
![тесты прошли](img/4.4.png "тесты прошли") 
![тесты прошли](img/4.4.1.png "тесты прошли") 

## Part 5. Этап деплоя
1. Подними вторую виртуальную машину Ubuntu Server 22.04 LTS. 
![две виртуальные машины](img/5.1.png "две виртуальные машины")  
2. Необходимо настроить подключение по ssh без пароля c GitLab Runner 
    - sudo -u gitlab-runner -i команда для работы от имени пользователя GitLab Runner (для выхода exit) 
    - ssh-keygen -t ed25519 -C "gitlab-runner-key" -f ~/.ssh/id_ed25519 -N "" Создание безопасного ключа  
    - ssh-copy-id deploy@192.168.1.88 Копирование ssh ключа  
![подключение по ssh без пароля c GitLab Runner](img/5.2.png "подключение по ssh без пароля c GitLab Runner")  
3. Проверяем возможность зайти по ssh без пароля на сервер деплоя с пользователя gitlab-runner: ssh deploy@192.168.1.88  
![проверка подключения](img/5.3.png "проверка подключения")  
4. Напиши bash-скрипт, который при помощи ssh и scp копирует файлы, полученные после сборки (артефакты), в директорию /usr/local/bin второй виртуальной машины. 
![deploy.sh](img/5.4.png "deploy.sh")  
5. В файле .gitlab-ci.yml добавь этап запуска написанного скрипта. 
![deploy в .gitlab-ci.yml](img/5.5.png "deploy в .gitlab-ci.yml")  
6. Применяем изменения в Git:
    - git add .gitlab-ci.yml src/deploy.sh
    - git commit -m "task5"
    - git push origin develop
7. Проверяем piplines в Git 
![Проверяем piplines в Git](img/5.7.png "Проверяем piplines в Git") 
8. Запусти этот этап вручную при условии, что все предыдущие этапы прошли успешно. 
![запуск deploy](img/5.8.png "запуск deploy") 
9. Готовое к работе приложение из папки code-samples (DO) на второй виртуальной машине 
![Готовое к работе приложение на второй виртуальной машине](img/5.9.png "Готовое к работе приложение на второй виртуальной машине") 
10. Сохрани дампы образов виртуальных машин. 
![дампы образов виртуальных машин](img/5.10.png "дампы образов виртуальных машин") 
![дампы образов виртуальных машин](img/5.10.1.png "дампы образов виртуальных машин") 