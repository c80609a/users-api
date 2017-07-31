## Prerequisites

```bash
$ ruby -v # ruby 2.3.3
$ rails -v # Rails 5.1.2
$ rails new users-api --api -T -d mysql
$ bundle install
$ rails g rspec:install
```

## API Endpoints

| Endpoint	                | Functionality                |
| :---------------------:   | :---------------------------:|
| `GET /users`	            |  List all users              |
| `POST /users`	            |  Create a new user           |
| `GET /users/:id`	        |  Get a user                  |
| `PUT /users/:id`	        |  Update a user               |
| `DELETE /users/:id`	    |  Delete a user               |
