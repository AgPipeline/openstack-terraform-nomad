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

## 