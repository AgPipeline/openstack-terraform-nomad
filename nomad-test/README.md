# Nomad experiments

## Create a Vagrant virtual machine with Nomad installed

In root of project, on laptop:

```bash
vagrant up
```


## Start Nomad nodes

Now start Nomad server in Vagrant: 

```bash
vagrant ssh
cd nomad-test 
nomad agent -config server.hcl
```

Now in another terminal tab start first Nomad client in Vagrant: 

```bash
vagrant ssh
cd nomad-test 
sudo nomad agent -config client1.hcl
```

Now in another terminal tab start second Nomad client in Vagrant:

```bash
vagrant ssh
cd nomad-test 
sudo nomad agent -config client2.hcl
```

Check the browser UI for servers & clients: <http://localhost:4646/>


## Start an example job

```bash
vagrant ssh
cd nomad-test 
nomad job plan example.nomad
nomad job run -check-index 0 example.nomad
nomad job status example
```

Also check the browser UI: <http://localhost:4646/ui/jobs>

Should show three healthy "task groups" and allocation for Redis.


## Start PostgreSQL job

Based on [official Docker image](https://hub.docker.com/_/postgres).

```bash
vagrant ssh
cd nomad-test 
nomad job plan postgresql.nomad
nomad job run -check-index 0 postgresql.nomad
nomad job status postgresql
```

Also check the browser UI: <http://localhost:4646/ui/jobs>

Should show one healthy "task group" and allocation for PostgreSQL.


## Find the PostgreSQL host & port

Go to <http://localhost:4646/ui/jobs/postgresql/database> and click on the allocation 

Should see one task called `postgresql_container` and an address with label `db`.

Can also use `nomad alloc`:

```bash
nomad job status postgres | grep " database " | cut -d " " -f1 | xargs -L 1 nomad alloc status | grep "db: " 
```


## Find the PostgreSQL Docker container name

In Vagrant shell:

```bash
docker ps --filter "name=postgresql_container"
```

You should see something like:

```
CONTAINER ID        IMAGE                    COMMAND                  CREATED             STATUS              PORTS                                                  NAMES
c55702d19725        postgres:9.6.15-alpine   "docker-entrypoint.s…"   15 minutes ago      Up 15 minutes       10.0.2.15:27575->5432/tcp, 10.0.2.15:27575->5432/udp   postgresql_container-feec8637-b73b-269f-c117-5438b1f973f6
```


## Set an environment variable with the PostgreSQL container ID

In Vagrant shell:

```bash
DB_CONTAINER_ID=$(docker ps --filter "name=postgresql_container" --format "{{.ID}}")
echo $DB_CONTAINER_ID
```

This should be the same container ID as you saw in the previous step. 


## Test that PostgreSQL works

In Vagrant shell:

```bash
docker exec --interactive --tty --user postgres --workdir /var/lib/postgresql/data ${DB_CONTAINER_ID} bash
```

Should be in a Docker shell as the `postgres` user. Double-check:

```bash
whoami
pwd
```

Should see something like:

```
bash-5.0$ whoami
postgres
bash-5.0$ pwd
/var/lib/postgresql/data
```

List the databases:

```bash
psql -l
```

You should see something like:

```
bash-5.0$ psql -l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)
```


## Start Mongo job

Based on [Docker "official image"](https://hub.docker.com/_/mongo).

```bash
vagrant ssh
cd nomad-test 
nomad job plan mongo.nomad
nomad job run -check-index 0 mongo.nomad
nomad job status mongo
```

Also check the browser UI: <http://localhost:4646/ui/jobs>

Should show three healthy "task groups" and allocations for Mongo.


## Find the Mongo hosts & ports

Go to <http://localhost:4646/ui/jobs/postgresql/database> and click on one of the allocations. 

Should see a task called `mongo_container` and an address with label `db`.

Can also use `nomad alloc`:

```bash
nomad job status mongo | grep " database " | cut -d " " -f1 | xargs -L 1 nomad alloc status | grep "db: " 
```


## Test that Mongo works

In Vagrant shell:

```bash
# Set MONGO_ADDRESS to one of the host:port combinations from above: 
MONGO_ADDRESS=10.0.2.15:25695
curl ${MONGO_ADDRESS}
```

Should see something like:

```
curl ${MONGO_ADDRESS}
It looks like you are trying to access MongoDB over HTTP on the native driver port.
```


## Run a command in the environment of a Nomad allocation and task

```bash
vagrant ssh
nomad exec -i -t -job mongo ps aux
nomad exec -i -t -job postgresql ps aux
``` 