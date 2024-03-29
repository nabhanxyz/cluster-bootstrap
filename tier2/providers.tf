provider "cloudflare" {
  api_token = var.cloudflare_token
}

provider "kubernetes" {
  config_path = "../bootstrap.kubeconfig"
  # config_context = "main-context"
}

provider "helm" {
  kubernetes {
    config_path = "../bootstrap.kubeconfig"
  }
}

provider "random" {
}
provider "kubectl" {
  config_path = "../bootstrap.kubeconfig"
}

provider "http" {
}

provider "authentik" {
  url   = "https://auth.${var.domain_name}"
  token = data.kubernetes_secret.authentik-bootstrap.data["authentik_bootstrap_token"]
}