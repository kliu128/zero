# Client label

`postgresql-postgresql-client=true`

# Making new database

- Get secret from config yaml file

postgres=# create database mydb;
postgres=# create user myuser with encrypted password 'mypass';
postgres=# grant all privileges on database mydb to myuser;