# Задача

~~Есть сущность пользователь (User). Он может быть трех типов:
~~
- Администратор
- Модератор
- Исполнитель
- Рекламодатель
~~
Каждый тип юзера, характеризуется опеределенным набором 
свойств, какие-то свойства общие для всех типов 
пользователей, какие-то характеризуют конкретного. 

~~Обязательные общие свойства:
- почта;
- имя;
- телефон.

~~Свойства рекламодателя:
- должность;
- название организации.

Необходимо создать небольшое Rails-приложение для работы 
с пользователями (достаточно только с рекламодателем). Что требуется:

1) Миграция БД

2) Реализовать создание, редактирование и 
json-представление данных о пользователе (рекламодателе). 
С сохранением в базу и валидациями.
 
Вьюхи делать не нужно, достаточно рабочих роутов. 
Роуты должны быть доступны только для ajax-запросов. 

```
    POST users#create
    {
        kind,
        title,
        tel,
        email,
        props: {
          12: 'Менеджер',
          1: 'Microsoft'
        }
    }
    
    PATCH users#update:id
    {
        title,
        tel,
        email,
        props: {
          12: 'Менеджер',
          1: 'Microsoft'
        }
    }
    
    GET users#show:id
```


3) Бизнес логику и валидации реализовать не в моделях 
ActiveRecord. Модели использовать только для доступа 
к БД. Можно заменить ActiveRecord, например, на 
sequel, или вообще чистый SQL. Сущность - это не модель 
ActiveRecord, а свой класс.

4) В качестве БД использовать PostgreSQL.

5) Индивидуальные свойства пользователя 
сохранить в отдельную таблицу.

# Решение

## Prerequisites

```bash
$ ruby -v # ruby 2.3.3
$ rails -v # Rails 5.1.2
$ rails new users-api --api -T -d mysql
$ bundle install
$ rails g rspec:install
```

## API Endpoints

| Endpoint	                    | Functionality                |
| :-------------------------:   | :---------------------------:|
| `POST /users_ads`	            |  Create a new user           |
| `GET /users_ads/:id`	        |  Get a user                  |
| `PUT /users_ads/:id`	        |  Update a user               |
| `DELETE /users_ads/:id`	    |  Delete a user               |

# Процесс

Лабаем модели и контроллер, проверяем:

```bash
curl -X POST localhost:3000/user_ads -d 'title=test&email=email@mail.ru&phone=8123551515&org=microsoft&pos=manager' -H 'X-Requested-With:XMLHttpRequest'
#  SQL (0.4ms)  INSERT INTO `users` (`type`, `title`, `email`, `phone`, `created_at`, `updated_at`) VALUES ('UserAd', 'test', 'email@mail.ru', '8123551515', '2017-08-01 00:04:01', '2017-08-01 00:04:01')
#  SQL (0.4ms)  INSERT INTO `user_ad_companions` (`user_ad_id`, `pos`, `org`, `created_at`, `updated_at`) VALUES (2, 'manager', 'microsoft', '2017-08-01 00:04:01', '2017-08-01 00:04:01')

curl localhost:3000/user_ads/1 -H 'X-Requested-With:XMLHttpRequest'
# UserAd Load (0.7ms)  SELECT  `users`.* FROM `users` WHERE `users`.`type` IN ('UserAd') AND `users`.`id` = 1 LIMIT 1
# {"id":1,"title":"test","email":"email@mail.ma","phone":"+7(960)540-32-23","created_at":"2017-07-31T23:07:17.000Z","updated_at":"2017-07-31T23:07:17.000Z"}

curl -X PUT localhost:3000/user_ads/1 -d 'title=test2' -H 'X-Requested-With:XMLHttpRequest'
# SQL (1.1ms)  UPDATE `users` SET `title` = 'test2', `updated_at` = '2017-08-01 00:09:12' WHERE `users`.`id` = 1

curl -X DELETE localhost:3000/user_ads/1 -H 'X-Requested-With:XMLHttpRequest' 
#  SQL (41.1ms)  DELETE FROM `user_ad_companions` WHERE `user_ad_companions`.`id` = 1
#   SQL (0.5ms)  DELETE FROM `users` WHERE `users`.`type` IN ('UserAd') AND `users`.`id` = 1

```