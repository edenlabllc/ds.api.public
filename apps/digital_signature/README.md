# Digital Signature API
[![Build Status](https://api.travis-ci.org/edenlabllc/digital_signature.api.svg?branch=master)](https://travis-ci.org/edenlabllc/digital_signature.api) [![Coverage Status](https://coveralls.io/repos/github/edenlabllc/digital_signature.api/badge.svg?branch=master)](https://coveralls.io/github/edenlabllc/digital_signature.api?branch=master)

This api allows to validate pkcs7 data and get unpacked data with signer information from it.

## Specification

- [API docs](http://docs.ehealthapi1.apiary.io/#reference/internal.-digital-signature/verification/digital-signature)

## Installation

You can use official Docker container to deploy this service, it can be found on [edenlabllc/ds.api](https://hub.docker.com/r/edenlabllc/ds.api/) Docker Hub.

### Dependencies

- PostgreSQL 9.6 is used as storage back-end.
- Elixir 1.4
- Erlang/OTP 19.2
- [Digital Signature LIB](https://github.com/edenlabllc/digital_signature.lib) is used for processing pkcs7 data.

## Configuration

See [ENVIRONMENT.md](docs/ENVIRONMENT.md).

## License

See [LICENSE.md](LICENSE.md).
