NOTES:

Please be patient while the chart is being deployed

Tip:

  Watch the deployment status using the command: kubectl get pods -w --namespace default -l release=mariadb

Services:

  echo Master: mariadb.default.svc.cluster.local:3306

Administrator credentials:

  Username: root
  Password : $(kubectl get secret --namespace default mariadb -o jsonpath="{.data.mariadb-root-password}" | base64 --decode)

To connect to your database:

  1. Run a pod that you can use as a client:

      kubectl run mariadb-client --rm --tty -i --restart='Never' --image  docker.io/bitnami/mariadb:10.3.16-debian-9-r29 --namespace default --command -- bash

  2. To connect to master service (read/write):

      mysql -h mariadb.default.svc.cluster.local -uroot -p my_database

To upgrade this helm chart:

  1. Obtain the password as described on the 'Administrator credentials' section and set the 'rootUser.password' parameter as shown below:

      ROOT_PASSWORD=$(kubectl get secret --namespace default mariadb -o jsonpath="{.data.mariadb-root-password}" | base64 --decode)
      helm upgrade mariadb stable/mariadb --set rootUser.password=$ROOT_PASSWORD

## Creating a new database

```
CREATE DATABASE `mydb`;
CREATE USER 'myuser' IDENTIFIED BY 'mypassword';
GRANT ALL privileges ON `mydb`.* TO 'myuser'@'%';
FLUSH PRIVILEGES;