resource "kubernetes_namespace" "gitea" {
  count = var.enable_gitea
  metadata {
    name        = "gitea"
    annotations = {}
    labels      = {}
  }
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

EOF
]
}