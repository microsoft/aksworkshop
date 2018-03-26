pushd ./mongo-rabbitmq/netcore
docker-compose build
docker-compose push
docker-compose up
popd