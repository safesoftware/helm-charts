# Official Safe Software Helm Charts

## Prerequisites

To add the Safe Software charts repository:  
`helm repo add safesoftware https://safesoftware.github.io/helm-charts/`

## Installing the Chart

To walk you through the helm installation process, a quick-start script for all supported FME Server versions has been created and can be found [here](http://fme.ly/k8s).

## FME Server 2018.1.0 BETA

### Configuration

The following table lists the configurable parameters of the FME Server 2018.1.0 BETA chart and their default values.

|      Parameter      |               Description             |                    Default                |
|---------------------|---------------------------------------|-------------------------------------------|
| `fmeserver.buildNr` | The requested FME Server Build Number |  `Nil` You must provide a build number. You can find available build numbers [here](http://fme.ly/k8s). |
| `deployment.hostname` | FME Server hostname | `localhost` |
| `deployment.proxyReadTimeout` | Default proxy read timeout (in seconds) | `60` |
| `deployment.tlsSecretName` | Custom TLS certificate, see [documentation](https://docs.google.com/document/d/e/2PACX-1vRHu7tkQLJsJ0uXRz-KgSxo6DOQL38Sc97PQPgMR0MLAfsEqrV7-HZeRE7i3BSRDjjIWDmAJoWkICii/pub) for more details | `Nil` |
| `deployment.certManager.issuerName` | Cert Manager issuer name, see [documentation](https://docs.google.com/document/d/e/2PACX-1vRHu7tkQLJsJ0uXRz-KgSxo6DOQL38Sc97PQPgMR0MLAfsEqrV7-HZeRE7i3BSRDjjIWDmAJoWkICii/pub) for more details | `Nil` |
| `deployment.certManager.issuerType` | Can be `cluster` or `namespace`, ignored if no issuerName is provided. See [documentation](https://docs.google.com/document/d/e/2PACX-1vRHu7tkQLJsJ0uXRz-KgSxo6DOQL38Sc97PQPgMR0MLAfsEqrV7-HZeRE7i3BSRDjjIWDmAJoWkICii/pub) for more details | `cluster` |
| `storage.reclaimPolicy` | [Volume Reclaim Policy](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaim-policy) | `Delete` |
| `storage.useHostDir` | Allows to map data and database volumes to a directory on a node. Requires path parameters. | `false` |
| `storage.postgresql.class` | Storage class for PostgreSQL data. Ignored if host dir mapping is used. | `Nil` |
| `storage.postgresql.size` | PostgreSQL volume size | `1Gi` |
| `storage.postgresql.path` | Absolute path where database data should be stored on host. Only required if useHostDir is enabled. | `Nil` |
| `storage.fmeserver.class` | Storage class for FME Server data. Ignored if host dir mapping is used. | `Nil` |
| `storage.fmeserver.size` | FME Server data volume size | `10Gi` |
| `storage.fmeserver.path` | Absolute path where FME Server data should be stored on host. Only required if useHostDir is enabled. | `Nil` |
| `images.pullPolicy` | Image pull policy | `IfNotPresent` |
| `images.registry` | Docker registry | `quay.io` This parameter should not be changed. |
| `images.namespace` | Docker registry namespace | `safesoftware` This parameter should not be changed. |

## Development

### Run unit tests

1. `helm plugin install https://github.com/lrills/helm-unittest`
2. `helm unittest <path/to/chart/source>`