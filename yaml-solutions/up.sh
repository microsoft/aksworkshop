export LOCATION=eastus
export RGNAME=akschallenge
export AKSNAME=akstest
export K8SVERSION=1.11.5

echo "Logging in to Azure CLI"
az login

echo "\nCreating Resource Group"
az group create --name $RGNAME --location $LOCATION

echo "\nCreating AKS cluster"
az aks create --resource-group $RGNAME --name $AKSNAME --enable-addons monitoring --kubernetes-version $K8SVERSION --generate-ssh-keys --location $LOCATION

echo "\nSleeping for 10 seconds to wait for cluster to stabilize"
sleep 10

echo "\nRetrieving cluster credentials"
az aks get-credentials --resource-group $RGNAME --name $AKSNAME --overwrite-existing

echo "\nInstalling kubectl"
az aks install-cli

echo "\nRetrieving nodes"
kubectl get nodes

echo "\nSetting up Tiller Service Account"
kubectl apply -f http://aksworkshop.io/yaml-solutions/01.%20challenge-02/helm-rbac.yaml

echo "\nSetting up Log Reader Service Account"
kubectl apply -f http://aksworkshop.io/yaml-solutions/01.%20challenge-03/logreader-rbac.yaml

echo "\nInitializing Helm"
helm init --service-account tiller

echo "\nSleeping for 10 seconds to wait for the Tiller pod"
sleep 10

echo "\nInstalling replicated MongoDB"
helm install stable/mongodb --name orders-mongo  --set replicaSet.enabled=true,mongodbUsername=orders-user,mongodbPassword=orders-password,mongodbDatabase=akschallenge

echo "\nWaiting for MongoDB to come up for 2 minutes"
sleep 120

echo "\nDeploying captureorder deployment"
kubectl apply -f http://aksworkshop.io/yaml-solutions/01.%20challenge-02/captureorder-deployment.yaml

echo "\nDeploying captureorder service"
kubectl apply -f http://aksworkshop.io/yaml-solutions/01.%20challenge-02/captureorder-service.yaml

echo "\nWatching pods"
watch kubectl get pods

echo "\nWaiting to get an external service ip"
SERVICEIP=""
while [ -z "$SERVICEIP" ]; 
do
  SERVICEIP=$(kubectl get service captureorder -o jsonpath="{.status.loadBalancer.ingress[*].ip}")
  echo "Service IP: $SERVICEIP"
  sleep 5
done

echo "\nService is up, sending a request"
curl -d '{"EmailAddress": "email@domain.com", "Product": "prod-1", "Total": 100}' -H "Content-Type: application/json" -X POST http://$SERVICEIP/v1/order
