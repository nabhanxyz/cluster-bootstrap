resource "kubernetes_namespace" "argo_wf" {
  metadata {
    name        = "argo"
    annotations = {}
    labels      = {}
  }
}

resource "helm_release" "argo_wf" {
  depends_on = [
    helm_release.cert_manager,
    helm_release.ingress_nginx,
    helm_release.argo_cd,
    helm_release.authentik
  ]
  name = "argo-wf"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-workflows"

  namespace = kubernetes_namespace.argo_wf.metadata[0].name

  values = [<<EOF
server:
  ingress:
    enabled: true
    ingressClassName: nginx
    annotations:
      external-dns.alpha.kubernetes.io/target: tunnel-origin.${var.domain_name}
    #   kubernetes.io/ingress.class: nginx
    #   # kubernetes.io/tls-acme: "true"
    #   # cert-manager.io/cluster-issuer: ${kubectl_manifest.letsencrypt-prod.name}
    # certManager: true
    hosts:
      - argo-wf.${var.domain_name}
  sso:
    issuer: https://argocd.${var.domain_name}/api/dex
    clientId:
      name: argo-workflows-sso
      key: client-id
    clientSecret:
      name: argo-workflows-sso
      key: client-secret
    redirectUrl: https://argo-wf.${var.domain_name}/oauth2/callback
    rbac:
      enabled: true
    scopes:
      - groups
    # issuerAlias: https://argocd.${var.domain_name}/api/dex
    # redirectUrl: https://argo-wf.${var.domain_name}/oauth2/callback
  extraArgs:
  - --auth-mode=sso


EOF
  ]
}


