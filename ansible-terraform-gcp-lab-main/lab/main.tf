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

module "network_peering" {
  source        = "terraform-google-modules/network/google//modules/network-peering"
  version       = "3.4.0"
  prefix        = "network-peering"
  local_network = "https://www.googleapis.com/compute/v1/projects/terraform-train-cl/global/networks/default"
  peer_network  = module.network.network_self_link
}

module "network_fabric-net-firewall" {
  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  version                 = "3.4.0"
  project_id              = var.project
  network                 = module.network.network_name
  internal_ranges_enabled = true
  internal_ranges         = [var.cidrip]
}

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
  }]
}

resource "google_compute_address" "address" {
  name         = "nat-manual-ip-xamp"
  region       = var.region
  address_type = "EXTERNAL"
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

  depends_on = [module.network_routes]
}

data "google_compute_default_service_account" "service_account" {

}

module "instance_template_linux" {
  source               = "terraform-google-modules/vm/google//modules/instance_template"
  version              = "7.1.0"
  region               = var.region
  project_id           = var.project
  machine_type         = var.type_instance
  startup_script       = var.startup_script
  source_image_project = var.image_project
  source_image_family  = var.image_family_instance
  source_image         = var.image_instance
  tags                 = ["vm", "debian", "egress-inet", "http-server"]
  disk_size_gb         = var.disk_size_instance
  subnetwork           = var.subnetname
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
  #access_config  = [{
  #  nat_ip       = google_compute_address.address.address
  #  network_tier = var.network_tier
  #}]
  depends_on = [module.cloud_nat]
}

module "instance_template_windows" {
  source               = "terraform-google-modules/vm/google//modules/instance_template"
  version              = "7.1.0"
  region               = var.region
  project_id           = var.project
  machine_type         = var.type_instance_windows
  metadata             = var.metadata_windows
  source_image_project = var.image_project_windows
  source_image_family  = var.image_family_instance_windows
  source_image         = var.image_instance_windows
  tags                 = ["vm", "windows", "egress-inet", "http-server"]
  disk_size_gb         = var.disk_size_instance_windows
  subnetwork           = var.subnetname
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
  #access_config  = [{
  #  nat_ip       = google_compute_address.address.address
  #  network_tier = var.network_tier
  #}]
  depends_on = [module.cloud_nat]
}

module "google_address_reserver" {
  source     = "terraform-google-modules/address/google//examples/ip_address_only"
  version    = "3.0.0"
  project_id = var.project
  region     = var.region
  subnetwork = module.network.subnets_self_links[0]
  names      = ["linux-proxy-ansible-addr", "linux-ansible-one-addr", "linux-ansible-two-addr", "windows-ansible-addr"]
}

module "compute_instance_linux_proxy" {
  source            = "terraform-google-modules/vm/google//modules/compute_instance"
  version           = "7.1.0"
  region            = var.region
  zone              = var.zone
  subnetwork        = var.subnetname
  num_instances     = var.num_instances
  hostname          = var.name_instance_proxy
  instance_template = module.instance_template_linux.self_link
  static_ips        = [module.google_address_reserver.addresses[0]]
  access_config = [{
    nat_ip       = null
    network_tier = "PREMIUM"
  }, ]
}

module "compute_instance_linux" {
  source            = "terraform-google-modules/vm/google//modules/compute_instance"
  version           = "7.1.0"
  region            = var.region
  zone              = var.zone
  subnetwork        = var.subnetname
  static_ips        = [module.google_address_reserver.addresses[1], module.google_address_reserver.addresses[2]]
  num_instances     = var.num_instances
  hostname          = var.name_instance
  instance_template = module.instance_template_linux.self_link
}

module "compute_instance_windows" {
  source            = "terraform-google-modules/vm/google//modules/compute_instance"
  version           = "7.1.0"
  region            = var.region
  zone              = var.zone
  static_ips        = [module.google_address_reserver.addresses[3]]
  subnetwork        = var.subnetname
  num_instances     = var.num_instances_windows
  hostname          = var.name_instance_windows
  instance_template = module.instance_template_windows.self_link
}

#resource "time_sleep" "wait_for_start" {
#  depends_on = [module.compute_instance_linux_proxy, module.compute_instance_linux, module.compute_instance_windows]
#
#  create_duration = "90s"
#}

resource "null_resource" "trigger_ansible" {
  depends_on = [module.compute_instance_linux_proxy, module.compute_instance_linux, module.compute_instance_windows] 
  #depends_on = [time_sleep.wait_for_start]

  provisioner "local-exec" {
    command = "ansible-playbook --extra-vars 'proxy_ip_addr=${module.google_address_reserver.addresses[0]} linux_ip_addr=${module.google_address_reserver.addresses[1]} linux_two_ip_addr=${module.google_address_reserver.addresses[2]} windows_ip_addr=${module.google_address_reserver.addresses[3]}' create_inventory.yml"
  }
  
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts provision.yml"
  }

  provisioner "local-exec" {
    command = "rm hosts"
  }
}
