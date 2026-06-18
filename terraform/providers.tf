terraform {
  required_providers {
    # Provider Proxmox pour créer les VM et Provider local pour générer l'inventaire Ansible.
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.66"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

provider "proxmox" {
  # Connexion à l'API Proxmox; l'accès SSH sert au provider pour préparer les opérations côté nœud.
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = true

  ssh {
    agent    = true
    username = "root"
    node {
      name    = var.proxmox_node
      address = "82.64.141.52"
      port    = 4007
    }
  }
}
