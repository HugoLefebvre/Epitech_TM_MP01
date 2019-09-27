# Epitech_TM_MP01
Epitech - Time Manager - Mini Project 01

# How to install
Run
```mix deps.get```

If you already have a database created, run 
```mix ecto.drop```

To create the database, run
```mix ecto.create```

To create the table in the database, run
```mix ecto.migrate```

To insert default data in the database, run 
```mix run priv/repo/seeds.exs```
Your can see the default value set in priv/repo/seeds.exs

# How to start API

Run
```mix phx.server```

# How to use the API with the CRUD ?

Run 
```mix phx.routes```
to know the differents existing routes. If it exist two routes identically, Phoenix or Elixir will use the first route on the list. So be careful.

To know the params of the differents routes, read the comments on the function. Be careful, some function didn't need some parameter like : something=????. It may be directly on the route like : api/users/1 where 1 is :userID.

Be careful, some function need bearer token ! You must sign in to have it