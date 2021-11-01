module "mysql-db-private-service-access" {
  source      = "./modules/private_service_access"
  project_id  = var.project
  vpc_network = var.networkname #module.network.network_name

  depends_on = [google_compute_address.address]
}

resource "random_password" "dbpassword" {
  length           = 16
  special          = true
  override_special = "!@#$?%&*()-[]"
}

module "mysql-db" {
  source               = "GoogleCloudPlatform/sql-db/google//modules/mysql"
  version              = "~> 7.0.0"
  name                 = var.dbname
  random_instance_name = true
  project_id           = var.project

  deletion_protection = false

  database_version = "MYSQL_5_7"
  region           = var.region
  zone             = var.zone
  tier             = var.dbmachine

  user_name     = var.dbusername
  user_password = random_password.dbpassword.result

  additional_users = [
    #  {
    #    name     = var.dbusername
    #    password = var.dbpassword
    #    host     = var.cidrip
    #  },
  ]

  ip_configuration = {
    ipv4_enabled    = true
    require_ssl     = false
    private_network = module.network.network_self_link
    #  private_network = null
    authorized_networks = [
      #  {
      #    name  = "${var.project}-cidr"
      #    value = "10.0.0.0/16"
      #  },
    ]
  }

  backup_configuration = {
    enabled                        = true
    binary_log_enabled             = true
    start_time                     = "20:55"
    location                       = null
    transaction_log_retention_days = 3
    retained_backups               = 5
    retention_unit                 = "COUNT"
  }

  depends_on = [module.mysql-db-private-service-access]

  #  assign_public_ip = "true"
  #  vpc_network      = var.networkname

  #  module_depends_on = [module.private-service-access.peering_completed]
}


resource "google_secret_manager_secret" "db-password" {
  secret_id = "db-password"
  replication {
    user_managed {
      replicas {
        location = "europe-north1"
      }
      #replicas {
      #  location = "europe-central2"
      #}
    }
  }
}

resource "google_secret_manager_secret_version" "db-password" {
  secret      = google_secret_manager_secret.db-password.id
  secret_data = random_password.dbpassword.result
}
