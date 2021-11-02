# Ansible Terraform GCP lab

<h1>Little terraform-ansible documentaion</h1>

<h3>What is it</h3>

A small ansible & terraform project. Creates 3+ VMS: 1st one is a reverse proxy machine with external connection access, the other are internal web servers. 

Nginx server checks and redirects traffic (as lb) to 2 internal Linux VMS, where a simple HTTP template and fortune script are located.

Generaly, we should have a web page that shows VM name, OS name, internal IP address, and randomly chosen fortune on every new connection.

<h3>How it works:</h3>

  * Terraform connects, checks, and plans all resources in GCP
  * Terraform applies all resources
  * When resources and VMS are online - terraform run provisioners to trigger Ansible playbooks
  * First ansible-playbook takes all vars and generates inventory file with all args
  * Second ansible-playbook takes all vars and params from invetory file, apply needed modules and actions on different hosts

<h3>How to run:</h3>

  1) Use gcloud auth to give access for terraform to gcp
  2) Open variables.tf - change project, region, etc
  3) Open backend.tf - add own backend bucket
  4) Run `terraform init` to init terraform and download providers, official hashicorp and google modules
  5) Check and plan resources with `terraform plan`
  6) Run with `terraform apply`

<h3>Structure:</h3>

  <h4>Files and folders:</h4>
  
  * modules - [folder] [not essential] modules folder, used for tests, consists of private service access and template modules, currently not used
  * templates - [folder] jinja and python templates
  * backend.tf - [file] terraform backend
  * main.tf - [file] network, templates and instances
  * outputs.tf - [file] [not essential], used for tests, outputs values after execution
  * providers.tf - [file] list of prividers
  * variables.tf - [file] list of all variables
  * versions.tf - [file] list of minimum requirements
  * create_inventory.yml - [file] ansible template for inventory genration
  * provision.yml - [file] ansible template for provisioning on needed VMS, takes all params and vars form inventory

  <h4>GCP inf:</h4>
  
  * Own network and subnetwork
  * Firewall rules
  * Cloud Nat and Router + external IP
  * Network peering, between current (default) and created network
  * Linux (Debian 10) template for reverse proxy, Linux template for web application + 1 test Windows Server Core
  * Linux machine proxy, 2 Linux machines for web + 1 Windows with OpenSSH
