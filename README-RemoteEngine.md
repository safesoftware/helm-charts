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

## Ingress Migration Notes

This chart now targets the official [NGINX Ingress Controller](https://docs.nginx.com/nginx-ingress-controller/), see [Community Ingress NGINX retirement](https://kubernetes.io/blog/2025/11/11/ingress-nginx-retirement/).
If you are migrating from previous chart versions that used community `ingress-nginx`, update your values as follows:

1. Keep `deployment.useHostnameIngress=true` when using the official NGINX Ingress Controller.
2. Set `deployment.hostname` to a DNS hostname (for example `fmeflow.example.com` or `localhost`). Do not use an IP address with hostname-based ingress.
3. Replace old `nginx.ingress.kubernetes.io/*` annotations with `nginx.org/*` annotations.
4. Sticky session defaults were removed. If your deployment depended on sticky sessions, configure an alternative strategy outside these chart defaults.
5. If `deployment.disableTLS=false`, set `deployment.tlsSecretName` to use your own certificate, or leave it empty to use the chart-managed self-signed secret.

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
| `deployment.tlsSecretName` | Custom TLS certificate, see [documentation](https://docs.safe.com/fme/html/FME-Flow/AdminGuide/Kubernetes/Kubernetes-Deploying-with-Custom-Certificate.htm) for more details. If not set, the chart will use a self-signed secret named `<release>-fmeremoteenginesservice-tls-selfsigned`. | `Nil` |
| `deployment.certManager.issuerName` | Cert Manager issuer name, see [documentation](https://docs.safe.com/fme/html/FME-Flow/AdminGuide/Kubernetes/Kubernetes-Deploying-with-Custom-Certificate.htm) for more details | `Nil` |
| `deployment.certManager.issuerType` | Can be `cluster` or `namespace`, ignored if no issuerName is provided. See [documentation](https://docs.safe.com/fme/html/FME-Flow/AdminGuide/Kubernetes/Kubernetes-Deploying-with-Custom-Certificate.htm) for more details | `cluster` |
| `deployment.startAsRoot` | Starts core container as root and grants the fmeflow user access to the file system. | `false` |
| `deployment.useHostnameIngress` | Configures the ingress to route traffic to FME Flow only if the request host matches `deployment.hostname`. When using official NGINX Ingress Controller, setting this to `false` is unsupported. | `true` |
| `deployment.ingress.useNginxMergeable` | Enables NGINX mergeable ingress resources (master/minion) when `deployment.useHostnameIngress=true`. Set this to `false` to disable mergeable mode or when using an ingress controller other than official NGINX. | `true` |
| `deployment.disableTLS` | Set this to `true` if you would like to disable TLS on the ingress. This is not recommended. | `false` |
| `resources.core` | [Core CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `1.5Gi`, CPU: `200m` |
| `resources.web` | [Web CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `1.5Gi`, CPU: `200m` |
| `resources.queue` | [Queue CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `64Mi`, CPU: `100m` |
| `resources.engine` | [Engine CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `4Gi`, CPU: `1000m` |
| `resources.database` | [Database CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `512Mi`, CPU: `200m` |
| `resources.dbinit` | [dbinit CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `128Mi`, CPU: `100m` |
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
| `deployment.ingress.ingressClassName` | `Ingress class name to use for ingress objects.` | `nginx` |
| `deployment.ingress.annotations` | `Annotations applied to ingress objects.` | `nginx.org/client-max-body-size: "0"`<br/>`nginx.org/proxy-read-timeout: "300s"` |
| `labels` | Labels to apply to the pod | `{}` |

## Development

### Run unit tests

1. `helm plugin install https://github.com/lrills/helm-unittest`
2. `helm unittest <path/to/chart/source>`

## Semantic Versioning

We follow the major.minor.patch versioning method (more details can be found on semver.org). Here is what each component means: 

### Major Version 

Major version refers to major, backward-incompatible changes.

### Minor Version

Minor version refers to back-compatible changes that does not break deploying earlier versions of FME Flow.

### Patch Version

Patch version refers to back-compatible bug fixes.
