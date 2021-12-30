terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_kubernetes_cluster" "kubernetes_cluster" {
  name    = "terraform-do-cluster"
  region  = "ams3"
  version = "1.19.15-do.0"
  node_pool {
    name       = "default-pool"
    size       = "s-2vcpu-4gb" 
    auto_scale = false
    node_count = 3
    tags       = ["node-pool-tag"]
  }
}