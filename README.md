# BETA SPM/Suite On-Premise
On premise setup for process manager and suite clients.

Official bootstrap for running your own Signavio Process Manager with [Docker](https://www.docker.com/).


## Requirements

 * Docker 17.12.0+
 * Compose 1.23.0+


## compose.sh

Setup uses prepared Docker images, which are built regularly and stored in *signavio-on-premise.jfrog.io*.

This script is a convenience wrapper around docker-compose to make life easier.
Before calling docker-compose, it outputs what will be executed.
The parameters added to the script define, what will be started.

### Parameters

- `spm` - Signavio Process Manager
- `solman` - SAP Solution Manager 7.2 Connector Service
- `hub` - Collaboration Hub (Hub-Next)

## How to update the SPM Docker image

NOTE. If you need to pull the SPM image explicitly

```bash
./compose.sh spm-pull
```

## Solman 7.2 connector

The Solman 7.2 connector can be enabled by adding `solman` to the command line (e.g. `./compose.sh spm solman`).
The Solman connector database is by default exposed to the host at port 8084.

Solman will be visible in SPM UI menu even when not loaded.
Nevertheless, SPM will throw an exception if Solman is selected and not started.

### configuration with conf.d

To configure Solman, [conf.d](https://github.com/kelseyhightower/confd) is used.
Use file 'setup.env' in folder 'services/solman' to set values.
conf.d will write 'application.yml' accordingly when starting the Solman container.
