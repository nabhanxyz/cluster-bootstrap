resource "kubernetes_namespace" "gitea" {
  count = var.enable_gitea
  metadata {
    name        = "gitea"
    annotations = {}
    labels      = {}
  }
}

resource "kubernetes_secret" "gitea_admin" {
  metadata {
    name = "gitea-admin-secret"
    namespace = kubernetes_namespace.gitea[0].metadata[0].name
  }

  data = {
    username = var.bootstrap_username
    password = var.bootstrap_password
  }

  type = "Opaque"
}

resource "helm_release" "gitea" {
  count = var.enable_gitea
  depends_on = [
    helm_release.cert_manager,
    helm_release.ingress_nginx
  ]
  name = "gitea"

  repository = "https://dl.gitea.io/charts/"
  chart      = "gitea"

  namespace = kubernetes_namespace.gitea[0].metadata[0].name

  values = [<<EOF
memcached:
  enabled: true

postgresql:
  enabled: false

mariadb:
  enabled: true

ingress:
  enabled: true
  annotations:
    external-dns.alpha.kubernetes.io/target: tunnel-origin.${var.domain_name}
    kubernetes.io/ingress.class: nginx
    # kubernetes.io/tls-acme: "true"
    # cert-manager.io/cluster-issuer: ${kubectl_manifest.letsencrypt-prod.name}
  # certManager: true
  hostname: git.${var.domain_name}

  hosts:
    - host: git.${var.domain_name}
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
      - git.${var.domain_name}
      secretName: gitea.tls
persistence:
  enabled: true
  size: 5Gi

gitea:
  admin:
    existingSecret: ${kubernetes_secret.gitea_admin.metadata[0].name}
  config:
    server:
      SSH_DOMAIN: git-ssh.${var.domain_name}


EOF
]
}


