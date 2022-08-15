resource "kubernetes_namespace" "external_dns" {
  metadata {
    name        = "external-dns"
    annotations = {}
    labels      = {}
  }
}

resource "helm_release" "external_dns" {
  name = "external-dns"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"

  namespace = kubernetes_namespace.external_dns.metadata[0].name

  set {
    name  = "provider"
    value = "cloudflare"
  }

  set {
    name  = "cloudflare.secretName"
    value = kubernetes_secret.external_dns.metadata[0].name
  }

  set {
    name  = "zoneIdFilters.${data.cloudflare_zone.zone_id.id}"
    value = data.cloudflare_zone.zone_id.id
  }

  set {
    name  = "policy"
    value = "sync"
  }
}

resource "kubernetes_secret" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = kubernetes_namespace.external_dns.metadata[0].name
  }

  data = {
    "cloudflare_api_token" = var.cloudflare_token
  }

  type = "kubernetes.io/secret"
}