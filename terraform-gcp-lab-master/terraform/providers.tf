terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.82.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    #  null = {
    #    source  = "hashicorp/null"
    #    version = "~> 3.1.0"
    #  }
  }
}

provider "google" {
  #  credentials = file(var.credkey)
  project     = var.project
  region      = var.region
  zone        = var.zone
  #  request_timeout = "15m"
}

provider "random" {

}

#provider "null" {
#
#}
