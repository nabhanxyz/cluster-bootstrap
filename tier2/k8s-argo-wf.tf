resource "kubernetes_namespace" "argo_wf" {
  metadata {
    name        = "argo"
    annotations = {}
    labels      = {}
  }
}

resource "helm_release" "argo_wf" {
  depends_on = [
    kubernetes_cluster_role_binding.user_default_login
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
    #   # cert-manager.io/cluster-issuer: letsencrypt-prod
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


resource "kubernetes_service_account" "user_default_login" {
  metadata {
    name      = "user-default-login"
    namespace = kubernetes_namespace.argo_wf.metadata[0].name

    annotations = {
      "workflows.argoproj.io/rbac-rule" = "true"

      "workflows.argoproj.io/rbac-rule-precedence" = "0"
    }
  }
  # automount_service_account_token = true
  secret {
    name = "user-default-login"
  }
}

resource "kubernetes_secret_v1" "example" {
  metadata {
    name      = "user-default-login"
    namespace = kubernetes_namespace.argo_wf.metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name" = "user-default-login"
    }
  }

  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_cluster_role" "user_default_login" {
  metadata {
    name = kubernetes_service_account.user_default_login.metadata[0].name
  }

  rule {
    verbs      = ["*"]
    api_groups = ["", "*"]
    resources  = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "user_default_login" {
  metadata {
    name = kubernetes_service_account.user_default_login.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.user_default_login.metadata[0].name
    namespace = kubernetes_namespace.argo_wf.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.user_default_login.metadata[0].name
  }
}

