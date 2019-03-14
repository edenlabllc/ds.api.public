#!/bin/bash
rm -rf _build/

echo "Create Docker network"
docker network create ds_test_db

echo "Run Postgres container"
POSTGRES_USER=postgres POSTGRES_PASSWORD=postgres docker run -d --name ds_test_db --net ds_test_db postgres:9.6

echo "Run Kafka container"
 docker run -d \
     -e CONSUMER_THREADS=1 \
     --env GROUP_ID="digital_signature" \
     --net=ds_test_db \
     --name=ds_test_kafka \
     spotify/kafka

# docker exec -it ds_test_kafka /bin/bash
# /opt/kafka_2.11-0.10.1.0/bin/kafka-console-consumer.sh --new-consumer --bootstrap-server localhost:9092 --topic digital_signature


echo "Build App test image"
IMAGE=$(docker build -f Dockerfile.local . | tail -1 | awk '{ print $NF }')

echo "Run App test image"

docker run \
  -e ERLANG_COOKIE=elixir \
  -e DB_HOST=ds_test_db \
  -e DB_PORT=5432 \
  -e DB_USER=postgres \
  -e DB_NAME=ds \
  -e DB_PASSWORD=postgres \
  -e CONSUMER_GROUP=digital_signature \
  -e KAFKA_BROKERS="ds_test_kafka:9092" \
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
