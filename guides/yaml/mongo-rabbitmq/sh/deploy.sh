helm init
helm install --name mongodb stable/mongodb --namespace k8schallenge-mongorabbitmq
helm install --name rabbitmq stable/rabbitmq --namespace k8schallenge-mongorabbitmq --set rabbitmqUsername=admin,rabbitmqPassword=password