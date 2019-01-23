# Digital Signature
[![Build Status](https://api.travis-ci.org/edenlabllc/ds.api.svg?branch=develop)](https://travis-ci.org/edenlabllc/ds.api) [![Coverage Status](https://coveralls.io/repos/github/edenlabllc/ds.api/badge.svg?branch=develop)](https://coveralls.io/github/edenlabllc/ds.api?branch=develop)

Index page for projects that related to digital signed documents
- Parse CA signed content
- Implements offline check CRL
- Implements OCSP

Ensure Kafka topic has number of partitions >= $DS_KAFKA_PARTITIONS (10 by default)

## Specification

- [API docs](http://docs.ehealthapi1.apiary.io/)

## Installation

You can use official Docker container to deploy this service, it can be found on [edenlabllc/ds](https://hub.docker.com/r/edenlabllc/) Docker Hub.

### Dependencies

- PostgreSQL 9.6 is used as storage back-end.
- Elixir 1.6
- Erlang OTP 20.3.8
## Configuration

See [ENVIRONMENT.md](docs/ENVIRONMENT.md).

## License

See [LICENSE.md](LICENSE.md).
