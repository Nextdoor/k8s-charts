# simple-app

Default Microservice Helm Chart

![Version: 0.20.1](https://img.shields.io/badge/Version-0.20.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

[deployments]: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
[hpa]: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

This chart provides a default deployment for a simple application that operates
in a [Deployment][deployments]. The chart automatically configures various
defaults for you like the Kubernetes [Horizontal Pod Autoscaler][hpa].

## Upgrade Notes

### 0.19.x -> 0.20.x

**Default Replica Count is now 2!**

In order to make sure that even our staging/development deployments have some
guarantees of uptime, the defaults for the chart have changed. We now set
`replicaCount: 2` and create a `podDisruptionBudget` by default. This ensures
that a developer needs to _intentionally_ disable these settings in order to
create a single-pod deployment.

### 0.18.x -> 0.19.x

**Automatic NodeSelectors**

By default the chart now sets the `kubernetes.io/os` and `kubernetes.io/arch`
values in the `nodeSelector` field for your pods! The default values are
targeted towards our most common deployment environments - `linux` on `amd64`
hosts. Pay close attention to the `targetOperatingSystem` and
`targetArchitecture` values to customize this behavior.

### 0.17.x -> 0.18.x

**New Feature: Secrets Management**

You can now manage `Secret` and `KMSSecret` Resources through `Values.secrets`.
See the [Secrets](#secrets) section below for details on how secrets work.

### 0.16.x -> 0.17.x

**New Feature: Customize User-Facing Ports**

You can now expose a custom port for your users (eg: `80`) while your service
continues to listen on a private containerPort (eg: `5000`). In the maps in
`.Values.ports` simply add a `port: <int>` key and the `Service` resource
will be reconfigured to route that port to the backend container port.

**Bug Fix: ServiceMonitor resources were broken**

Previously the `ServiceMonitor` resources were pointing to the `Service` but
the `Service` did not expose a `metrics` endpoint, which caused the resource to
be invalid. This has been fixed.

## Monitoring

This chart makes the assumption that you _do_ have a Prometheus-style
monitoring endpoint configured. See the `Values.monitor.portName`,
`Values.monitor.portNumber` and `Values.monitor.path` settings for informing
the chart of where your metrics are exposed.

If you are operating in an Istio Service Mesh, see the
[Istio](#istio-networking-support) section below for details on how monitoring
works. Otherwise, see the `Values.serviceMonitor` settings to configure a
Prometheus ServiceMonitor resource to monitor your application.

## Datadog Agent Support

This chart supports operating in environments where the Datadog Agent is
running. If you set the `Values.datadog.enabled` flag, then a series of
additional Pod Annotations, Labels and Environment Variables will be
automatically added in to your deployment. See the `Values.datadog` parameters
for further information.

## Istio Networking Support

### Monitoring through the Sidecar Proxy

[metrics_merging]: https://istio.io/latest/docs/ops/integrations/prometheus/#option-1-metrics-merging

When running your Pod within an Istio Mesh, access to the `metrics` endpoint
for your Pod can be obscured by the mesh itself which sits in front of the
metrics port and may require that all clients are coming in through the
mesh natively. The simplest way around this is to use [Istio Metrics
Merging][metrics_merging] - where the Sidecar container is responsible for
scraping your application's `metrics` port, merging the metrics with its own,
and then Prometheus is configured to pull all of the metrics from the Sidecar.

There are several advantages to this model.

* It's much simpler - developers do not need to create `ServiceMonitor` or
  `PodMonitor` resources because the Prometheus system is already configured to
  discover all `istio-proxy` sidecar containers and collect their metrics.

* Your application is not exposed outside of the service mesh to anybody - the
  `istio-proxy` sidecar handles that for you.

* There are fewer individual configurations for Prometheus, letting it's
  configuration be simpler and lighter weight. It runs fewer "scrape" jobs,
  improving its overall performance.

This feature is turned on by default if you set `Values.istio.enabled=true` and
`Values.monitor.enabled=true`.

## Secrets
A `Secret` or `KMSSecret` resource would be created and mounted into the container
based upon the `Values.secrets` and `Values.secretsEngine` being populated.
The `Secret` resource is generally used for local dev and/or CI test.
Secret` resources can be created by setting the following:
```
secrets:
  FOO_BAR: my plaintext secret
secretsEngine: plaintext
```
Alternatively, `KMSSecret` can be generated using the following example:
```
secrets:
  FOO_BAR: AQIA...
secretsEngine: kms
kmsSecretsRegion: us-west-2 (AWS region where the KMS key is located)
```

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../nd-common | nd-common | 0.0.2 |
| https://k8s-charts.nextdoor.com | istio-alerts | 0.1.3 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| args | list | `[]` | The arguments passed to the command. If unspecified the container defaults are used. The exact rules of how commadn and args are interpreted can be # found at: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/ |
| autoscaling.enabled | bool | `false` | Controls whether or not an HorizontalPodAutoscaler resource is created. |
| autoscaling.maxReplicas | int | `100` | Sets the maximum number of Pods to run |
| autoscaling.minReplicas | int | `1` | Sets the minimum number of Pods to run |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Configures the HPA to target a particular CPU utilization percentage |
| command | list | `[]` | The command run by the container. This overrides `ENTRYPOINT`. If not specified, the container's default entrypoint is used. The exact rules of how commadn and args are interpreted can be # found at: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/ |
| datadog.enabled | bool | `true` | (`bool`) Whether or not the various datadog labels and options should be included or not. |
| datadog.env | `string` | `nil` | The "env" tag to configure for the application - this maps to the Datadog environment concept for isolating traces/apm data. If you do not set this, then no `DD_ENV` variable is set, and the underlying Datadog Agent will set that value. |
| datadog.metricsNamespace | string | `"eks"` | (`string`) The prefix to append to all metrics that are scraped by Datadog. We set this to one common value so that common metrics (like `istio_.*` or `go_.*`) are shared across all apps in Datadog for easier dashboard creation as well as comparision between applications. |
| datadog.metricsToScrape | list | `["\"*\""]` | (`strings[]`) A list of strings that match the metric names that Datadog should scrape from the endpoint. This defaults to `"*"` to tell it to scrape ALL metrics - however, if your app exposes too many metrics (> 2000), Datadog will drop them all on the ground. |
| datadog.scrapeMetrics | bool | `false` | (`bool`) If true, then we will configure the Datadog agent to scrape metrics from the Pod (or the `istio-proxy` sidecar). |
| datadog.service | `string` | `nil` | If set, this configures the "service" tag. If this is not set, the tag defaults to the `.Release.Name` for the application. |
| deploymentStrategy | object | `{}` | https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy |
| env | list | `[]` | Environment Variables for the primary container. These are all run through the tpl function (the key name and value), so you can dynamically name resources as you need. |
| envFrom | list | `[]` | Pull all of the environment variables listed in a ConfigMap into the Pod. See https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#configure-all-key-value-pairs-in-a-configmap-as-container-environment-variables for more details. |
| fullnameOverride | string | `""` |  |
| image.forceTag | String | `nil` | Forcefully overrides the `image.tag` setting - this is useful if you have an outside too that automatically updates the `image.tag` value, but you want your application operators to be able to squash that override themselves. |
| image.pullPolicy | string | `"IfNotPresent"` | (String) Always, Never or IfNotPresent |
| image.repository | string | `"nginx"` | (String) The Docker image name and repository for your application |
| image.tag | String | `nil` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Supply a reference to a Secret that can be used by Kubernetes to pull down the Docker image. This is only used in local development, in combination with our `kube_create_ecr_creds` function from dotfiles. |
| ingress.annotations | object | `{}` | Any annotations you wish to add to the ALB. See https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/ for more details. |
| ingress.enabled | bool | `false` |  |
| ingress.host | string | `"{{ include \"simple-app.fullname\" . }}.{{ .Release.Namespace }}"` | This setting configures the ALB to listen specifically to requests for this hostname. It _also_ ties into the external-dns controller and automatically provisions DNS hostnames matching this value (presuming that they are allowed by the cluster settings). |
| ingress.path | string | `"/"` | See the `ingress.pathType` setting documentation. |
| ingress.pathType | string | `"Prefix"` | https://kubernetes.io/docs/concepts/services-networking/ingress/#path-types |
| ingress.port | string | `nil` | If set, this will override the `service.portName` parameter, and the `Service` object will point specifically to this port number on the backing Pods. |
| ingress.portName | string | `"http"` | This is the port "name" that the `Service` will point to on the backing Pods. This value must match one of the values of `.name` in the `Values.ports` configuration. |
| ingress.sslRedirect | bool | `true` | If `true`, then this will annotate the Ingress with a special AWS ALB Ingress Controller annotation that configures an SSL-redirect at the ALB level. |
| istio-alerts.enabled | bool | `true` | (`bool`) Whether or not to enable the istio-alerts chart. |
| istio.enabled | bool | `false` | (`bool`) Whether or not the service should be part of an Istio Service Mesh. If this is turned on and `Values.monitor.enabled=true`, then the Istio Sidecar containers will be configured to pull and merge the metrics from the application, rather than creating a new `ServiceMonitor` object. |
| istio.preStopCommand | `list <str>` | `nil` | If supplied, this is the command that will be passed into the `istio-proxy` sidecar container as a pre-stop function. This is used to delay the shutdown of the istio-proxy sidecar in some way or another. Our own default behavior is applied if this value is not set - which is that the sidecar will wait until it does not see the application container listening on any TCP ports, and then it will shut down. eg: preStopCommand: [ /bin/sleep, "30" ] |
| kmsSecretsRegion | String | `nil` | AWS region where the KMS key is located |
| livenessProbe | object | `{"httpGet":{"path":"/","port":"http"}}` | A PodSpec container "livenessProbe" configuration object. Note that this livenessProbe will be applied to the proxySidecar container instead if that is enabled. |
| minReadySeconds | string | `nil` | https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#min-ready-seconds |
| monitor.enabled | bool | `true` | (`bool`) If enabled, ServiceMonitor resources for Prometheus Operator are created or if `Values.istio.enabled` is `True`, then the appropriate Pod Annotations will be added for the istio-proxy sidecar container to scrape the metrics. |
| monitor.path | string | `"/metrics"` | (`string`) Path to scrape metrics from within your Pod. |
| monitor.portName | string | `"metrics"` | (`string`) Name of the port to scrape for metrics - this is the name of the port that will be exposed in your `PodSpec` for scraping purposes. |
| monitor.portNumber | int | `9090` | (`int`) Number of the port to scrape for metrics - this port will be exposed in your `PodSpec` to ensure it can be scraped. |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` | (`map`) A list of key/value pairs that will be added in to the nodeSelector spec for the pods. |
| podAnnotations | object | `{}` | (`Map`) List of Annotations to be added to the PodSpec |
| podDisruptionBudget | object | `{"maxUnavailable":1}` | Set up a PodDisruptionBudget for the Deployment. See https://kubernetes.io/docs/tasks/run-application/configure-pdb/ for more details. |
| podLabels | object | `{}` | (`Map`) List of Labels to be added to the PodSpec |
| podSecurityContext | object | `{}` |  |
| ports | list | `[{"containerPort":80,"name":"http","port":null,"protocol":"TCP"}]` | (`ContainerPort[]`) A list of Port objects that are exposed by the service. These ports are applied to the main container, or the proxySidecar container (if enabled). The port list is also used to generate Network Policies that allow ingress into the pods. See https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.21/#containerport-v1-core for details. **Note: We have added an optional "port" field to this list that allows the user to override the Service Port (for example 80) that a client  connects to, without altering the Container Port (say, 8080) that is listening for connections. |
| preStopCommand | list | `["/bin/sleep","10"]` | Before a pod gets terminated, Kubernetes sends a SIGTERM signal to every container and waits for period of time (10s by default) for all containers to exit gracefully. If your app doesn't handle the SIGTERM signal or if it doesn't exit within the grace period, Kubernetes will kill the container and any inflight requests that your app is processing will fail. Make sure you set this to SHORTER than the terminationGracePeriod (30s default) setting. https://docs.flagger.app/tutorials/zero-downtime-deployments#graceful-shutdown |
| progressDeadlineSeconds | string | `nil` | https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#progress-deadline-seconds |
| prometheusRules.CPUThrottlingHigh | object | `{"for":"15m","severity":"warning","threshold":65}` | Container is being throttled by the CGroup - needs more resources. |
| prometheusRules.ContainerWaiting | object | `{"for":"1h","severity":"warning"}` | Pod container waiting longer than threshold |
| prometheusRules.DeploymentGenerationMismatch | object | `{"for":"15m","severity":"warning"}` | Deployment generation mismatch due to possible roll-back |
| prometheusRules.DeploymentReplicasMismatch | object | `{"for":"15m","severity":"warning"}` | Deployment has not matched the expected number of replicas |
| prometheusRules.HpaMaxedOut | object | `{"for":"15m","severity":"warning"}` | HPA is running at max replicas |
| prometheusRules.HpaReplicasMismatch | object | `{"for":"15m","severity":"warning"}` | HPA has not matched descired number of replicas |
| prometheusRules.PodContainerTerminated | object | `{"for":"1m","over":"10m","reasons":["ContainerCannotRun","DeadlineExceeded"],"severity":"warning","threshold":0}` | Monitors Pods for Containers that are terminated either for unexpected reasons like ContainerCannotRun. If that number breaches the $threshold (1) for $for (1m), then it will alert. |
| prometheusRules.PodCrashLooping | object | `{"for":"15m","severity":"warning"}` | Pod is crash looping |
| prometheusRules.PodNotReady | object | `{"for":"15m","severity":"warning"}` | Pod has been in a non-ready state for more than a specific threshold |
| prometheusRules.additionalRuleLabels | object | `{}` | (`map`) Additional custom labels attached to every PrometheusRule |
| prometheusRules.enabled | bool | `true` | (`bool`) Whether or not to enable the container rules template |
| proxySidecar.enabled | bool | `false` | (Boolean) Enables injecting a pre-defined reverse proxy sidecar container into the Pod containers list. |
| proxySidecar.env | list | `[]` | Environment Variables for the primary container. These are all run through the tpl function (the key name and value), so you can dynamically name resources as you need. |
| proxySidecar.envFrom | list | `[]` | Pull all of the environment variables listed in a ConfigMap into the Pod. See https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#configure-all-key-value-pairs-in-a-configmap-as-container-environment-variables for more details. |
| proxySidecar.image.pullPolicy | string | `"IfNotPresent"` | (String) Always, Never or IfNotPresent |
| proxySidecar.image.repository | string | `"nginx"` | (String) The Docker image name and repository for the sidecar |
| proxySidecar.image.tag | string | `"latest"` | (String) The Docker tag for the sidecar |
| proxySidecar.name | string | `"proxy"` | (String) The name of the proxy sidecar container |
| proxySidecar.resources | object | `{}` | A PodSpec "Resources" object for the proxy container |
| proxySidecar.volumeMounts | list | `[]` | List of VolumeMounts that are applied to the proxySidecar container - these must refer to volumes set in the `Values.volumes` parameter. |
| readinessProbe | object | `{"httpGet":{"path":"/","port":"http"}}` | A PodSpec container "readinessProbe" configuration object. Note that this readinessProbe will be applied to the proxySidecar container instead if that is enabled. |
| replicaCount | int | `2` | (`int`) The number of Pods to start up by default. If the `autoscaling.enabled` parameter is set, then this serves as the "start scale" for an application. Setting this to `null` prevents the setting from being applied at all in the PodSpec, leaving it to Kubernetes to use the default value (1). https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#replicas |
| resources | object | `{}` |  |
| revisionHistoryLimit | int | `3` | (`int`) The default revisionHistoryLimit in Kubernetes is 10 - which is just really noisy. Set our default to 3. https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy |
| runbookUrl | string | `"https://github.com/Nextdoor/k8s-charts/blob/main/charts/simple-app/README.md"` | The URL of the runbook for this service. |
| secrets | object | `{}` | (`Map`) Map of environment variables to plaintext secrets or KMS encrypted secrets. |
| secretsEngine | string | `"plaintext"` | (String) Secrets Engine determines the type of Secret Resource that will be created (`KMSSecret`, `Secret`). kms || plaintext are possible values. |
| securityContext | object | `{}` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| serviceMonitor.annotations | object | `{}` | (`map`) ServiceMonitor annotations. |
| serviceMonitor.interval | string | `nil` | ServiceMonitor scrape interval |
| serviceMonitor.labels | object | `{}` | Additional ServiceMonitor labels. |
| serviceMonitor.namespace | `string` | `nil` | Alternative namespace for ServiceMonitor resources. |
| serviceMonitor.relabelings | list | `[]` | ServiceMonitor relabel configs to apply to samples before scraping https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/api.md#relabelconfig |
| serviceMonitor.scheme | string | `"http"` | ServiceMonitor will use http by default, but you can pick https as well |
| serviceMonitor.scrapeTimeout | string | `nil` | ServiceMonitor scrape timeout in Go duration format (e.g. 15s) |
| serviceMonitor.tlsConfig | string | `nil` | ServiceMonitor will use these tlsConfig settings to make the health check requests |
| targetArchitecture | string | `"amd64"` | (`string`) If set, this value will be used in the .spec.nodeSelector to ensure that these pods specifically launch on the desired target host architecture. If set to null/empty-string, then this value will not be set. |
| targetOperatingSystem | string | `"linux"` | (`string`) If set, this value will be used in the .spec.nodeSelector to ensure that these pods specifically launch on the desired target Operating System. Must be set. |
| terminationGracePeriodSeconds | string | `nil` | https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#hook-handler-execution |
| tests.connection.args | list | `["{{ include \"simple-app.fullname\" . }}"]` | A list of arguments passed into the command. These are run through the tpl function. |
| tests.connection.command | list | `["curl","--retry-connrefused","--retry","5"]` | The command used to trigger the test. |
| tests.connection.image.repository | string | `"curlimages/curl"` | Sets the image-name that will be used in the "connection" integration test. If this is left empty, then the .image.repository value will be used instead (and the .image.tag will also be used). By default, prefer the latest official version to handle cases where the app image provides either no curl binary or an outdated one. |
| tests.connection.image.tag | string | `nil` | Sets the tag that will be used in the "connection" integration test. If this is left empty, the default is "latest" |
| tolerations | list | `[]` |  |
| topologySpreadConstraints | list | `[]` |  |
| virtualService.annotations | object | `{}` | Any annotations you wish to add to the `VirtualService` resource. See https://istio.io/latest/docs/reference/config/annotations/ for more details. |
| virtualService.corsPolicy | object | `{}` | (`map`) If set, this will populate the corsPolicy setting for the VirtualService. See https://istio.io/latest/docs/reference/config/networking/virtual-service/#CorsPolicy for more details. |
| virtualService.enabled | bool | `false` | (Boolean) Maps the Service to an Istio IngressGateway, exposing the service outside of the Kubernetes cluster. |
| virtualService.gateways | list | `[]` | The name of the Istio `Gateway` resource that this `VirtualService` will register with. You can get a list of the avaialable `Gateways` by running `kubectl -n istio-system get gateways`. Not specifying a Gateway means that you are creating a VirtualService routing definition only inside of the Kubernetes cluster, which is totally reasonable if you want to do that. |
| virtualService.hosts | list | `["{{ include \"simple-app.fullname\" . }}"]` | A list of destination hostnames that this VirtualService will accept traffic for. Multiple names can be listed here. See https://istio.io/latest/docs/reference/config/networking/virtual-service/#VirtualService for more details. |
| virtualService.matches | object | `{}` | (`map[]`) A list of Istio `HTTPMatchRequest` objects that will be applied to the VirtualService. This is the more advanced and customizable way of controlling which paths get sent to your backend. These are added _in addition_ to the `paths` or `path` settings. See https://istio.io/latest/docs/reference/config/networking/virtual-service/#HTTPMatchRequest for examples. |
| virtualService.namespace | string | `"istio-system"` | The namespace where the Istio services are operating. Do not change this. |
| virtualService.path | string | `"/"` | The default path prefix that the `VirtualService` will match requests against to pass to the default `Service` object in this deployment. |
| virtualService.paths | list | `[]` | (`string[]`) List of optional path prefixes that the `VirtualService` will use to match requests against and will pass to the `Service` object in this deployment. This list replaces the `path` prefix above - use one or the other, do not use both. |
| virtualService.port | int | `80` | This is the backing Pod port _number_ to route traffic to. This must match a `containerPort` in the `Values.ports` list. |
| virtualService.tls | string | `""` |  |
| volumeMounts | list | `[]` | List of VolumeMounts that are applied to the application container - these must refer to volumes set in the `Values.volumes` parameter. |
| volumes | list | `[]` | A list of 'volumes' that can be mounted into the Pod. See https://kubernetes.io/docs/concepts/storage/volumes/. |
| volumesString | string | `""` | A stringified list of 'volumes' similar to the `Values.volumes` parameter, but this one gets run through the `tpl` function so that you can use templatized values if you need to. See https://kubernetes.io/docs/concepts/storage/volumes/. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)
