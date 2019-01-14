FROM elixir:1.7 as builder

ARG APP_NAME

ADD . /home/ds
WORKDIR /home/ds

RUN ln -s /home/ds/apps/digital_signature/priv/libUACryptoQ.so /usr/local/lib/libUACryptoQ.so.1
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV MIX_ENV=prod
ENV REPLACE_OS_VARS=true

RUN apt-get install git
RUN mix do \
  local.hex --force, \
  local.rebar --force, \
  deps.get, \
  deps.compile


RUN mix release --name=${APP_NAME}
RUN git log --pretty=format:"%H %cd %s" > commits.txt

FROM elixir:1.7-slim

ARG APP_NAME

ENV TZ=Europe/Kiev

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /home

COPY --from=builder /home/ds/apps/digital_signature/priv/libUACryptoQ.so /usr/local/lib/libUACryptoQ.so.1

ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

COPY --from=builder /home/ds/_build/prod/rel/${APP_NAME}/releases/0.1.0/${APP_NAME}.tar.gz .
COPY --from=builder /home/ds/commits.txt /app

RUN tar -xzf ${APP_NAME}.tar.gz; rm ${APP_NAME}.tar.gz

ENV REPLACE_OS_VARS=true \
  APP=${APP_NAME}


CMD ./bin/${APP} foreground
