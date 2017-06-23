# Terraform for Mattermost on Digital Ocean

Terraform code to spin the Mattermost server on Digital Ocean

RUN
====

Before run change the following parameters:

- `variables.tf`:

- `scritps/install-mattermost.sh`:
In the section for wget you can change the version of mattermost to deploy. Currently we are using version 3.10

- `scritps/install-mattermostdb.sh`:
You can change the username, database name and the password

- `scripts/create-mattermost-user-team.sh`:
Change the initial username, password and email
Change the initial team name


```bash
set the enviroment variables:
export TF_VAR_digitalocean_ssh_keys=<DO Token>
expott TF_VAR_token='<ssh key>'

After that check the terraform with plan
$ terraform plan

To deploy run:
$ terraform apply
```

If everything went well you can see the ips for the brand new servers.

Then grab the ip and access in the browser your new Mattermost server.


TODO:
-----

 - DNS name
 - HTTPS
 - Firewall in the db
 - Create modules for each part - server and db.