export LOCATION=westus
export RGNAME=akschallenge
export AKSNAME=aksdelete
export K8SVERSION=$(az aks get-versions -l $LOCATION --query 'orchestrators[-1].orchestratorVersion' -o tsv)

#echo "Logging in to Azure CLI"
#az login

echo "\nCreating Resource Group"
az group create --name $RGNAME --location $LOCATION

echo "\nCreating AKS cluster"
az aks create --resource-group $RGNAME --name $AKSNAME --enable-addons monitoring --kubernetes-version $K8SVERSION --generate-ssh-keys --location $LOCATION --service-principal "88c0f4fa-c91f-4095-96db-462f942c0172" --client-secret "58b1983b-ed1a-49a9-a602-5c918003dd38"

echo "\nSleeping for 10 seconds to wait for cluster to stabilize"
sleep 10

echo "\nRetrieving cluster credentials"
az aks get-credentials --resource-group $RGNAME --name $AKSNAME --overwrite-existing

echo "\nInstalling kubectl"
az aks install-cli

echo "\nRetrieving nodes"
kubectl get nodes

echo "\nSetting up Tiller Service Account"
kubectl apply -f http://staging.aksworkshop.io/yaml-solutions/01.%20challenge-02/helm-rbac.yaml

echo "\nSetting up Log Reader Service Account"
kubectl apply -f http://staging.aksworkshop.io/yaml-solutions/01.%20challenge-03/logreader-rbac.yaml

echo "\nInitializing Helm"
helm init --history-max 200 --service-account tiller --node-selectors "beta.kubernetes.io/os=linux"

echo "\nWaiting for Tiller pod to be Running"
TILLERSTATUS=""
while [ "$TILLERSTATUS" != "Running" ]; 
do
  TILLERSTATUS=$(kubectl get pod -n kube-system -l name=tiller -o jsonpath="{.items[0].status.phase}")
  echo "Tiller: $TILLERSTATUS"
  sleep 5
done

echo "\nInstalling replicated MongoDB"
helm install stable/mongodb --name orders-mongo  --set replicaSet.enabled=true,mongodbUsername=orders-user,mongodbPassword=orders-password,mongodbDatabase=akschallenge

echo "\nWaiting for MongoDB primary to be running"
MONGOPRIMARY=""
while [ "$MONGOPRIMARY" != "Running" ]; 
do
  MONGOPRIMARY=$(kubectl get pod -l app=mongodb,component=primary,release=orders-mongo -o jsonpath="{.items[0].status.phase}")
  echo "MongoDB primary: $MONGOPRIMARY"
  sleep 5
done

echo "\nDeploying captureorder deployment"
kubectl apply -f https://staging.aksworkshop.io/yaml-solutions/01.%20challenge-02/captureorder-deployment.yaml

echo "\nDeploying captureorder service"
kubectl apply -f https://staging.aksworkshop.io/yaml-solutions/01.%20challenge-02/captureorder-service.yaml


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
sleep 5

echo "\nDeploying frontend deployment"
curl -o fed.yaml -L https://staging.aksworkshop.io/yaml-solutions/01.%20challenge-02/frontend-deployment.yaml
sed -i -e "s/_PUBLIC_IP_CAPTUREORDERSERVICE_/$SERVICEIP/g" fed.yaml
kubectl apply -f fed.yaml

echo "\nDeploying frontend service"
kubectl apply -f https://staging.aksworkshop.io/yaml-solutions/01.%20challenge-02/frontend-service.yaml

echo "\nEnabling HTTP routing add-on"
az aks enable-addons --resource-group $RGNAME --name $AKSNAME --addons http_application_routing

echo "\Retrieving cluster DNS zone name"
export DNSZONENAME=$(az aks show --resource-group $RGNAME --name $AKSNAME --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName -o tsv)

echo "\nDeploying frontend ingress"
curl -o fei.yaml -L https://staging.aksworkshop.io/yaml-solutions/01.%20challenge-02/frontend-ingress.yaml
sed -i -e  "s/_CLUSTER_SPECIFIC_DNS_ZONE_/$DNSZONENAME/g" fei.yaml
kubectl apply -f fei.yaml

echo "\nGo to http://frontend.$DNSZONENAME to test"
