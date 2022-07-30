terraform {
  required_version = ">= 1.1.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 3.18.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.12.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.3.2"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "2.2.0"
    }

    authentik = {
      source  = "goauthentik/authentik"
      version = "2022.7.1"
    }
  }
}