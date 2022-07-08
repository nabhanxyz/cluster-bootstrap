resource "kubernetes_namespace" "argocd" {
  metadata {
    name        = "argocd"
    annotations = {}
    labels      = {}
  }
}

resource "null_resource" "argocd" {
  depends_on = [
    kubernetes_namespace.argocd,
  ]
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ./bootstrap.kubeconfig apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl --kubeconfig ./bootstrap.kubeconfig delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
  }
}

resource "cloudflare_record" "argocd" {
  zone_id = var.cloudflare_zone_id
  name    = "argocd.${var.domain_name}"
  value   = "${cloudflare_argo_tunnel.bootstrap.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = false
}