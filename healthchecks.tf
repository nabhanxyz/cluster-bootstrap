resource "kubernetes_namespace" "healthchecks" {
  metadata {
    name        = "healthchecks"
    annotations = {}
    labels      = {}
  }
}

resource "helm_release" "healthchecks" {
  name       = "healthchecks"
  namespace = kubernetes_namespace.healthchecks.metadata[0].name
  repository = "https://k8s-at-home.com/charts/"
  chart      = "healthchecks"


  set {
    name  = "persistence.config.enabled"
    value = "true"
  }

  set {
    name  = "persistence.config.mountpath"
    value = "/config"
  }

  set {
    name  = "ingress.main.enabled"
    value = "true"
  }

  set {
    name  = "ingress.main.hosts[0].host"
    value = "healthchecks.${var.domain_name}"
  }
  
  set {
    name  = "ingress.main.hosts[0].paths[0].path"
    value = "/"
  }

  set {
    name  = "ingress.main.hosts[0].paths[0].pathType"
    value = "Prefix"
  }

  set {
    name  = "ingress.main.ingressClassName"
    value = "nginx"
  }

  set {
    name  = "ingress.main.tls[0].secretName"
    value = "healthchecks-tls-secret"
  }
  set {
    name  = "ingress.main.tls[0].hosts[0]"
    value = "healthchecks.${var.domain_name}"
  }

  set {
    name  = "ingress.main.annotations.cert-manager\\.io/cluster-issuer"
    value = "letsencrypt-prod"
  }

  set {
    name  = "ingress.main.annotations.external-dns\\.alpha\\.kubernetes\\.io/target"
    value = "tunnel-origin.${tostring(var.domain_name)}"
  }

#   set {
#     name  = "ingress.main.annotations.nginx\\.ingress\\.kubernetes\\.io/force-ssl-redirect"
#     value = tostring("true")
#   }

#   set {
#     name  = "ingress.main.annotations.nginx\\.ingress\\.kubernetes\\.io/backend-protocol"
#     value = "HTTPS"
#   }

  set {
    name  = "env.TZ"
    value = "US/Mountain"
  }
  set {
    name  = "env.REGENERATE_SETTINGS"
    value = "False"
  }
  set {
    name  = "env.SITE_ROOT"
    value = "https://healthchecks.${var.domain_name}"
  }
  set {
    name  = "env.SITE_NAME"
    value = "Healthchecks"
  }
  set {
    name  = "env.SUPERUSER_EMAIL"
    value = "${var.contact_email}"
  }
  set {
    name  = "env.SUPERUSER_PASSWORD"
    value = "${var.bootstrap_password}"
  }

  set {
    name  = "env.SECRET_KEY"
    value = random_string.secret_key.result
  }


}

resource "random_string" "secret_key" {
  length           = 24
  special          = false
}

# resource "cloudflare_record" "healthchecks" {
#   zone_id = var.personal_zone_id
#   name    = "${var.service.name}"
#   value   = "192.168.0.30"
#   type    = "A"
#   ttl     = 60
#   proxied = false
# }