# Nomad Bootstrapper with Terraform for OpenStack

This is based on the National Data Service's 
[Kubeadm Bootstrapper with Terraform for OpenStack](https://github.com/nds-org/kubeadm-terraform), 
which in turn is mostly based on the article by Andrea Zonca of San Diego Supercomputer Center: 
[Deploy scalable Jupyterhub with Kubernetes on Jetstream](https://zonca.github.io/2017/12/scalable-jupyterhub-kubernetes-jetstream.html)

## How to build a Nomad cluster

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


## Clone this repository

Check out a copy of this repo and cd into the top directory.

Do the steps below for each of the following directories:

- 01_os_network
- 02_os_bastion
- 03_os_nomad_server
- 04_os_nomad_client


### Configure variables

You will need to set some of the variables found in `variables.tf`. The best
way to do this is to create a `.tfvars` file in the current directory. This
file is in `.gitignore` to make this easy. Entries in `.tfvars` files
are just _name_ = "_value_"


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


### Build the component

To build your Terraform resource issue this command:

```bash
% terraform apply -var-file="<<your .tfvars file>>"
```


## Destroying the cluster

If you want to release the resources allocated to your cluster you can destroy
it by running the `terraform destroy` command in each sub-directory, starting 
with `04_os_nomad_client` and working backwards:

```bash
% terraform destroy
```
