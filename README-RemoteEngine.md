# Remote Engines Service Helm chart

## Prerequisites

To add the Safe Software charts repository:  
`helm repo add safesoftware https://safesoftware.github.io/helm-charts/`

## Installing the Chart

To quickly get started, find the latest docker image tag for the FME Flow Remote Engines Service [on Docker Hub](https://hub.docker.com/r/safesoftware/fmeflow-core/tags?name=2024.2). It is recommended to use a date-stamped tag from this list. For example: `2024.2.2-20250115`.

Then run the command specifying the docker tag found above:
`helm install fmeremoteenginesservice safesoftware/fmeremoteenginesservice --set fmeflow.image.tag=<docker_tag>`

See the FME Flow doc about working with [Remote Engines Service](https://docs.safe.com/fme/html/FME-Flow/WebUI/Remote-Engine-Services.htm) to connect your deployment to FME Flow.

See all available parameters below.

## Configuration

The following table lists the configurable parameters of the FME Flow helm chart and their default values.

|      Parameter      |               Description             |                    Default                |
|---------------------|---------------------------------------|-------------------------------------------|
| `fmeflow.image.tag` | The docker image tag to use. |  `Nil` You must provide a tag. You can find available tags [here](https://hub.docker.com/r/safesoftware/fmeflow-core/tags?page=1&name=2024.2&ordering=last_updated). |
| `fmeflow.image.pullPolicy` | Image pull policy. IfNotPresent means that the image is pulled only if it is not already present on the node. If this is changed to "Always", then the node will always try to pull to make sure it has the latest version of that tag. | `IfNotPresent` |
| `fmeflow.image.registry` | Docker registry | `docker.io` This parameter should not be changed. |
| `fmeflow.image.namespace` | Docker registry namespace | `safesoftware` This parameter should not be changed. |
| `deployment.hostname` | FME Flow hostname | `localhost` |
| `deployment.port` | FME Flow port | `443` |
| `deployment.tlsSecretName` | Custom TLS certificate, see [documentation](https://docs.safe.com/fme/html/FME-Flow/AdminGuide/Kubernetes/Kubernetes-Deploying-with-Custom-Certificate.htm) for more details | `Nil` |
| `deployment.certManager.issuerName` | Cert Manager issuer name, see [documentation](https://docs.safe.com/fme/html/FME-Flow/AdminGuide/Kubernetes/Kubernetes-Deploying-with-Custom-Certificate.htm) for more details | `Nil` |
| `deployment.certManager.issuerType` | Can be `cluster` or `namespace`, ignored if no issuerName is provided. See [documentation](https://docs.safe.com/fme/html/FME-Flow/AdminGuide/Kubernetes/Kubernetes-Deploying-with-Custom-Certificate.htm) for more details | `cluster` |
| `deployment.startAsRoot` | Starts core container as root and grants the fmeflow user access to the file system. | `false` |
| `deployment.useHostnameIngress` | Configures the ingress to route traffic to FME Flow only if the request matches the value of `deployment.hostname`. Setting this to false will route all traffic on the ingress to FME Flow. | `true` |
| `deployment.disableTLS` | Set this to `true` if you would like to disable TLS on the ingress. This is not recommended. | `false` |
| `resources.core` | [Core CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `1.5Gi`, CPU: `200m` |
| `resources.web` | [Web CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `1Gi`, CPU: `200m` |
| `resources.queue` | [Queue CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `128Mi`, CPU: `100m` |
| `resources.engine` | [Engine CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `128Mi`, CPU: `100m` |
| `resources.database` | [Database CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `128Mi`, CPU: `100m` |
| `storage.reclaimPolicy` | [Volume Reclaim Policy](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaim-policy) | `Delete` |
| `storage.useHostDir` | Allows to map data and database volumes to a directory on a node. Requires path parameters. | `false` |
| `storage.postgresql.class` | Storage class for PostgreSQL data. Ignored if host dir mapping is used. | `Nil` |
| `storage.postgresql.size` | PostgreSQL volume size | `1Gi` |
| `storage.postgresql.path` | Absolute path where database data should be stored on host. Only required if useHostDir is enabled. | `Nil` |
| `storage.fmeflow.accessMode` | Access mode for FME Flow data storage class. | `ReadWriteOnce` |
| `storage.fmeflow.class` | Storage class for FME Flow data. Ignored if host dir mapping is used. | `Nil` |
| `storage.fmeflow.size` | FME Flow data volume size | `10Gi` |
| `storage.fmeflow.path` | Absolute path where FME Flow data should be stored on host. Only required if useHostDir is enabled. | `Nil` |
| `fmeflow.database.password` | The database password for the fmeflow user. | `4fmmsgrz09` |
| `fmeflow.database.passwordSecret` | Instead of specifying a database password in plaintext, specify an existing secret that contains the password to use. |  |
| `fmeflow.database.passwordSecretKey` | The key in the above specified secret that contains the fmeflow database password. |  `fmeflow-db-password` |
| `fmeflow.forcePasswordChange` | Force the admin user to change password on first login | `true` |
| `fmeflow.enableTransactionQueueTimeout` | Enable timeout on queue connections. | `false` |
| `fmeflow.healthcheck.startup.initialDelaySeconds` | Set the initial delay before running the startup probes. | `10` |
| `fmeflow.healthcheck.startup.failureThreshold` | Set the failure threshold for the startup probes. This can be increased if pods take longer to start in your cluster. | `20` |
| `fmeflow.healthcheck.startup.timeoutSeconds` | Set the timeout for the the startup probes. | `5` |
| `fmeflow.healthcheck.startup.periodSeconds` | Set the time (in seconds) between startup probe invocations. This can be increased if pods take longer to start in your cluster. | `30` |
| `scheduling.affinity` | Affinity labels for pod assignment. For information on how to assign pods to specific nodes using the affinity feature, read the [official documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/). | `{}` |
| `scheduling.nodeselector` | Map of nodeselector annotations to add to the pod. For information on how to assign pods to specific nodes using the nodeSelector parameter, read the [official documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/). | `{}` |
| `scheduling.tolerations` | Toleration labels for pod assignment. [Official documentation](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) on taints and tolerations. | `[]` |
| `annotations.statefulset` | `Annotations for the statefulset` | `{}` |
| `annotations.template` | `Annotations for the pod template` | `{}` |
| `ingress.ingressClassName` | `Ingress class name to use for ingress objects.` | `nginx` |
| `ingress.annotations` | `Annotations to apply to all ingress objects.` | `nginx.ingress.kubernetes.io/proxy-body-size: "0"`<br/>`nginx.ingress.kubernetes.io/affinity: cookie`<br/>`nginx.ingress.kubernetes.io/session-cookie-name: fmeflow-ingress`<br/>`nginx.ingress.kubernetes.io/session-cookie-hash: md5` |
| `labels` | Labels to apply to the pod | `{}` |

## Development

### Run unit tests

1. `helm plugin install https://github.com/lrills/helm-unittest`
2. `helm unittest <path/to/chart/source>`
