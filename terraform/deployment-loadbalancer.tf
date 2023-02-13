resource "kubernetes_deployment" "demo" {
  metadata {
    name      = "demo-deployment"
    namespace = "default"
    labels = {
      app = "demo"
    }
  }

  spec {
    replicas = 3

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = "25%"
        max_unavailable = "25%"
      }
    }

    selector {
      match_labels = {
        app = "demo"
      }
    }

    template {
      metadata {
        labels = {
          app = "demo"
        }
      }

      spec {
        container {
          name  = "demo-spa-container"
          image = "kumaranisk/spa-demo:v1"

          resources {
            limits = {
              cpu    = "1"
              memory = "200Mi"
            }
            requests = {
              cpu    = "500m"
              memory = "100Mi"
            }
          }

          liveness_probe {
            tcp_socket {
              port = 8000
            }
            initial_delay_seconds = 5
            timeout_seconds        = 5
            success_threshold      = 1
            failure_threshold      = 3
            period_seconds         = 10
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 8000
            }
            initial_delay_seconds = 5
            timeout_seconds        = 2
            success_threshold      = 1
            failure_threshold      = 3
            period_seconds         = 10
          }

          image_pull_policy = "Always"

          port {
            name          = "demo-spa-port"
            container_port = 8000
          }
        }

        termination_grace_period_seconds = 1
        restart_policy                     = "Always"
      }
    }
  }
}

resource "kubernetes_service" "demo" {
  metadata {
    name      = "demo-loadbalancer"
    namespace = "default"
    labels = {
      service_label_key = "demo-loadbalancer-label"
    }
  }

  spec {
    type = "LoadBalancer"

    port {
      name       = "demo-loadbalancer-port"
      port       = 8002
      target_port = 8000
      protocol   = "TCP"
    }

    selector = {
      app = "demo"
    }
  }
}
