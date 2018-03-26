helm install --name prometheus-k8schallenge stable/prometheus -f prometheus-configforhelm.yaml --namespace k8schallenge-monitoring
helm install --name graphana-k8schallenge stable/grafana --set server.service.type=LoadBalancer,server.adminUser=admin,server.adminPassword=admin  --namespace k8schallenge-monitoring
