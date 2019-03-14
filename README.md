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

### Applications
- core: provides processing entities; this app always use as dependency in ds_api, ocsp_service, synchronizer_crl
- digital_signature: provides nif parsing signed content uses `uaCrypto (ICAO version)` (see more in appropriate LICENSE.md)
- ds_api: API check signed content
  1. Parse signed content with digital_signature
  2. 1. a) If fitting CRL file (Certificate Revoked List) found in database and actual, makes offline check if certificate revoked
  2. 1. b) Signed contend certificate info pushed into kafka, and later online certificate check (OCSP) will be applied. If sign is not actual, admin receive email notification
  2. 2. If no CRL file for content found or CRL outdated, online certificate status check (OCSP) will be done immediately and notify synchronizer_crl service about new CRL
- ocsp_service: makes OCSP online status certificate protocol check with digital_signature to corresponding provider
- synchronizer_crl: download providers certificate revoked list, parse, store revoked certificates serial numbers and continues doing after   next_update time when provider will update CRL file 

### Dependencies

- PostgreSQL 9.6 is used as storage back-end.
- Elixir 1.6
- Erlang OTP 20.3.8
## Configuration

See [ENVIRONMENT.md](docs/ENVIRONMENT.md).

## License

See [LICENSE.md](LICENSE.md).
