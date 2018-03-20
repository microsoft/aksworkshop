helm install --name prometheus-k8schallenge stable/prometheus --version 4.6.13 -f prometheus-configforhelm.yaml --namespace k8schallenge-monitoring
helm install --name graphana-k8schallenge stable/grafana --version 0.5.1 --set server.service.type=LoadBalancer,server.adminUser=admin,server.adminPassword=admin  --namespace k8schallenge-monitoring
