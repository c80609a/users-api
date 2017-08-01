# Задача

Есть сущность пользователь (User). Он может быть трех типов:

- Администратор
- Модератор
- Исполнитель
- Рекламодатель

Каждый тип юзера, характеризуется опеределенным набором 
свойств, какие-то свойства общие для всех типов 
пользователей, какие-то характеризуют конкретного. 

Обязательные общие свойства:
- почта;
- имя;
- телефон.

Свойства рекламодателя:
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

Создаются 3 модели и 2 таблицы.

### Миграции:

```ruby
class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :type, null: false
      t.string :title, null: false
      t.string :email, null: false
      t.string :phone, null: false

      t.timestamps
    end
  end
end
```

```ruby
class CreateUserAdCompanions < ActiveRecord::Migration[5.1]
  def change
    create_table :user_ad_companions do |t|
      t.references :user_ad
      t.string :pos
      t.string :org

      t.timestamps
    end
  end
end
```

### Модели

```ruby
class User < ActiveRecord::Base
  validates :title, presence: true
  validates :email,
            presence: true,
            format: { with: /\A([a-z0-9_.-]+)@([a-z0-9-]+)\.[a-z.]+\z/}
  validates :phone,
            presence: true,
            format: { with: /\A((8|\+7)?[\- ]?)?(\(?\d{3}\)?[\- ]?)?[\d\- ]{7,10}\z/ }
end
```

```ruby
class UserAd < User

  has_one :companion,
          class_name: 'UserAdCompanion',
          inverse_of: :user_ad,
          dependent: :destroy,
          autosave: true

  delegate :pos,
           :org,
           :pos=,
           :org=,
           to: :lazily_companion

  private

  def lazily_companion
    companion || build_companion
  end

end
```

```ruby
class UserAdCompanion < ActiveRecord::Base
  # Attributes: pos, org
  belongs_to :user_ad, inverse_of: :companion
  validates :user_ad, presence: true
end
```

### Контроллер

Контроллер обслуживает маршруты из `routes.rb` и использует `concern` 
который уменьшает количество boilerplate кода в коде контроллера:

```ruby
module ExceptionHandler
  extend ActiveSupport::Concern

  included do

    # define custom handlers
    rescue_from ActiveRecord::RecordInvalid, with: :four_twenty_two
    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({message: e.message}, :not_found)
    end

  end

  private

  # JSON ответ со статус-кодом 422 - unprocessable_entity
  def four_twenty_two(e)
    json_response({message: e.message}, :unprocessable_entity)
  end

end
```

Контроллер обслуживает маршруты из `routes.rb` и использует `concern` помогаеющий
с `json`-ответами:

```ruby
module Response
  def json_response(object, status = :ok)
    render json: object, status: status
  end
end
```

## Проверяем

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