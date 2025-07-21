#resource "helm_release" "metrics_server" {
 # name       = "metrics-server"
  #repository = "https://kubernetes-sigs.github.io/metrics-server/"
 # chart      = "metrics-server"
 # version    = "3.12.1"

#  namespace = "kube-system"
 # create_namespace = false

 # values = [
 #   file("${path.module}/metrics-values.yaml")
 # ]

 # depends_on = [azurerm_kubernetes_cluster.aks_cluster]
#}