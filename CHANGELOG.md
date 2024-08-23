# Changelog

All notable changes to this project will automatically be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v0.6.2 - 2024-08-23

### What's Changed

#### 🐛 Bug Fixes

* fix: Specify transport_transit_gateway_attachment_id when vpn connection has outside_ip_address_type of private (#14) @jorrite

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-transit-gateway/compare/v0.6.1...v0.6.2

## v0.6.1 - 2024-07-24

### What's Changed

#### 🐛 Bug Fixes

* fix: the vpn address type to be unique per vpn (#13) @stimmerman

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-transit-gateway/compare/v0.6.0...v0.6.1

## v0.6.0 - 2024-07-16

### What's Changed

#### 🚀 Features

* feature: add support for AWS VPN with private IP space and Transit Gateway CIDR blocks (#12) @stimmerman

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-transit-gateway/compare/v0.5.0...v0.6.0

## v0.5.0 - 2024-03-28

### What's Changed

#### 🚀 Features

* feat: make transit gateway sharing more flexible, allowing more principal types (#11) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-transit-gateway/compare/v0.4.0...v0.5.0

## v0.4.0 - 2024-03-18

### What's Changed

#### 🚀 Features

* feature: add variable to control whether resource attachment requests are automatically accepted (#10) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-transit-gateway/compare/v0.3.0...v0.4.0

## v0.3.0 - 2023-06-01

### What's Changed

#### 🚀 Features

- feature: make it possible to specify name_prefix used in iam role and policy (#7) @stimmerman

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-transit-gateway/compare/v0.2.0...v0.3.0

## v0.2.0 - 2023-03-30

### What's Changed

- Add release drafter (#4) @stimmerman

#### 🚀 Features

- enhancement(github): Update Github workflows (#3) @stimmerman

#### 📖 Documentation

- enhancement(github): Update Github workflows (#3) @stimmerman

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-transit-gateway/compare/v0.1.0...v0.2.0

## v0.1.0 - 2022-02-22

- Initial module version
