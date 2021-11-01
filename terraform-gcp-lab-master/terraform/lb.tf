module "http_lb" {
  source      = "GoogleCloudPlatform/lb-http/google"
  version     = "~> 5.1"
  name        = "http-lb-xamp"
  project     = var.project
  target_tags = ["xamp"]

  backends = {
    default = {

      description                     = "Backend http lb"
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 10
      connection_draining_timeout_sec = null
      enable_cdn                      = false

      custom_request_headers  = null
      custom_response_headers = null
      security_policy         = google_compute_security_policy.xamp-lb-policy.name

      connection_draining_timeout_sec = 10
      session_affinity                = null
      affinity_cookie_ttl_sec         = null

      health_check = {
        check_interval_sec  = 60
        timeout_sec         = 5
        healthy_threshold   = 1
        unhealthy_threshold = 3
        request_path        = "/"
        port                = 80
        host                = ""
        logging             = true
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group                        = module.managed_instance_group.instance_group
          balancing_mode               = "UTILIZATION"
          capacity_scaler              = 1
          description                  = "HTTP LB for lamp"
          max_connections              = 0
          max_connections_per_instance = 0
          max_connections_per_endpoint = 0
          max_rate                     = 0
          max_rate_per_instance        = 0
          max_rate_per_endpoint        = 0
          max_utilization              = 1
        },
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
    }
  }

  depends_on = [module.managed_instance_group]
}
