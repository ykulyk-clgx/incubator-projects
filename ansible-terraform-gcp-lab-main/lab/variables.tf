###########
# Default #
###########

variable "project" {
  default = "terraform-train-cl"
  type    = string
}

variable "region" {
  default = "europe-north1"
  type    = string
}

variable "zone" {
  default = "europe-north1-a"
  type    = string
}

variable "credkey" {
  default = "/home/markokulyk8/ansible-proj/serviceacc.json"
  type    = string
}

###########
# Network #
###########

variable "networkname" {
  default = "ansible-network"
  type    = string
}

variable "subnetname" {
  default = "ansible-subnet"
  type    = string
}

variable "cidrip" {
  default = "10.10.0.0/24"
  type    = string
}

variable "network_tier" {
  default = "PREMIUM"
  type    = string
}

variable "sshranges" {
  default = ["35.235.240.0/20", "34.118.71.0/24", "10.0.0.0/8"]
  type    = list(string)
}

#variable "cidrranges" {
#  default = ["10.10.0.0/16"]
#  type    = list(string)
#}

#######################
# Instance Linuxbased #
#######################

variable "name_instance" {
  default = "instance-debian-ansible"
  type    = string
}

variable "name_instance_proxy" {
  default = "instance-debian-proxy-ansible"
  type    = string
}

variable "type_instance" {
  default = "e2-small"
  type    = string
}

variable "image_project" {
  default = "debian-cloud"
  type    = string
}

variable "image_family_instance" {
  default = "debian-10"
  type    = string
}

variable "image_instance" {
  default = "debian-10-buster-v20210916"
  type    = string
}

variable "num_instances" {
  default = 2
  type    = number
}

variable "disk_size_instance" {
  default = 10
  type    = number
}

variable "disk_type_instance" {
  default = "pd-standart"
  type    = string
}

#know about startup_script=file(path_to_sh) feature, but like var more
variable "startup_script" {
  default = "sudo apt update\nsudo apt install python -y\nsudo adduser --shell /bin/bash --gecos \"\" ansible\necho \"ansible ALL=(ALL) NOPASSWD:ALL\" | sudo tee -a /etc/sudoers\nsudo mkdir /home/ansible/.ssh\nsudo chown -R ansible:ansible /home/ansible/.ssh\nsudo chmod 700 /home/ansible/.ssh\necho \"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0XNB4a1oQHFJ+CbADkhWZg7Niu9PjF1LLxtZdW87K8D2HGvvAvbkraSmLDXaKr/FYGMTlhzOHFTK6JuT35jyCa+SgW1jRrh82ldFh2qQQXjIB9n/loot4ISnsoOZIbUk1khYQEEXrmlseNx00agsis60KQmrEdcdn4j0jm+IBypYbt0yRpDL+S2h78UUvzQtmlEgxv+cR8mPb+0RtbjoarRyT3tD1sORLMm5nDppfo+kqQ09n/ogfQYAJPBHL0i08BVylQarFjE1k5Gofy/fxNIXALYGjflTtAkH1f5g/ixkQ+I2xnf4zxm7rcI9y/xkESmiy+dKVJOTwxV2sY5xf markokulyk8@for-terraform\" | sudo tee -a /home/ansible/.ssh/authorized_keys\nsudo usermod -L ansible"
  type    = string
}

#variable "service_account" {
#  default = {
#    "email" : "1041290623041-compute@developer.gserviceaccount.com",
#    "scopes" : [
#      "https://www.googleapis.com/auth/sqlservice.admin",
#      "https://www.googleapis.com/auth/servicecontrol",
#      "https://www.googleapis.com/auth/service.management.readonly",
#      "https://www.googleapis.com/auth/logging.write",
#      "https://www.googleapis.com/auth/monitoring.write",
#      "https://www.googleapis.com/auth/trace.append",
#      "https://www.googleapis.com/auth/devstorage.read_only"
#    ]
#  }
#  type = object({
#    email  = string,
#    scopes = set(string)
#  })
#  description = "Service account to attach to the instance"
#}

##########################
# Instance WindowsServer #
##########################

variable "name_instance_windows" {
  default = "instance-windows-ansible"
  type    = string
}

variable "type_instance_windows" {
  default = "e2-medium"
  type    = string
}

variable "image_project_windows" {
  default = "windows-cloud"
  type    = string
}

variable "image_family_instance_windows" {
  default = "windows-2019-core"
  type    = string
}

variable "image_instance_windows" {
  default = "windows-server-2019-dc-core-v20210914"
  type    = string
}

variable "num_instances_windows" {
  default = 1
  type    = number
}

variable "disk_size_instance_windows" {
  default = 32
  type    = number
}

variable "disk_type_instance_windows" {
  default = "pd-standart"
  type    = string
}

#know about startup_script=file(path) feature, but like var more
variable "metadata_windows" {
  default = ({
    windows-startup-script-ps1 = "(new-object net.webclient).DownloadFile('https://raw.githubusercontent.com/GuardNexusGN/Ansible-on-Windows-OpenSHH/main/ssh_ansible.ps1','ssh_ansible.ps1'); ./ssh_ansible.ps1; echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0XNB4a1oQHFJ+CbADkhWZg7Niu9PjF1LLxtZdW87K8D2HGvvAvbkraSmLDXaKr/FYGMTlhzOHFTK6JuT35jyCa+SgW1jRrh82ldFh2qQQXjIB9n/loot4ISnsoOZIbUk1khYQEEXrmlseNx00agsis60KQmrEdcdn4j0jm+IBypYbt0yRpDL+S2h78UUvzQtmlEgxv+cR8mPb+0RtbjoarRyT3tD1sORLMm5nDppfo+kqQ09n/ogfQYAJPBHL0i08BVylQarFjE1k5Gofy/fxNIXALYGjflTtAkH1f5g/ixkQ+I2xnf4zxm7rcI9y/xkESmiy+dKVJOTwxV2sY5xf markokulyk8@for-terraform' > C:/Users/ansible/.ssh/authorized_keys"
  })
}
