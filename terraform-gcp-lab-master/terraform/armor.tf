resource "google_compute_security_policy" "xamp-lb-policy" {
  name = "xamp-lb-policy"

  #Here can be defined any allow or deny rule

  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }
}
