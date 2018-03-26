pushd ./mongo-rabbitmq/golang
docker-compose build
docker-compose push
docker-compose up
popd