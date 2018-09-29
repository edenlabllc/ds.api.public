FROM elixir:1.6 as builder

ARG APP_NAME

ADD . /home/ds

WORKDIR /home/ds

RUN ln -s /home/ds/apps/digital_signature/priv/libUACryptoQ.so /usr/local/lib/libUACryptoQ.so.1
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

ENV MIX_ENV=prod

RUN mix do \
  local.hex --force, \
  local.rebar --force, \
  deps.get, \
  deps.compile, \
  release.init, \
  release
RUN ls /home/ds/_build/prod/rel/ds/releases/0.1.0/ \
&& tar -xzf /home/ds/_build/prod/rel/ds/releases/0.1.0/ds.tar.gz \
&& ls /home/ds/_build/prod/rel/ds/releases/0.1.0/
FROM elixir:1.6-slim

ARG APP_NAME

ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /home/ds
COPY --from=builder /home/ds/apps/digital_signature/priv/libUACryptoQ.so /usr/local/lib/libUACryptoQ.so.1
#COPY ./libUACryptoQ.so /usr/local/lib/libUACryptoQ.so.1
#ADD ./ds/apps/digital_signature/priv/libUACryptoQ.so /usr/local/lib/libUACryptoQ.so.1
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

COPY --from=builder /home/ds/_build/prod/rel/ds/releases/0.1.0/ds.tar.gz .

RUN tar -xzf ds.tar.gz; rm ds.tar.gz

ENV REPLACE_OS_VARS=true \
  APP=${APP_NAME}

CMD ./bin/${APP} foreground
