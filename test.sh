#!/bin/bash

echo "Create Docker network"
docker network create ds_test_db

echo "Run Postgres container"
POSTGRES_USER=postgres POSTGRES_PASSWORD=postgres docker run -d --name ds_test_db --net ds_test_db postgres:9.6

echo "Run Kafka container"
 docker run -d \
     -e CONSUMER_THREADS=1 \
     --env GROUP_ID="digital_signature" \
     --env TOPICS=digital_signature \
     --env NUM_PARTITIONS=20 \
     --net=ds_test_db \
     --name=ds_test_kafka \
     spotify/kafka

echo "Build App test image"
IMAGE=$(docker build -f Dockerfile.local . | tail -1 | awk '{ print $NF }')

echo "Run App test image"

# docker run \
#   -e DB_HOST=ds_test_db \
#   -e KAFKA_HOST=ds_test_kafka \
#   -e KAFKA_PORT=9092 \
#   --rm -it --net ds_test_db $IMAGE /bin/bash -c 'cd /home/ds; for i in {1..20}; do mix test; done;'

docker run \
  -e DB_HOST=ds_test_db \
  -e DB_PORT=5432 \
  -e DB_USER=postgres \
  -e DB_NAME=ds \
  -e DB_PASSWORD=postgres \
  -e KAFKA_HOST=ds_test_kafka \
  -e KAFKA_PORT=9092 \
  -e CONSUMER_GROUP=digital_signature \
  -v `pwd`:/home/ds \
  --rm -it --net ds_test_db $IMAGE /bin/bash -c 'cd /home/ds; /bin/bash;'


# cleanup
echo "Cleanup..."
docker stop ds_test_db
docker stop ds_test_kafka

docker rm ds_test_db
docker rm ds_test_kafka
docker rmi $IMAGE

docker network rm ds_test_db
