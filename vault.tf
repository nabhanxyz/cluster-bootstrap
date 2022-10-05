resource "kubernetes_namespace" "vault" {
  metadata {
    name        = "vault"
    annotations = {}
    labels      = {}
  }
}

resource "helm_release" "vault" {
  name = "vault"

  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"

  namespace = kubernetes_namespace.vault.metadata[0].name

  values = [<<EOF

global:
  enabled: true
injector:
  enabled: false
server:
  ingress:
    enabled: true
    annotations:
      # |
      # kubernetes.io/ingress.class: nginx
      # kubernetes.io/tls-acme: "true"
      #   or
      # kubernetes.io/ingress.class: nginx
      kubernetes.io/tls-acme: "true"
      external-dns.alpha.kubernetes.io/target: tunnel-origin.${var.domain_name}
      cert-manager.io/cluster-issuer: ${kubectl_manifest.letsencrypt-prod.name}
    ingressClassName: "nginx"

    pathType: Prefix

    # When HA mode is enabled and K8s service registration is being used,
    # configure the ingress to point to the Vault active service.
    activeService: true
    hosts:
      - host: vault.${var.domain_name}
        paths: []
  ha:
    enabled: true
    # replicas: 3
    raft:
      enabled: true
ui:
  # True if you want to create a Service entry for the Vault UI.
  enabled: true


EOF
  ]
}


# resource "kubernetes_ingress_v1" "vault" {
#   metadata {
#     name      = "${kubernetes_namespace.vault.metadata[0].name}-custom"
#     namespace = kubernetes_namespace.vault.metadata[0].name
#     annotations = {
#       # "ingress.kubernetes.io/rewrite-target" = "/"
#       # "kubernetes.io/ingress.class" = "nginx"
#       "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
#       "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTPS"
#       "external-dns.alpha.kubernetes.io/target"        = "tunnel-origin.${var.domain_name}"


#     }
#   }
#   spec {
#     default_backend {
#       service {
#         name = "default-http-backend"
#         # name = "${kubernetes_namespace.yopass.metadata[0].name}.${kubernetes_namespace.yopass.metadata[0].name}.svc"
#         port {
#           number = 80
#         }
#       }
#     }
#     ingress_class_name = "nginx"

#     rule {
#       host = "vault.${var.domain_name}"
#       http {
#         path {
#           backend {
#             service {
#               name = "vault-ui"
#               port {
#                 number = 8200
#               }
#             }
#           }

#           path = "/"
#         }
#       }
#     }
#   }
# }