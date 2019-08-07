# TERRA-REF Pipeline Bootstrapper with Terraform for OpenStack

This is based on the National Data Service's 
[Kubeadm Bootstrapper with Terraform for OpenStack](https://github.com/nds-org/kubeadm-terraform), 
which in turn is mostly based on the article by Andrea Zonca of San Diego Supercomputer Center: 
[Deploy scalable Jupyterhub with Kubernetes on Jetstream](https://zonca.github.io/2017/12/scalable-jupyterhub-kubernetes-jetstream.html)


## How to build a pipeline

Check out a copy of this repo and cd into the top directory.


### Configure variables

You will need to set some of the variables found in `variables.tf`. The best
way to do this is to create a `.tfvars` file in the `configs` directory. This
directory is in `.gitignore` to make this easy. Entries in `.tfvars` files
are just _name_ = "_value_"

Most of the variables should be obvious, but here is a summary with some detail
on the more specific value domains.

| Variable                 | Description                                                           |
| ------------------------ | -----------                                                           |
| env_name                 | Root name for this pipeline. Will be used to name nodes and networks |
| openstack_cloud          | Name of the OpenStack cloud to use - the credentials should be in your `clouds.yaml` file. See below. |
| pubkey                   | Path to a public key file which will be used to generate the OpenStack key pair |
| privkey                  | Path to the corresponding private key file which will be used to access the hosts |
| postgresql_flavor        | Name of the OpenStack instance flavor to use for the PostgreSQL node |
| postgresql_image         | Name of the OS image to be used to initialize PostgreSQL node. |
| postgresql_volume_size   | Specify the size of the storage attached to the PostgreSQL node. Expressed in GBytes |
| external_network_name    | Name of the network that has the gateway to the internet (e.g. `ext-net`, `public`) |
| pool_name                | The name of the pool from which the floating IP belongs to (usually the external network's name) |
| availability_zone        | Name of the OpenStack availability zone where the hosts should be provisioned |
| dns_nameservers          | A list of IP addresses of DNS name servers available to the new subnet |


### Initialize Terraform

This recipe uses Terraform to provision the network, host, and execute the
steps to set up your pipeline. You will need to 
[install terraform](https://www.terraform.io/intro/getting-started/install.html) 
on your local machine.

Terraform uses a plug-in architecture. You will need to instruct it to download
and install the plugins used in this setup.

In the root directory of this repo execute the following command:
```bash
% terraform init
```

### Set your OpenStack credentials
 
Create a file called `clouds.yaml` in `~/.config/openstack` directory. Example:

```yaml
clouds:
  tombstone-terraref:
    identity_api_version: 3
    auth:
      username: johndoe
      password: your-openstack-password
      project_name: terraref
      domain_name: cso
      auth_url: "https://tombstone-cloud.cyverse.org:5000/v3"
```

 
### Build the pipeline

To build your servers issue this command in the root folder of this repo:

```bash
% terraform apply -var-file="configs/<<your .tfvars file>>"
```


## Using the pipeline

TODO


## Destroying the pipeline

If you want to release the resources allocated to your pipeline you can destroy
it with the terraform command:

```bash
% terraform destroy
```
