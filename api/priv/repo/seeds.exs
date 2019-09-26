# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Api.Repo.insert!(%Api.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Api.Auth

roles = [
  %{
    name: "admin"
  },
  %{
    name: "manager"
  },
  %{
    name: "employee"
  }
]

user = [
  %{
    username: "admin",
    email: "admin@admin.fr",
    password: "admin",
    role_id: "1"
  },
  %{
    username: "manager",
    email: "manager@manager.fr",
    password: "manager",
    role_id: "2"
  },
  %{
    username: "employee",
    email: "employee@employee.fr",
    password: "employee",
    role_id: "3"
  }
]

# For each role in roles array, create a role
Enum.each(roles, fn(data) -> 
  Auth.create_role(data)
end)

# For each user in user array, create a user
Enum.each(user, fn(data) -> 
  Auth.create_user(data)
end)