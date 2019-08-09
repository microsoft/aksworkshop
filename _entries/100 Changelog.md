---
sectionid: changelog
sectionclass: h1
title: Changelog
is-parent: yes
---

All notable changes to this workshop will be documented in this file.

## 2019-07-15

### Changed

- Updated Log Analytics instructions

## 2019-07-11

### Added

- Prometheus metric collection using Azure Monitor

## 2019-07-09

### Added

- Missing instruction to update ACR repository in the forked code

## 2019-06-24

### Added

- Instructions to enable multi-stage pipeline preview

### Changed

- Updated capture order app to load MongoDB details from a Kubernetes secret

## 2019-05-24

### Added

- Added changelog

### Removed

- Removed Helm section from DevOps until it is reworked into the new multi-stage pipelines experience

### Changed

- Updated Azure DevOps section with the new multi-stage pipelines experience
 
## 2019-04-29

### Fixed

- Missing `enable-vmss` flag

### Changed

- Clarified when to use the liveness check hint

## 2019-04-24

### Fixed

- Added missing line breaks "`\`" to `az aks create` command

### Changed

- Updated proctor notes for using Application Insights key
- Updated Azure Key Vault FlexVol instructions

## 2019-04-23

### Changed

- Updated prerequisite section
- Simplified scoring section

## 2019-04-19

### Added

- Added cluster autoscaler section
- Added clean up section

### Removed

- Load testing with VSTS load tests because it is deprecated

### Fixed

- Fixed command to get the latest Kubernetes version

### Changed

- Workshop can be done exclusively using Azure Cloud Shell

## 2019-04-02

### Added

- Screenshots to Azure DevOps variables tab

### Fixed

- Fixed command to observe pods after load to use the correct label `app=captureorder`

## 2019-03-15

### Added

- Added Azure Key Vault Flex Vol task

## 2019-03-14

### Changed

- Updated commands to always use the latest Kubernetes version

### Fixed

- Fixed `sed` command syntax in CI/CD task

## 2019-02-21

### Changed

- Updated scoring to use Requests Per Second (RPS)

## 2019-02-13

### Added

- Added Ingress section
- Added SSL/TLS section

### Changed

- Updated DNS section

## 2019-01-24

### Added

- Virtual Nodes section