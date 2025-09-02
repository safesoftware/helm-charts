# Official Safe Software Helm Charts

This repository houses the helm charts for deploying FME Flow and the FME Flow Remote Engine Service. The remainder of this readme is focussed on the FME Flow Helm chart. To see the readme for the Remote Engine Service, see its [Readme](./README-RemoteEngine.md)

## Important Notice: Bitnami PostgreSQL Chart Changes (August 28, 2025)

Note: Applies only to Helm chart versions < 2.5.0. From 2.5.0+, we use the official PostgreSQL image (no Bitnami dependency).

**Bitnami is making changes to their PostgreSQL Helm chart and container images, scheduled for August 28, 2025.** After this date, only the latest PostgreSQL image tag will be available on Docker Hub, and older tags will be removed. This will impact users who rely on specific image tags for PostgreSQL.

**What you need to do:**

1. **Switch to the legacy image repository:**
   - Set the image repository to `bitnamilegacy/postgresql` to continue using older tags.
2. **Allow image substitutions:**
   - The Bitnami chart will block deployment with image substitutions unless you set `global.security.allowInsecureImages=true`.

You can do both in one command:

```
helm install ... \
  --set postgresql.image.repository=bitnamilegacy/postgresql \
  --set global.security.allowInsecureImages=true \
  ...
```

Or in your `values.yaml`:

```yaml
global:
  security:
    allowInsecureImages: true
postgresql:
  image:
    repository: bitnamilegacy/postgresql
```

If you do not make these changes, your deployments may fail to pull or start the required PostgreSQL image after August 28, 2025.

For more details, see the [Bitnami announcement](https://github.com/bitnami/containers/issues/83267), [bitnamilegacy Docker Hub](https://hub.docker.com/r/bitnamilegacy/postgresql), and [Bitnami chart image verification documentation](https://github.com/bitnami/charts/issues/30850).

## Helm Chart Rename

Starting with FME Flow 2024.0, the helm chart has been renamed from having separate charts for each major release (e.g., `safesoftware/fmeserver-2023-1`, `safesoftware/fmeserver-2023-2`, etc) to having a single chart `safesoftware/fmeflow`.

This change is being made to make this repo less complex with so many versions of the chart. The new `fmeflow` chart will be made compatible with versions of FME Flow moving forward starting with 2024.0. If there are changes we need to make that will break backwards compatibility, we will increment the major version of this chart and will provide guidance to users on which versions of the chart to use with which versions of FME Flow. These types of changes should be very infrequent.

Along with the rename of the chart itself, everything in the chart has been renamed from `fmeserver` to `fmeflow`, including values specified in the values.yaml file.   
**Ensure that you update any existing values.yaml files you have to the new parameter names.**

Deploying with versions prior to 2024.0 should still use the old `fmeserver-<version>` charts.

## Helm Chart Versioning

Starting with 2024.1, we had to make some changes to the deployment that are not backwards compatible. This means that FME Flow 2024.0 should use version 1 of this chart, and 2024.1 and newer should use the latest version (version 2). This can be specified when calling `helm install` as follows:

<b>2024.0</b>: `helm install --version 1 ...`<br>
<b>2024.1+</b>: `helm install ...` or `helm install --version 2 ...` <br>

You can view all versions of the helm chart by running the command `helm search repo fmeflow --versions` after adding the repository. It is a good idea to make your deployments reproducible to pin an exact version of the helm chart when deploying and use the same version for any helm operations you need to perform on that deployment. You can pin a helm chart version with the `--version` flag. For example, `helm install --version 2.2.0 ...`

## Prerequisites

To add the Safe Software charts repository:  
`helm repo add safesoftware https://safesoftware.github.io/helm-charts/`

## Installing the Chart

To quickly get started, find the latest docker image tag for FME Flow [on Docker Hub](https://hub.docker.com/r/safesoftware/fmeflow-core/tags?name=2025.0). It is recommended to use a date-stamped tag from this list. For example: `2025.0-20250303`.

Then run the command specifying the docker tag found above:
`helm install fmeflow safesoftware/fmeflow --set fmeflow.image.tag=<docker_tag>`

See all available parameters below.

For more information see the [documentation](https://docs.safe.com/fme/html/FME_Server_Documentation/AdminGuide/Kubernetes/Kubernetes-Deploying-Intro.htm) and our [FME Community landing page for Kubernetes](https://community.safe.com/s/article/Getting-Started-with-FME-Server-and-Kubernetes).

## Configuration

The following table lists the configurable parameters of the FME Flow helm chart and their default values.

|      Parameter      |               Description             |                    Default                |
|---------------------|---------------------------------------|-------------------------------------------|
| `fmeflow.image.tag` | The docker image tag to use. |  `Nil` You must provide a tag. You can find available tags [here](https://hub.docker.com/r/safesoftware/fmeflow-core/tags?page=1&name=2025.0&ordering=last_updated). |
| `fmeflow.image.pullPolicy` | Image pull policy. IfNotPresent means that the image is pulled only if it is not already present on the node. If this is changed to "Always", then the node will always try to pull to make sure it has the latest version of that tag. | `IfNotPresent` |
| `fmeflow.image.registry` | Docker registry | `docker.io` This parameter should not be changed. |
| `fmeflow.image.namespace` | Docker registry namespace | `safesoftware` This parameter should not be changed. |
| `fmeflow.debugLevel` | Set the verbosity of the FME Flow Core logs. Can be set to NONE, LOW, MEDIUM, HIGH or SUPER_VERBOSE. | `NONE` |
| `deployment.hostname` | FME Flow hostname | `localhost` |
| `deployment.port` | FME Flow port | `443` |
| `deployment.tlsSecretName` | Custom TLS certificate, see [documentation](http://docs.safe.com/fme/2021.0/html/FME_Server_Documentation/AdminGuide/Kubernetes/Kubernetes-Deploying-with-Custom-Certificate.htm) for more details | `Nil` |
| `deployment.certManager.issuerName` | Cert Manager issuer name, see [documentation](http://docs.safe.com/fme/2021.0/html/FME_Server_Documentation/AdminGuide/Kubernetes/Kubernetes-Deploying-with-Custom-Certificate.htm) for more details | `Nil` |
| `deployment.certManager.issuerType` | Can be `cluster` or `namespace`, ignored if no issuerName is provided. See [documentation](http://docs.safe.com/fme/2021.0/html/FME_Server_Documentation/AdminGuide/Kubernetes/Kubernetes-Deploying-with-Custom-Certificate.htm) for more details | `cluster` |
| `deployment.numCores` | Number of cores to launch. Multi-core only works in a multi-host cluster with ReadWriteMany storage | `1` |
| `deployment.startAsRoot` | Starts core container as root and grants the fmeflow user access to the file system. | `false` |
| `deployment.useHostnameIngress` | Configures the ingress to route traffic to FME Flow only if the request matches the value of `deployment.hostname`. Setting this to false will route all traffic on the ingress to FME Flow. | `true` |
| `deployment.deployPostgresql` | Deploy a Postgresql Database for FME Flow to use. Set this to `false` if you have an existing database you would like FME Flow to connect to. | `true` |
| `deployment.disableTLS` | Set this to `true` if you would like to disable TLS on the ingress. This is not recommended. | `false` |
| `deployment.automountServiceAccountToken` | Set this to `true` if you would like to automatically mount the service token for the namespace. See [documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#opt-out-of-api-credential-automounting) for more details. | `false` |
| `resources.core` | [Core CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `1.5Gi`, CPU: `200m` |
| `resources.web` | [Web CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `1Gi`, CPU: `200m` |
| `resources.queue` | [Queue CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `128Mi`, CPU: `100m` |
| `resources.websocket` | [Websocket CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `256Mi`, CPU: `100m` |
| `resources.fmeutility` | [FMEUtility CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `1.5Gi`, CPU: `200m`|
| `resources.dbinit` | [dbinit CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `128Mi`, CPU: `100m` |
| `storage.reclaimPolicy` | [Volume Reclaim Policy](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaim-policy). Only required if useHostDir is enabled. | `Delete` |
| `storage.useHostDir` | Allows to map data and database volumes to a directory on a node. Requires path parameters. | `false` |
| `storage.postgresql.class` | Storage class for PostgreSQL data. Ignored if host dir mapping is used. | `Nil` |
| `storage.postgresql.size` | PostgreSQL volume size | `1Gi` |
| `storage.postgresql.path` | Absolute path where database data should be stored on host. Only required if useHostDir is enabled. | `Nil` |
| `storage.fmeflow.accessMode` | Access mode for FME Flow data storage class. | `ReadWriteOnce` |
| `storage.fmeflow.class` | Storage class for FME Flow data. Ignored if host dir mapping is used. | `Nil` |
| `storage.fmeflow.size` | FME Flow data volume size | `10Gi` |
| `storage.fmeflow.path` | Absolute path where FME Flow data should be stored on host. Only required if useHostDir is enabled. | `Nil` |
| `fmeflow.engines.debugLevel` | Set the verbosity of the FME Flow Engine logs. Can be set to NONE, LOW, MEDIUM, HIGH or SUPER_VERBOSE. | `NONE` |
| `fmeflow.engines.receiveTimeout` | Engines that have not received a job in this period of time (measured in milliseconds) will be restarted. Set to 0 to never restart. | `0` |
| `fmeflow.engines.groups` | An array of engine deployments. Each deployment defines a name, queues to join, number of replicas, and scheduling information. |  |
| `fmeflow.engines.groups[].name` | The name of this group of engines. | `default` |
| `fmeflow.engines.groups[].engines` | The number of engines to deploy in this engine deployment. | `2` |
| `fmeflow.engines.groups[].type` | The FME Engine licensing type to use. Must be STANDARD or DYNAMIC. | `STANDARD` |
| `fmeflow.engines.groups[].engineProperties` | A comma delimited list of properties to set on this engine. The engine deployment `name` will be automatically added. [See this link for more info](https://community.safe.com/s/article/FME-Server-on-Kubernetes-Utilizing-Engine-Assignment-and-Job-Routing) | `""` |
| `fmeflow.engines.groups[].resources` | [Engine CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `512Mi`, CPU: `200m` |
| `fmeflow.engines.groups[].memorylimit.top` | Tell the FME Engine the percentage of available memory to use. Only set this if a memory limit is being set for this engine group. Must be a float between 0.0 and 1.0 and greater than `memorylimit.bottom`. Note this parameter is set automatically when a memory limit is set for an engine. Use these parameters to override. |  |
| `fmeflow.engines.groups[].memorylimit.bottom` | Tell the FME Engine the percentage of available memory to use. Only set this if a memory limit is being set for this engine group. Must be a float between 0.0 and 1.0 and less than `memorylimit.top`. Note this parameter is set automatically when a memory limit is set for an engine. Use these parameters to override. |  |
| `fmeflow.engines.groups[].affinity` | Affinity labels for pod assignment for this engine deployment | `{}` |
| `fmeflow.engines.groups[].nodeSelector` | Map of nodeselector annotations to add to this engine deployment | `{}` |
| `fmeflow.engines.groups[].tolerations` | Toleration labels for pod assignment for this engine deployment | `[]` |
| `fmeflow.engines.groups[].labels` | Labels to apply to the engine pods | `{}` |
| `fmeflow.engines.awsServiceAccount.iamRoleArn` | `IAM Role to associate with the FME Engine pods (this will create a service account for FME Engine to access AWS)` | `Nil` |
| `fmeflow.engines.groups[].image` | Changes the image that the engine uses. Defaults to the image set in the `fmeflow.image` settings if not set. | |
| `fmeflow.engines.groups[].image.tag` | The docker image tag to use. |  |
| `fmeflow.engines.groups[].image.pullPolicy` | Image pull policy. IfNotPresent means that the image is pulled only if it is not already present on the node. If this is changed to "Always", then the node will always try to pull to make sure it has the latest version of that tag. |  |
| `fmeflow.engines.groups[].image.registry` | Docker registry |  |
| `fmeflow.engines.groups[].image.namespace` | Docker registry namespace |  |
| `fmeflow.database.host` | The hostname of the Postgres database to use. Only set this if you are not using the included Postgres database |  _The service DNS of the Postgresql database deployed with this chart_ |
| `fmeflow.database.port` | The port of the Postgres database to use. |  `5432` |
| `fmeflow.database.name` | The database name for FME Flow to use for its schema. |  `fmeflow` |
| `fmeflow.database.user` | The database user for FME Flow to use/create. |  `fmeflow` |
| `fmeflow.database.password` | The database password for the fmeflow user. | `4fmmsgrz09` |
| `fmeflow.database.passwordSecret` | Instead of specifying a database password in plaintext, specify an existing secret that contains the password to use. |  |
| `fmeflow.database.passwordSecretKey` | The key in the above specified secret that contains the fmeflow database password. |  `fmeflow-db-password` |
| `fmeflow.database.adminUser` | The admin database user for FME Flow to use to create its schema in the database. |  `postgres` |
| `fmeflow.database.adminPasswordSecret` | The name of the secret that contains the password of the admin user specified in `fmeflow.database.adminUser` |  _Secret generated by the Postgresql chart_ |
| `fmeflow.database.adminPasswordSecretKey` | The key in the specified `fmeflow.database.adminPasswordSecret` that contains the password for the admin user specified in `fmeflow.database.adminUser` |  `postgres-password` |
| `fmeflow.database.adminDatabase` | The admin database to use when connecting with the adminUser. |  `postgres` |
| `fmeflow.database.ssl` | Adds `sslmode=require` to the JDBC connections to the database |  `false` |
| `fmeflow.database.azure` | NOTE: This flag is needed for Azure Database for PostgreSQL Single Server, which is being retired from Azure at the end of March 2025, and is no longer needed for the newer Azure PosgreSQL Flexible Servers. (more info [here](https://azure.microsoft.com/en-us/updates?id=azure-database-for-postgresql-single-server-will-be-retired-migrate-to-flexible-server-by-28-march-2025)) Set this to `true` only if connecting to an Azure Managed Postgresql Single Server database to format the username properly when connecting. |  `false` |
| `fmeflow.webserver.maxThreads` | Max threads the Tomcat webserver can use (more info [here](https://tomcat.apache.org/tomcat-8.0-doc/config/http.html)) | 200 |
| `fmeflow.forcePasswordChange` | Force the admin user to change password on first login | `true` |
| `fmeflow.enableTransactionQueueTimeout` | Enable timeout on queue connections. | `false` |
| `fmeflow.portpool` | Range of ports which can be assigned to FME Engines, Subscribers and Protocols when connecting to FME Flow. Port pools may be specified as a comma-seperated list of port numbers and port number ranges. E.g. 20000-21000,21200 | `Nil` |
| `fmeflow.waitForDatabase` | Wait until the database is up and can be connected to before starting FME Flow Core and Engines. Only disable this if this check is causing issues.  | `true` |
| `fmeflow.waitForQueue` | Wait until the redis queue is up and can be connected to before starting FME Flow Core. Only disable this if this check is causing issues.  | `true` |
| `fmeflow.healthcheck.startup.initialDelaySeconds` | Set the initial delay before running the startup probes. | `10` |
| `fmeflow.healthcheck.startup.failureThreshold` | Set the failure threshold for the startup probes. This can be increased if pods take longer to start in your cluster. | `20` |
| `fmeflow.healthcheck.startup.timeoutSeconds` | Set the timeout for the the startup probes. | `5` |
| `fmeflow.healthcheck.startup.periodSeconds` | Set the time (in seconds) between startup probe invocations. This can be increased if pods take longer to start in your cluster. | `30` |
| `scheduling.core.affinity` | Affinity labels for pod assignment for Core pod. For information on how to assign pods to specific nodes using the affinity feature, read the [official documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/). | `{}` |
| `scheduling.core.nodeselector` | Map of nodeselector annotations to add to the Core pod. For information on how to assign pods to specific nodes using the nodeSelector parameter, read the [official documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/). | `{}` |
| `scheduling.core.tolerations` | Toleration labels for pod assignment for Core pod. [Official documentation](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) on taints and tolerations. | `[]` |
| `scheduling.queue.affinity` | Affinity labels for pod assignment for Queue pod. For information on how to assign pods to specific nodes using the affinity feature, read the [official documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/). | `{}` |
| `scheduling.queue.nodeselector` | Map of nodeselector annotations to add to the Queue pod. For information on how to assign pods to specific nodes using the nodeSelector parameter, read the [official documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/). | `{}` |
| `scheduling.queue.tolerations` | Toleration labels for pod assignment for Queue pod. [Official documentation](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) on taints and tolerations. | `[]` |
| `scheduling.websocket.affinity` | Affinity labels for pod assignment for Websocket pod. For information on how to assign pods to specific nodes using the affinity feature, read the [official documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/). | `{}` |
| `scheduling.websocket.nodeselector` | Map of nodeselector  annotations to add to the Websocket pod. For information on how to assign pods to specific nodes using the nodeSelector parameter, read the [official documentation](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/). | `{}` |
| `scheduling.websocket.tolerations` | Toleration labels for pod assignment for Websocket pod. [Official documentation](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) on taints ansd tolerations. | `[]` |
| `annotations.core.statefulset` | `Annotations for the core statefulset` | `{}` |
| `annotations.core.template` | `Annotations for the core pod template` | `{}` |
| `annotations.engine.deployment` | `Annotations for the engine deployment` | `{}` |
| `annotations.engine.template` | `Annotations for the engine pod template` | `{}` |
| `annotations.queue.statefulset` | `Annotations for the queue statefulset` | `{}` |
| `annotations.queue.template` | `Annotations for the queue pod template` | `{}` |
| `annotations.websocket.statefulset` | `Annotations for the websocket statefulset` | `{}` |
| `annotations.websocket.template` | `Annotations for the websocket pod template` | `{}` |
| `ingress.general.ingressClassName` | `Ingress class name to use for ingress objects.` | `nginx` |
| `ingress.general.annotations` | `Annotations to apply to all ingress objects.` | `nginx.ingress.kubernetes.io/proxy-body-size: "0"`<br/>`nginx.ingress.kubernetes.io/affinity: cookie`<br/>`nginx.ingress.kubernetes.io/session-cookie-name: fmeflow-ingress`<br/>`nginx.ingress.kubernetes.io/session-cookie-hash: md5` |
| `ingress.web.annotations` | `Annotations to apply to the default web ingress` | `nginx.ingress.kubernetes.io/proxy-read-timeout: "300"`<br/>`nginx.ingress.kubernetes.io/proxy-body-size: "0"` |
| `ingress.migration.annotations` | `Annotations to apply to the migration REST endpoint ingress. Typically a longer timeout is set for large backup and restore REST calls.` | `nginx.ingress.kubernetes.io/proxy-read-timeout: "1800"` |
| `ingress.transact.annotations` | `Annotations to apply to the transact REST endpoint ingress. Typically a long timeout is set for synchronous calls to execute long running jobs.` | `nginx.ingress.kubernetes.io/proxy-read-timeout: "1209600"` |
| `ingress.websocket.annotations` | `Annotations to apply to the websocket REST endpoint ingress. Typically a long timeout is set for long open websocket connections.` | `nginx.ingress.kubernetes.io/proxy-read-timeout: "2592000"` |
| `labels.core` | Labels to apply to the core pods | `{}` |
| `labels.queue` | Labels to apply to the core pods | `{}` |
| `labels.websocket` | Labels to apply to the core pods | `{}` |
| `additionalStorage` | An array of additional volumes to mount into the Core, Web and Engine pods. This can be useful when needing to store data in a different volume from the system share, or if you wanted to share data with other things running in your cluster. Unless `existingClaim` is used, this will create a new persistentVolumeClaim which depending on your storage class will likely create an empty volume for you to use. | `[]`|
| `additionalStorage[].name` | The name of the volume. This will be used as the claim name and volume name. | `Nil` |
| `additionalStorage[].mountPath` | The path inside of the containers to mount the volume. This will be identical in the pods it is mounted in. | `Nil` |
| `additionalStorage[].accessMode` | Access mode for the storage. This should be ReadWriteMany if your pods will be deployed across multiple nodes. | `Nil` |
| `additionalStorage[].size` | Volume size. | `Nil` |
| `additionalStorage[].class` | Storage class for the volume. | `Nil` |
| `additionalStorage[].existingClaim` | Name of an existing PersistentVolumeClaim to use. This is useful if you want to mount an existing volume mounted inside another app in the cluster. Specifying this will set the `claimName` to this and will not create a new persistent volume claim. | `Nil` |
| `additionalStorage[].useHostDir` | Create the volume in a directory on the node instead of using a storage class. | `Nil` |
| `additionalStorage[].path` | Absolute path where data should be stored on host. Only required if useHostDir is enabled. | `Nil` |
| `additionalStorage[].reclaimPolicy` | [Volume Reclaim Policy](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaim-policy). Only required if useHostDir is enabled. | `Nil` |

## Development

### Run unit tests

1. `helm plugin install https://github.com/lrills/helm-unittest`
2. `helm unittest <path/to/chart/source>`

## Third Party Dependancies
PostgreSQL Helm Chart  - Apache 2.0 - Available from [Bitnami](https://github.com/bitnami/charts/tree/master/bitnami/postgresql).
