resource "kubernetes_namespace" "openobserve" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "openobserve" {
  name       = "openobserve"
  namespace  = kubernetes_namespace.openobserve.metadata[0].name
  chart      = "../helm-charts/openobserve"
}

resource "kubernetes_deployment" "logging_app" {
  metadata {
    name      = "logging-app"
    namespace = kubernetes_namespace.openobserve.metadata[0].name
    labels = {
      app = "logging-app"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "logging-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "logging-app"
        }
      }

      spec {
        container {
          name  = "logger"
          image = "busybox"

          command = [
            "sh", "-c",
            "while true; do echo '{\"level\":\"INFO\",\"message\":\"Hello from logging app\"}'; sleep 5; done"
          ]
        }
      }
    }
  }
}
