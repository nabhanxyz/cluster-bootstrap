resource "kubernetes_namespace" "authentik" {
  metadata {
    name        = "authentik"
    annotations = {}
    labels      = {}
  }
}

resource "helm_release" "authentik" {
  depends_on = [
    helm_release.cert_manager,
    helm_release.ingress_nginx
  ]
  name = "authentik"

  repository = "https://charts.goauthentik.io"
  chart      = "authentik"

  namespace = kubernetes_namespace.authentik.metadata[0].name

  set {
    name  = "postgresql.postgresqlPassword"
    value = random_password.authentik_pg_password.result
  }

  set {
    name  = "authentik.postgresql.password"
    value = random_password.authentik_pg_password.result
  }

  set {
    name  = "authentik.secret_key"
    value = random_password.authentik_secret_key.result
  }

  values = [<<EOF
authentik:
  error_reporting:
    enabled: true
redis:
  enabled: true
postgresql:
  enabled: true
ingress:
  enabled: true
  annotations:
    external-dns.alpha.kubernetes.io/target: tunnel-origin.${var.domain_name}
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
    cert-manager.io/cluster-issuer: ${kubectl_manifest.letsencrypt-prod.name}
  hosts:
    - host: auth.${var.domain_name}
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
      - git.${var.domain_name}
      secretName: gitea.tls
EOF
]
}

resource "random_password" "authentik_pg_password" {
  length           = 32
  special          = true
}

resource "random_password" "authentik_secret_key" {
  length           = 50
  special          = true
}