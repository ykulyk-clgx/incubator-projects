###########
# Default #
###########

variable "project" {
  default = "terraform-train-cl"
  type    = string
}

variable "region" {
  #default = "europe-north1"
  default = "europe-west4"
  type    = string
}

variable "zone" {
  #default = "europe-north1-a"
  default = "europe-west4-a"
  type    = string
}

variable "credkey" {
  default = "/home/markokulyk8/terraform-proj/serviceacc.json"
  type    = string
}

###########
# Network #
###########

variable "networkname" {
  default = "terraform-network"
  type    = string
}

variable "subnetname" {
  default = "subnet-lamp"
  type    = string
}

variable "cidrip" {
  default = "10.0.0.0/24"
  type    = string
}

variable "sshranges" {
  default = ["35.235.240.0/20", "185.46.221.38/32"]
  type    = list(string)
}

#############
# Instances #
#############

variable "type_instance" {
  default = "e2-small"
  #default = "e2-highcpu-2"
  type = string
}

variable "source_image_instance" {
  default = "centos-7-v20201112"
  type    = string
}

variable "source_image_family_instance" {
  default = "centos-7"
  type    = string
}

variable "source_image_project_instance" {
  default = "centos-cloud"
  type    = string
}

variable "num_instances" {
  default = 2
  type    = number
}

variable "disk_type_instance" {
  default = "pd-balanced"
  type    = string
}

variable "disk_size_instance" {
  default = 20
  type    = number
}

variable "network_tier" {
  default = "STANDARD"
  #default = "PREMIUM"
  type = string
}

variable "path_linux_startup" {
  default = "./neededfiles/linux_startup.sh"
  type    = string
}

#variable "startup_script" {
#  default = "sudo yum update -y\nsudo yum install httpd -y\nsudo systemctl start httpd.service\nsudo systemctl enable httpd.service\nsudo gsutil cp gs://xamp-site-bucket-xmpl/index.html /var/www/html/index.html\nsudo yum install mariadb-server mariadb  -y\nsudo systemctl start mariadb\nsudo systemctl enable mariadb.service\nsudo mysql -e \"UPDATE mysql.user SET Password = PASSWORD('123321') WHERE User = 'root'\"\nsudo mysql -e \"DROP USER ''@'localhost'\"\nsudo mysql -e \"DROP USER ''@'$(hostname)'\"\nsudo mysql -e \"DROP DATABASE test\"\nsudo mysql -e \"FLUSH PRIVILEGES\"\nsudo yum install php php-mysql  -y\nsudo systemctl restart httpd.service"
#  type    = string
#}

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

############
# Database #
############

variable "dbname" {
  default = "xamp-db"
  type    = string
}

variable "dbmachine" {
  default = "db-g1-small"
  type    = string
}

variable "dbusername" {
  default = "marko"
  type    = string
}

##########
# Bucket #
##########

variable "bucketname" {
  default = "xamp-site-bucket-xmpl"
  type    = string
}

variable "indexname" {
  default = "index.html"
  type    = string
}

variable "sitepath" {
  default = "./neededfiles/index.html"
  type    = string
}


