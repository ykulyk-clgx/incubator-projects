module "network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 3.4.0"
  network_name = var.networkname
  project_id   = var.project

  subnets = [
    {
      subnet_name           = var.subnetname
      subnet_ip             = var.cidrip
      subnet_region         = var.region
      subnet_private_access = "true"
    }
  ]

  secondary_ranges = {
  }
}

module "network_routes" {
  source       = "terraform-google-modules/network/google//modules/routes"
  version      = "~> 3.4.0"
  network_name = module.network.network_name
  project_id   = var.project

  routes = [
    {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    },
  ]

  depends_on = [module.network]
}

#module "network_fabric-net-firewall" {
#  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
#  version                 = "3.4.0"
#  project_id              = var.project
#  network                 = module.network.network_name
#  internal_ranges_enabled = true
#  internal_ranges         = [var.cidrip]
#}

module "network_firewall_rules" {
  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = var.project
  network_name = module.network.network_name

  rules = [{
    name                    = "allow-ssh-ingress"
    description             = "Allows SSH to all instances"
    direction               = "INGRESS"
    priority                = 100
    ranges                  = var.sshranges
    source_tags             = null
    source_service_accounts = null
    target_tags             = ["vm"]
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = ["22"]
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
    },
    {
      name                    = "allow-http-ingress"
      description             = "Allows SSH to all instances"
      direction               = "INGRESS"
      priority                = 100
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = ["http-server"]
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = ["80"]
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    }
  ]
}

#module "instance_service_account" {
#  source     = "terraform-google-modules/service-accounts/google"
#  version    = "~> 4.0.2"
#  project_id = var.project
#  prefix     = "lamp-xamp"
#  names      = ["instance-acc"]
#  project_roles = [
#    "${var.project}=>roles/viewer",
#    #"${var.project}=>roles/storage.objectViewer"
#  ]
#}

resource "google_compute_address" "address" {
  name         = "nat-manual-ip-xamp"
  region       = var.region
  address_type = "EXTERNAL"

  depends_on = [module.network_firewall_rules]
}

module "cloud_nat" {
  source        = "terraform-google-modules/cloud-nat/google"
  version       = "2.0.0"
  router        = "xamp-router"
  create_router = true
  project_id    = var.project
  network       = var.networkname
  region        = var.region
  name          = "cloud-nat-lb-xamp-nat"
  #  nat_ips       = [google_compute_address.address.address]
  #  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips = google_compute_address.address.*.self_link

  #  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  #  subnetworks = [{
  #    name                    = var.cidrip #module.network.subnets[0].name
  #    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  #    secondary_ip_range_names = null
  #  }]

  depends_on = [resource.google_compute_address.address]
}

data "google_compute_default_service_account" "service_account" {

}

module "instance_template" {
  source     = "./modules/instance_template"
  region     = var.region
  project_id = var.project

  machine_type         = var.type_instance
  source_image         = var.source_image_instance
  source_image_family  = var.source_image_family_instance
  source_image_project = var.source_image_project_instance

  startup_script = file(var.path_linux_startup) #var.startup_script
  tags           = ["vm", "centos", "xamp", "egress-inet", "http-server"]

  disk_type    = var.disk_type_instance
  disk_size_gb = var.disk_size_instance

  subnetwork = var.subnetname
  service_account = ({
    email = data.google_compute_default_service_account.service_account.email
    scopes = [
      "https://www.googleapis.com/auth/sqlservice.admin",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]
  })
  #access_config = [{
  #  nat_ip       = google_compute_address.address.address
  #  network_tier = var.network_tier
  #}]

  depends_on = [module.cloud_nat]
}

module "managed_instance_group" {
  source            = "terraform-google-modules/vm/google//modules/mig"
  project_id        = var.project
  version           = "~> 7.1.0"
  region            = var.region
  network           = module.network.network_name
  subnetwork        = var.subnetname
  target_size       = var.num_instances
  hostname          = "instance-xamp"
  instance_template = module.instance_template.self_link
  named_ports = [{
    name = "http"
    port = 80
  }]

  autoscaling_enabled = false
  #min_replicas = var.num_instances
  #max_replicas = var.num_instances * 2
  #cooldown_period = 60
  #autoscaling_cpu = [{
  #  cpu_utilization = 0.7
  #}]

  #health_check = {
  #  type                = "http"
  #  initial_delay_sec   = 800
  #  check_interval_sec  = 60
  #  healthy_threshold   = 1
  #  timeout_sec         = 10
  #  unhealthy_threshold = 2
  #  response            = ""
  #  proxy_header        = "NONE"
  #  port                = 80
  #  request             = ""
  #  request_path        = "/"
  #  host                = ""
  #}

  # depends_on = [module.cloud_nat]
}
