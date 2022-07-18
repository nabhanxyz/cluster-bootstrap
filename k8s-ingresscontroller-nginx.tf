resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name        = "nginx-ingress"
    annotations = {}
    labels      = {}
  }
}

resource "helm_release" "ingress_nginx" {
  name = "nginx-ingress-controller"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  namespace = kubernetes_namespace.ingress_nginx.metadata[0].name

  set {
    name  = "controller.service.type"
    value = "ClusterIP"
  }

  # set {
  #   name  = "service.type"
  #   value = "LoadBalancer"
  # }

  # set {
  #   name  = "defaultBackend.enabled"
  #   value = "true"
  # }

  # set {
  #   name  = "ingressClassResource.name"
  #   value = "nginx"
  # }
  # set {
  #   name  = "ingressClassResource.enabled"
  #   value = "true"
  # }
  # set {
  #   name  = "ingressClassResource.default"
  #   value = "true"
  # }

  # set {
  #   name  = "ingressClassResource.enabled"
  #   value = "true"
  # }

}
