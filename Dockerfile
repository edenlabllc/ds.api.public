FROM elixir:1.6 as builder

ARG APP_NAME

ADD . /home/ds
WORKDIR /home/ds

RUN ls -la

RUN ln -s /home/ds/apps/digital_signature/priv/libUACryptoQ.so /usr/local/lib/libUACryptoQ.so.1
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV MIX_ENV=prod
ENV REPLACE_OS_VARS=true

RUN apt-get update \
&& apt-get install -y vim

RUN mix do \
  local.hex --force, \
  local.rebar --force, \
  deps.get, \
  deps.compile, \
  release --name=${APP_NAME}

RUN ls -la /home/ds/_build/prod/rel/
RUN ls -la /home/ds/_build/prod/rel/${APP_NAME}
FROM elixir:1.6-slim

ARG APP_NAME

ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /home
COPY --from=builder /home/ds/apps/digital_signature/priv/libUACryptoQ.so /usr/local/lib/libUACryptoQ.so.1
# COPY ./libUACryptoQ.so /usr/local/lib/libUACryptoQ.so.1
# ADD ./ds/apps/digital_signature/priv/libUACryptoQ.so /usr/local/lib/libUACryptoQ.so.1
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

COPY --from=builder /home/ds/_build/prod/rel/${APP_NAME}/releases/0.1.0/${APP_NAME}.tar.gz .

RUN echo $DB_HOST
RUN echo $DB_NAME
RUN echo $DB_USER
RUN echo $DB_PASSWORD
RUN echo $DB_PORT
RUN echo $DB_HOST
RUN echo $KAFKA_HOST
RUN tar -xzf ${APP_NAME}.tar.gz; rm ${APP_NAME}.tar.gz
RUN ls -la
# RUN ls -la releases/
RUN ls -la ./bin/
# RUN ls -la /home/ds/
# RUN ls -la /home/ds/releases/

ENV REPLACE_OS_VARS=true \
  APP=${APP_NAME}

CMD ./bin/${APP} foreground
