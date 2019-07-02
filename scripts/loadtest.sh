export SERVICEIP=$1
export CONTENT_TYPE="Content-Type: application/json"
export PAYLOAD='{"EmailAddress": "email@domain.com", "Product": "prod-1", "Total": 100}'
export ENDPOINT=http://$SERVICEIP/v1/order

echo "POST $ENDPOINT"
echo $CONTENT_TYPE
echo $PAYLOAD

echo
read -p "Initiate load test against $SERVICEIP? Type Y to confirm: " -n 1 -r
echo 

if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo "Phase 1: Warming up - 30 seconds, 100 users."
  docker run --rm -it azch/loadtest -z 30s -c 100 -d "$PAYLOAD" -H "$CONTENT_TYPE" -m POST "$ENDPOINT"
  
  echo "Waiting 10 seconds for the cluster to stabilize"
  sleep 10

  echo "\nPhase 2: Warming up - 30 seconds, 200 users."
  docker run --rm -it azch/loadtest -z 30s -c 200 -d "$PAYLOAD" -H "$CONTENT_TYPE" -m POST "$ENDPOINT"

  echo "Waiting 10 seconds for the cluster to stabilize"
  sleep 10

  echo "\nPhase 3: Load test - 30 seconds, 400 users."
  docker run --rm -it azch/loadtest -z 30s -c 400 -d "$PAYLOAD" -H "$CONTENT_TYPE" -m POST "$ENDPOINT"

  echo "Waiting 10 seconds for the cluster to stabilize"
  sleep 10

  echo "\nPhase 4: Load test - 30 seconds, 800 users."
  docker run --rm -it azch/loadtest -z 30s -c 800 -d "$PAYLOAD" -H "$CONTENT_TYPE" -m POST "$ENDPOINT"

  echo "Waiting 10 seconds for the cluster to stabilize"
  sleep 10

  echo "\nPhase 5: Load test - 30 seconds, 1600 users."
  docker run --rm -it azch/loadtest -z 30s -c 1600 -d "$PAYLOAD" -H "$CONTENT_TYPE" -m POST "$ENDPOINT"
else
  echo "Done."
fi