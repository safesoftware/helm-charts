# Official Safe Software Helm Charts

## Prerequisites

To add the Safe Software charts repository:  
`helm repo add safesoftware https://safesoftware.github.io/helm-charts/`

## Installing the Chart

To quickly get started, find the latest docker image tag for this version of FME Server [here](https://hub.docker.com/r/safesoftware/fmeserver-core/tags?page=1&name=2023.1&ordering=last_updated).

Then run the command specifying the docker tag found above:
`helm install fmeserver safesoftware/fmeserver-2023-1 --set fmeserver.image.tag=<docker_tag>`

See all available parameters below.

For more information see the [documentation](https://docs.safe.com/fme/html/FME_Server_Documentation/AdminGuide/Kubernetes/Kubernetes-Deploying-Intro.htm) and our [FME Community landing page for Kubernetes](https://community.safe.com/s/article/Getting-Started-with-FME-Server-and-Kubernetes).

## Configuration

NOTE: starting in 2023.1, ingress class name is now set using `ingress.general.ingressClassName`

The following table lists the configurable parameters of the FME Server 2023.1 chart and their default values.

|      Parameter      |               Description             |                    Default                |
|---------------------|---------------------------------------|-------------------------------------------|
| `fmeserver.image.tag` | The docker image tag to use. |  `Nil` You must provide a tag. You can find available tags [here](https://hub.docker.com/r/safesoftware/fmeserver-core/tags?page=1&name=2023.0&ordering=last_updated). |
| `fmeserver.image.pullPolicy` | Image pull policy. IfNotPresent means that the image is pulled only if it is not already present on the node. If this is changed to "Always", then the node will always try to pull to make sure it has the latest version of that tag. | `IfNotPresent` |
| `fmeserver.image.registry` | Docker registry | `docker.io` This parameter should not be changed. |
| `fmeserver.image.namespace` | Docker registry namespace | `safesoftware` This parameter should not be changed. |
| `fmeserver.debugLevel` | Set the verbosity of the FME Server Core logs. Can be set to NONE, LOW, MEDIUM, HIGH or SUPER_VERBOSE. | `NONE` |
| `deployment.hostname` | FME Server hostname | `localhost` |
| `deployment.port` | FME Server port | `443` |
| `deployment.tlsSecretName` | Custom TLS certificate, see [documentation](http://docs.safe.com/fme/2021.0/html/FME_Server_Documentation/AdminGuide/Kubernetes/Kubernetes-Deploying-with-Custom-Certificate.htm) for more details | `Nil` |
| `deployment.certManager.issuerName` | Cert Manager issuer name, see [documentation](http://docs.safe.com/fme/2021.0/html/FME_Server_Documentation/AdminGuide/Kubernetes/Kubernetes-Deploying-with-Custom-Certificate.htm) for more details | `Nil` |
| `deployment.certManager.issuerType` | Can be `cluster` or `namespace`, ignored if no issuerName is provided. See [documentation](http://docs.safe.com/fme/2021.0/html/FME_Server_Documentation/AdminGuide/Kubernetes/Kubernetes-Deploying-with-Custom-Certificate.htm) for more details | `cluster` |
| `deployment.numCores` | Number of cores to launch. Multi-core only works in a multi-host cluster with ReadWriteMany storage | `1` |
| `deployment.startAsRoot` | Starts core container as root and grants the fmeserver user access to the file system. | `false` |
| `deployment.useHostnameIngress` | Configures the ingress to route traffic to FME Server only if the request matches the value of `deployment.hostname`. Setting this to false will route all traffic on the ingress to FME Server. | `true` |
| `deployment.deployPostgresql` | Deploy a Postgresql Database for FME Server to use. Set this to `false` if you have an existing database you would like FME Server to connect to. | `true` |
| `deployment.disableTLS` | Set this to `true` if you would like to disable TLS on the ingress. This is not recommended. | `false` |
| `resources.core` | [Core CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `1.5Gi`, CPU: `200m` |
| `resources.web` | [Web CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `1Gi`, CPU: `200m` |
| `resources.queue` | [Queue CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `128Mi`, CPU: `100m` |
| `resources.websocket` | [Websocket CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `256Mi`, CPU: `100m` |
| `storage.reclaimPolicy` | [Volume Reclaim Policy](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaim-policy) | `Delete` |
| `storage.useHostDir` | Allows to map data and database volumes to a directory on a node. Requires path parameters. | `false` |
| `storage.postgresql.class` | Storage class for PostgreSQL data. Ignored if host dir mapping is used. | `Nil` |
| `storage.postgresql.size` | PostgreSQL volume size | `1Gi` |
| `storage.postgresql.path` | Absolute path where database data should be stored on host. Only required if useHostDir is enabled. | `Nil` |
| `storage.fmeserver.accessMode` | Access mode for FME Server data storage class. | `ReadWriteOnce` |
| `storage.fmeserver.class` | Storage class for FME Server data. Ignored if host dir mapping is used. | `Nil` |
| `storage.fmeserver.size` | FME Server data volume size | `10Gi` |
| `storage.fmeserver.path` | Absolute path where FME Server data should be stored on host. Only required if useHostDir is enabled. | `Nil` |
| `fmeserver.engines.debugLevel` | Set the verbosity of the FME Server Engine logs. Can be set to NONE, LOW, MEDIUM, HIGH or SUPER_VERBOSE. | `NONE` |
| `fmeserver.engines.receiveTimeout` | Engines that have not received a job in this period of time (measured in milliseconds) will be restarted. Set to 0 to never restart. | `0` |
| `fmeserver.engines.groups` | An array of engine deployments. Each deployment defines a name, queues to join, number of replicas, and scheduling information. |  |
| `fmeserver.engines.groups[].name` | The name of this group of engines. | `default` |
| `fmeserver.engines.groups[].engines` | The number of engines to deploy in this engine deployment. | `2` |
| `fmeserver.engines.groups[].type` | The FME Engine licensing type to use. Must be STANDARD or DYNAMIC. | `STANDARD` |
| `fmeserver.engines.groups[].engineProperties` | A comma delimited list of properties to set on this engine. The engine deployment `name` will be automatically added. [See this link for more info](https://community.safe.com/s/article/FME-Server-on-Kubernetes-Utilizing-Engine-Assignment-and-Job-Routing) | `""` |
| `fmeserver.engines.groups[].queues` | **DEPRECATED:** This parameter is deprecated. Assigning engines to queues is now done in the Web UI using engine properties. [See this link for more info](https://community.safe.com/s/article/FME-Server-on-Kubernetes-Utilizing-Engine-Assignment-and-Job-Routing) <br /><br /> The queues that the engines in this deployment should join. This is a comma delimited list of queues and optionally priorities for those queues of the form `<QueueName>[:<QueuePriority>],<QueueName>[:<QueuePriority>],...`. The default priority is 100. For example: `Queue1:100,Queue2:200,Queue3:1` or `Queue1,Queue4,Queue5` | `""` |
| `fmeserver.engines.groups[].resources` | [Engine CPU/Memory resource requests/limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) | Memory: `512Mi`, CPU: `200m` |
| `fmeserver.engines.groups[].memorylimit.top` | Tell the FME Engine the percentage of available memory to use. Only set this if a memory limit is being set for this engine group. Must be a float between 0.0 and 1.0 and greater than `memorylimit.bottom`. Note this parameter is set automatically when a memory limit is set for an engine. Use these parameters to override. |  |
| `fmeserver.engines.groups[].memorylimit.bottom` | Tell the FME Engine the percentage of available memory to use. Only set this if a memory limit is being set for this engine group. Must be a float between 0.0 and 1.0 and less than `memorylimit.top`. Note this parameter is set automatically when a memory limit is set for an engine. Use these parameters to override. |  |
| `fmeserver.engines.groups[].affinity` | Affinity labels for pod assignment for this engine deployment | `{}` |
| `fmeserver.engines.groups[].nodeSelector` | Map of nodeselector annotations to add to this engine deployment | `{}` |
| `fmeserver.engines.groups[].tolerations` | Toleration labels for pod assignment for this engine deployment | `[]` |
| `fmeserver.engines.groups[].labels` | Labels to apply to the engine pods | `{}` |
| `fmeserver.engines.awsServiceAccount.iamRoleArn` | `IAM Role to associate with the FME Engine pods (this will create a service account for FME Engine to access AWS)` | `Nil` |
| `fmeserver.engines.groups[].image` | Changes the image that the engine uses. Defaults to the image set in the `fmeserver.image` settings if not set. | |
| `fmeserver.engines.groups[].image.tag` | The docker image tag to use. |  |
| `fmeserver.engines.groups[].image.pullPolicy` | Image pull policy. IfNotPresent means that the image is pulled only if it is not already present on the node. If this is changed to "Always", then the node will always try to pull to make sure it has the latest version of that tag. |  |
| `fmeserver.engines.groups[].image.registry` | Docker registry |  |
| `fmeserver.engines.groups[].image.namespace` | Docker registry namespace |  |
| `fmeserver.database.host` | The hostname of the Postgres database to use. Only set this if you are not using the included Postgres database |  _The service DNS of the Postgresql database deployed with this chart_ |
| `fmeserver.database.port` | The port of the Postgres database to use. |  `5432` |
| `fmeserver.database.name` | The database name for FME Server to use for its schema. |  `fmeserver` |
| `fmeserver.database.user` | The database user for FME Server to use/create. |  `fmeserver` |
| `fmeserver.database.password` | The database password for the fmeserver user. | `4fmmsgrz09` |
| `fmeserver.database.passwordSecret` | Instead of specifying a database password in plaintext, specify an existing secret that contains the password to use. |  |
| `fmeserver.database.passwordSecretKey` | The key in the above specified secret that contains the fmeserver database password. |  `fmeserver-db-password` |
| `fmeserver.database.adminUser` | The admin database user for FME Server to use to create its schema in the database. |  `postgres` |
| `fmeserver.database.adminPasswordSecret` | The name of the secret that contains the password of the admin user specified in `fmeserver.database.adminUser` |  _Secret generated by the Postgresql chart_ |
| `fmeserver.database.adminPasswordSecretKey` | The key in the specified `fmeserver.database.adminPasswordSecret` that contains the password for the admin user specified in `fmeserver.database.adminUser` |  `postgres-password` |
| `fmeserver.database.adminDatabase` | The admin database to use when connecting with the adminUser. |  `postgres` |
| `fmeserver.database.ssl` | Adds `sslmode=require` to the JDBC connections to the database |  `false` |
| `fmeserver.database.azure` | Set this to `true` if connecting to an Azure Managed Postgresql database to format the username properly when connecting. |  `false` |
| `fmeserver.webserver.maxThreads` | Max threads the Tomcat webserver can use (more info [here](https://tomcat.apache.org/tomcat-8.0-doc/config/http.html)) | 200 |
| `fmeserver.forcePasswordChange` | Force the admin user to change password on first login | `true` |
| `fmeserver.enableTransactionQueueTimeout` | Enable timeout on queue connections. | `false` |
| `fmeserver.portpool` | Range of ports which can be assigned to FME Engines, Subscribers and Protocols when connecting to the FME Server. Port pools may be specified as a comma-seperated list of port numbers and port number ranges. E.g. 20000-21000,21200 | `Nil` |
| `fmeserver.healthcheck.liveness.initialDelaySeconds` | Set the initial delay before running the liveness probes. Increase this if pods take longer to start in your cluster. | `60` |
| `fmeserver.healthcheck.readiness.initialDelaySeconds` | Set the initial delay before running the readiness probes. Increase this if pods take longer to start in your cluster. | `60` |
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
| `ingress.general.annotations` | `Annotations to apply to all ingress objects.` | `nginx.ingress.kubernetes.io/proxy-body-size: "0"`<br/>`nginx.ingress.kubernetes.io/affinity: cookie`<br/>`nginx.ingress.kubernetes.io/session-cookie-name: fmeserver-ingress`<br/>`nginx.ingress.kubernetes.io/session-cookie-hash: md5` |
| `ingress.web.annotations` | `Annotations to apply to the default web ingress` | `nginx.ingress.kubernetes.io/proxy-read-timeout: "300"`<br/>`nginx.ingress.kubernetes.io/proxy-body-size: "0"` |
| `ingress.migration.annotations` | `Annotations to apply to the migration REST endpoint ingress. Typically a longer timeout is set for large backup and restore REST calls.` | `nginx.ingress.kubernetes.io/proxy-read-timeout: "1800"` |
| `ingress.transact.annotations` | `Annotations to apply to the transact REST endpoint ingress. Typically a long timeout is set for synchronous calls to execute long running jobs.` | `nginx.ingress.kubernetes.io/proxy-read-timeout: "1209600"` |
| `ingress.websocket.annotations` | `Annotations to apply to the websocket REST endpoint ingress. Typically a long timeout is set for long open websocket connections.` | `nginx.ingress.kubernetes.io/proxy-read-timeout: "2592000"` |
| `labels.core` | Labels to apply to the core pods | `{}` |
| `labels.queue` | Labels to apply to the core pods | `{}` |
| `labels.websocket` | Labels to apply to the core pods | `{}` |

## Development

### Run unit tests

1. `helm plugin install https://github.com/lrills/helm-unittest`
2. `helm unittest <path/to/chart/source>`

## Third Party Dependancies
PostgreSQL Helm Chart  - Apache 2.0 - Available from [Bitnami](https://github.com/bitnami/charts/tree/master/bitnami/postgresql).
