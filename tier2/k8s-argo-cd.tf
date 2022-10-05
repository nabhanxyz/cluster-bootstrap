resource "kubernetes_namespace" "argo_cd" {
  metadata {
    name        = "argocd"
    annotations = {}
    labels      = {}
  }
}

resource "random_uuid" "argo_uuid" {
}


resource "kubernetes_secret" "argo_cd_token" {
  metadata {
    name      = "argo-workflows-sso"
    namespace = kubernetes_namespace.argo_cd.metadata[0].name
  }

  data = {
    client-id = "argo-workflows-sso"
    client-secret : random_uuid.argo_uuid.result
  }

  type = "Opaque"
  depends_on = [
    kubernetes_namespace.argo_cd,
  ]

}

resource "kubernetes_secret" "argo_wf_token" {
  metadata {
    name      = "argo-workflows-sso"
    namespace = kubernetes_namespace.argo_wf.metadata[0].name
  }

  data = {
    client-id = "argo-workflows-sso"
    client-secret : random_uuid.argo_uuid.result
  }

  type = "Opaque"
  depends_on = [
    kubernetes_namespace.argo_cd,
  ]

}

resource "helm_release" "argo_cd" {

  name = "argo-cd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  namespace = kubernetes_namespace.argo_cd.metadata[0].name

  values = [<<EOF
dex:
  env:
    - name: ARGO_WORKFLOWS_SSO_CLIENT_SECRET
      valueFrom:
        secretKeyRef:
          name: argo-workflows-sso
          key: client-secret
server:
  ingress:
    enabled: true
    ingressClassName: nginx
    annotations:
      external-dns.alpha.kubernetes.io/target: tunnel-origin.${var.domain_name}
  #   #   kubernetes.io/ingress.class: nginx
  #   #   # kubernetes.io/tls-acme: "true"
  #   #   # cert-manager.io/cluster-issuer: letsencrypt-prod
  # #   # certManager: true
    hosts:
      - argocd.${var.domain_name}
  config:
    url: https://argocd.${var.domain_name}
    dex.config: |
      # logger:
      #   level: debug
      #   format: json
      connectors:
        # OIDC
        - type: oidc
          id: oidc
          name: Authentik
          config:
            issuer:  https://auth.${var.domain_name}/application/o/argocd/
            clientID: ${random_password.authentik_argocd_client_id.result}
            clientSecret: ${random_password.authentik_argocd_client_secret.result}
            redirectURI: https://argocd.${var.domain_name}/api/dex/callback
            getUserInfo: true
            insecureEnableGroups: true
            scopes: 
              - profile
              - email
              - groups
              - name
      staticClients:
        - id: argo-workflows-sso
          name: Argo Workflow
          redirectURIs:
            - https://argo-wf.${var.domain_name}/oauth2/callback
            - https://argo-wf.${var.domain_name}/oauth2/redirect
          secretEnv: ARGO_WORKFLOWS_SSO_CLIENT_SECRET

EOF
  ]
}


# resource "cloudflare_record" "argocd" {
#   zone_id = data.cloudflare_zone.zone_id.id
#   name    = "argocd.${var.domain_name}"
#   value   = "tunnel-origin.${var.domain_name}"
#   type    = "CNAME"
#   proxied = true
# }

# resource "kubernetes_ingress_v1" "argocd" {
#   metadata {
#     name      = "argocd"
#     namespace = "argocd"
#     annotations = {
#       # "ingress.kubernetes.io/rewrite-target" = "/"
#       # "kubernetes.io/ingress.class" = "nginx"
#       "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
#       "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTPS"
#     }
#   }
#   spec {
#     default_backend {
#       service {
#         name = "argo-cd-argocd-server"
#         port {
#           number = 80
#         }
#       }
#     }
#     ingress_class_name = "nginx"

#     rule {
#       host = "argocd.${var.domain_name}"
#       http {
#         path {
#           backend {
#             service {
#               name = "argo-cd-argocd-server"
#               port {
#                 number = 443
#               }
#             }
#           }

#           path = "/(.*)"
#         }
#       }
#     }
#   }
# }