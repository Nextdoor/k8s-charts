# stateful-app

Default StatefulSet Helm Chart

![Version: 1.3.0](https://img.shields.io/badge/Version-1.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

[statefulsets]: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/
[hpa]: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

This chart provides a standard deployment for operating a [stateful application
in Kubernetes][statefulsets]. The chart provides all of the common pieces like
ServiceAccounts, Services, etc.

## Upgrade Notes

### 1.1.x -> 1.2.x

**NEW: Templated Termination Grace Period**

`terminationGracePeriodSeconds` now supports template variables. This allows
one to compute the termination grace period based on additional criteria.

### 0.16.x -> 1.0.x

**BREAKING: Istio Alerts have changed**

The Istio Alerts chart was updated to 4.0.0 which updates the alert on the 5XX
rate to only aggregate per service, rather than including the client source workload.

Additionally, it added an alert which will attempt to detect if your selector
criteria is valid or not. This requires kube-state-metrics to be installed and
can be disabled via your values file if you do not wish to install
kube-state-metrics.

### 0.14.x -> 0.15.x

The `livenessProbe` and `readinessProbe` changes made in
https://github.com/Nextdoor/k8s-charts/pull/212 were invalid. Going forward
`livenessProbe` is optional, but `readinessProbe` is a required field.

### 0.11.x -> 0.12.x

**BREAKING: Istio Alerts have changed**

Review https://github.com/Nextdoor/k8s-charts/pull/231 carefully - the `5xx`
and `HighLatency` alarms have changed in makeup and you may need to adjust the
thresholds for your application now.

### 0.10.x -> 0.11.x

**BREAKING: `.Values.virtualService.gateways` syntax changed**

Istio `Gateways` can live in any namespace - and it is [recommended by
Istio](https://istio.io/latest/docs/setup/additional-setup/gateway/#deploying-a-gateway)
to run the Gateways in a separate namespace from the Istio Control Plane. The
`.Values.virtualService.gateways` format now must include the namespace of the
[`Gateway`](https://istio.io/latest/docs/reference/config/networking/gateway/)
object. Eg:

_Before_
```yaml
# values.yaml
virtualService:
  namespace: istio-system
  gateways:
  - internal
```

_After_
```yaml
# values.yaml
virtualService:
  gateways:
  - istio-system/internal
```

### 0.9.x -> 0.10.x

**NEW: Optional sidecar and init containers**

We have added the ability to define init and sidecar containers for your pod.
This can be helpful if your application requires bootstrapping or additional
applications to function. They can be added via `initContainers` and
`extraContainers` parameters respectively. It is important to note that these
containers are defined using native helm definition rather than the template
scheme this chart provides.

### 0.8.x -> 0.9.x

**NEW: Always create a `Service` Resource**

In order to make sure that the Istio Service Mesh can always determine
"locality" for client and server workloads, we _always_ create a `Service`
object now that is used by Istio to track the endpoints and determine their
locality. This `Service` may not expose any real ports to the rest of the
network, but is still critical for Istio.

**Switched `PodMonitor` to `ServiceMonitor`**

Because we are always creating a `Service` resource now, we've followed the
Prometheus Operator recommendations and switched to using a `ServiceMonitor`
object. The metrics stay the same, but for some reason the `ServiceMonitor` is
preferred.

### 0.7.x -> 0.8.x

**BREAKING: Rolled back to Values.prometheusRules**

The use of nested charts within nested charts is problematic, and we have
rolled it back. Please use `Values.prometheusRules` to configure alarms. We
will deprecate the `prometheus-alerts` chart.

### 0.6.x -> 0.7.x

**NEW: PrometheusRules are enabled by default!!**

Going forward, the
[`prometheus-alerts](https://github.com/Nextdoor/k8s-charts/tree/main/charts/prometheus-alerts)
chart will be installed _by default_ for you and configured to monitor your
basic resources. If you want to disable it or reconfigure the alerts, the
configuration lives in the `.Values.alerts` key.

### 0.5.x -> 0.6.x

**BREAKING: If you do not set .Values.ports, then no VirtualService will be created**

In the past, the `.Values.virtualService.enabled` flag was the only control
used to determine whether or not to create the `VirtualService` resource. This
meant that you could accidentally create a `VirtualService` pointing to a
non-existent `Service` if your application exposes no ports (like a
"taskworker" type application).

Going forward, the chart will not create a `VirtualService` unless the
`Values.ports` array is populated as well. This links the logic for `Service`
and `VirtualService` creation together.

### 0.4.x -> 0.5.x

**BREAKING: Default behavior is to turn on the Istio Annotations/Labels**

We now default setting `.Values.istio.enabled=true` in the `values.yaml` file.
This was done because the vast majority of our applications operate within the
mesh, and this default behavior is simpler for most users. If your service is
_not_ running within the mesh, then you must set the value to `false`.

**BREAKING: ServiceMonitor has been replaced with PodMonitor**

We have replaced the behavior of creating a `ServiceMonitor` resource with a
`PodMonitor` resource. This is done because not all applications will use a
`Service` (in fact, the creation of the `Service` resource is optional), and
that can cause the monitoring to fail. `PodMonitor` resources will configure
Prometheus to monitor the pods regardless of whether or not they are part of a
Service.

**BREAKING: All .Values.serviceMonitor parameters moved to .Values.monitor**

We have condensed the Values a bit, so the entire `.Values.serviceMonitor` key
has been removed, and all of the parameters have been moved into
`.Values.monitor`. Make sure to update your values appropriately!

**BREAKING: Istio Injection is now explicitly controlled**

In previous versions of the chart, setting `.Values.istio.enabled=true/false`
only impacted whether or not certain lables and annotations were created... it
did not impact whether or not your pod actually got injected with the Istio
sidecar.

_As of this new release, setting `.Values.istio.enabled=true` will explicitly
add the `sidecar.istio.io/inject="true"` label to your pods, which will inject
them regardless of the namespace config. Alternatively, setting
`.Values.istio.enabled=false` will explicitly set
`sidecar.istio.io/inject="false"` which will prevent injection, regardless of
the namespace configuration!_

### 0.3.x -> 0.4.x

**Default Replica Count is now 2!**

In order to make sure that even our staging/development deployments have some
guarantees of uptime, the defaults for the chart have changed. We now set
`replicaCount: 2` and create a `podDisruptionBudget` by default. This ensures
that a developer needs to _intentionally_ disable these settings in order to
create a single-pod deployment.

**No longer setting `DD_ENV` by default**

The `DD_ENV` variable in a container will override the underlying host Datadog
Agent `env` tag. This should not be set by default, so we no longer do this. If
you explicitly set this, it will work ... but by default you should let the
underlying host define the environment in which your application is running.

### 0.2.x -> 0.3.x

**Automatic NodeSelectors**

By default the chart now sets the `kubernetes.io/os` and `kubernetes.io/arch`
values in the `nodeSelector` field for your pods! The default values are
targeted towards our most common deployment environments - `linux` on `amd64`
hosts. Pay close attention to the `targetOperatingSystem` and
`targetArchitecture` values to customize this behavior.

### 0.1.3 -> 0.2.x

**New Feature: Secrets Management**

You can now manage `Secret` and `KMSSecret` Resources through `Values.secrets`.
See the [Secrets](#secrets) section below for details on how secrets work.

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
A `Secret`, `KMSSecret`, or `SealedSecret` resource would be created and mounted into the container
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
Or, alternatively, `SealedSecret` can be generated using the following example:
```
secrets:
  FOO_BAR: AQIA...
secretsEngine: sealed
```

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../nd-common | nd-common | 0.3.2 |
| https://k8s-charts.nextdoor.com | istio-alerts | 0.5.2 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| args | list | `[]` | The arguments passed to the command. If unspecified the container defaults are used. The exact rules of how commadn and args are interpreted can be # found at: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/ |
| command | list | `[]` | The command run by the container. This overrides `ENTRYPOINT`. If not specified, the container's default entrypoint is used. The exact rules of how commadn and args are interpreted can be # found at: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/ |
| containerName | string | `""` |  |
| datadog.enabled | `bool` | `true` | Whether or not the various datadog labels and options should be included or not. |
| datadog.env | `string` | `nil` | The "env" tag to configure for the application - this maps to the Datadog environment concept for isolating traces/apm data. _We default to not setting this, so that the Datadog Agent's own "ENV" setting is used as the default behavior. Only override this in special cases._ |
| datadog.metricsNamespace | `string` | `"eks"` | The prefix to append to all metrics that are scraped by Datadog. We set this to one common value so that common metrics (like `istio_.*` or `go_.*`) are shared across all apps in Datadog for easier dashboard creation as well as comparision between applications. |
| datadog.metricsToScrape | `strings[]` | `["\"*\""]` | A list of strings that match the metric names that Datadog should scrape from the endpoint. This defaults to `"*"` to tell it to scrape ALL metrics - however, if your app exposes too many metrics (> 2000), Datadog will drop them all on the ground. |
| datadog.scrapeLogs.enabled | `bool` | `true` | If true, then it will enable application logging to datadog. |
| datadog.scrapeLogs.processingRules | `map[]` | `[]` | A list of map that sets different log processing rules. https://docs.datadoghq.com/agent/logs/advanced_log_collection/?tab=configurationfile |
| datadog.scrapeLogs.source | `string` | `nil` | If set, this configures the "source" tag. If this is not set, the tag defaults to the `.Release.Name` for the application. |
| datadog.scrapeMetrics | `bool` | `false` | If true, then we will configure the Datadog agent to scrape metrics from the application pod via the values set in the .Values.monitor.* map. |
| datadog.service | `string` | `nil` | If set, this configures the "service" tag. If this is not set, the tag defaults to the `.Release.Name` for the application. |
| deploymentStrategy | object | `{}` | https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy |
| enableTopologySpread | `bool` | `false` | If set to `true`, then a default `TopologySpreadConstraint` will be created that forces your pods to be evenly distributed across nodes based on the `topologyKey` setting. The maximum skew between the spread is controlled with `topologySkew`. |
| env | list | `[]` | Environment Variables for the primary container. These are all run through the tpl function (the key name and value), so you can dynamically name resources as you need. |
| envFrom | list | `[]` | Pull all of the environment variables listed in a ConfigMap into the Pod. See https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#configure-all-key-value-pairs-in-a-configmap-as-container-environment-variables for more details. |
| extraContainers | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| image.forceTag | String | `nil` | Forcefully overrides the `image.tag` setting - this is useful if you have an outside too that automatically updates the `image.tag` value, but you want your application operators to be able to squash that override themselves. |
| image.pullPolicy | String | `"IfNotPresent"` | Always, Never or IfNotPresent |
| image.repository | String | `"nginx"` | The Docker image name and repository for your application |
| image.tag | String | `nil` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Supply a reference to a Secret that can be used by Kubernetes to pull down the Docker image. This is only used in local development, in combination with our `kube_create_ecr_creds` function from dotfiles. |
| ingress.annotations | object | `{}` | Any annotations you wish to add to the ALB. See https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/ for more details. |
| ingress.enabled | bool | `false` |  |
| ingress.host | string | `"{{ include \"nd-common.fullname\" . }}.{{ .Release.Namespace }}"` | This setting configures the ALB to listen specifically to requests for this hostname. It _also_ ties into the external-dns controller and automatically provisions DNS hostnames matching this value (presuming that they are allowed by the cluster settings). |
| ingress.path | string | `"/"` | See the `ingress.pathType` setting documentation. |
| ingress.pathType | string | `"Prefix"` | https://kubernetes.io/docs/concepts/services-networking/ingress/#path-types |
| ingress.port | string | `nil` | If set, this will override the `service.portName` parameter, and the `Service` object will point specifically to this port number on the backing Pods. |
| ingress.portName | string | `"http"` | This is the port "name" that the `Service` will point to on the backing Pods. This value must match one of the values of `.name` in the `Values.ports` configuration. |
| ingress.sslRedirect | bool | `true` | If `true`, then this will annotate the Ingress with a special AWS ALB Ingress Controller annotation that configures an SSL-redirect at the ALB level. |
| initContainers | list | `[]` |  |
| istio-alerts.enabled | `bool` | `true` | Whether or not to enable the istio-alerts chart. |
| istio.enabled | `bool` | `true` | Whether or not the service should be part of an Istio Service Mesh. If this is turned on and `Values.monitor.enabled=true`, then the Istio Sidecar containers will be configured to pull and merge the metrics from the application, rather than creating a new `ServiceMonitor` object. |
| istio.excludeInboundPorts | `list` | `[]` | If supplied, this is a list of inbound TCP ports that are excluded from being proxied by the Istio-proxy Envoy sidecar process. The `.Values.monitor.portNumber` is already included by default. The port values can either be integers or templatized strings. |
| istio.excludeOutboundPorts | `list` | `[]` | If supplied, this is a list of outbound TCP ports that are excluded from being proxied by the Istio-proxy Envoy sidecar process. The port values can either be integers or templatized strings. |
| istio.metricsMerging | `bool` | `false` | If set to "True", then the Istio Metrics Merging system will be turned on and Envoy will attempt to scrape metrics from the application pod and merge them with its own. This defaults to False beacuse in most environments we want to explicitly split up the metrics and collect Istio metrics separate from Application metrics. |
| istio.preStopCommand | `list <str>` | `nil` | If supplied, this is the command that will be passed into the `istio-proxy` sidecar container as a pre-stop function. This is used to delay the shutdown of the istio-proxy sidecar in some way or another. Our own default behavior is applied if this value is not set - which is that the sidecar will wait until it does not see the application container listening on any TCP ports, and then it will shut down.  eg: preStopCommand: [ /bin/sleep, "30" ] |
| kmsSecretsRegion | String | `nil` | AWS region where the KMS key is located |
| livenessProbe | string | `nil` | A PodSpec container "livenessProbe" configuration object. Note that this livenessProbe will be applied to the proxySidecar container instead if that is enabled. |
| monitor.annotations | `map` | `{}` | ServiceMonitor annotations. |
| monitor.enabled | `bool` | `true` | If enabled, ServiceMonitor resources for Prometheus Operator are created or if `Values.istio.enabled` is `True`, then the appropriate Pod Annotations will be added for the istio-proxy sidecar container to scrape the metrics. |
| monitor.interval | string | `nil` | ServiceMonitor scrape interval |
| monitor.labels | object | `{}` | Additional ServiceMonitor labels. |
| monitor.metricRelabelings | list | `[{"action":"drop","regex":"(go|process)_.*","sourceLabels":["__name__"]}]` | ServiceMonitor MetricRelabelConfigs to apply to samples before ingestion. https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#relabelconfig |
| monitor.path | `string` | `"/metrics"` | Path to scrape metrics from within your Pod. |
| monitor.portName | `string` | `"http-metrics"` | Name of the port to scrape for metrics - this is the name of the port that will be exposed in your `PodSpec` for scraping purposes. |
| monitor.portNumber | `int` | `9090` | Number of the port to scrape for metrics - this port will be exposed in your `PodSpec` to ensure it can be scraped. |
| monitor.relabelings | list | `[]` | ServiceMonitor relabel configs to apply to samples before scraping https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/api.md#relabelconfig |
| monitor.sampleLimit | `int` | `25000` | The maximum number of metrics that can be scraped - if there are more than this, then scraping will fail entirely by Prometheus. This is used as a circuit breaker to avoid blowing up Prometheus memory footprints. |
| monitor.scheme | `enum: http, https` | `"http"` | ServiceMonitor will use http by default, but you can pick https as well |
| monitor.scrapeTimeout | string | `nil` | ServiceMonitor scrape timeout in Go duration format (e.g. 15s) |
| monitor.tlsConfig | string | `nil` | ServiceMonitor will use these tlsConfig settings to make the health check requests |
| nameOverride | string | `""` |  |
| network.allowedNamespaces | `strings[]` | `[]` | A list of namespaces that are allowed to access the Pods in this application. If not supplied, then no `NetworkPolicy` is created, and your application may be isolated to itself. Note, enabling `VirtualService` or `Ingress` configurations will create their own dedicated `NetworkPolicy` resources, so this is only intended for internal service-to-service communication grants. |
| nodeSelector | `map` | `{}` | A list of key/value pairs that will be added in to the nodeSelector spec for the pods. |
| podAnnotations | `Map` | `{}` | List of Annotations to be added to the PodSpec |
| podDisruptionBudget | object | `{"maxUnavailable":1}` | Set up a PodDisruptionBudget for the Deployment. See https://kubernetes.io/docs/tasks/run-application/configure-pdb/ for more details. |
| podLabels | `Map` | `{}` | List of Labels to be added to the PodSpec |
| podManagementPolicy | `string` | `nil` | podManagementPolicy controls how pods are created during initial scale up, when replacing pods on nodes, or when scaling down. The default policy is `OrderedReady`, where pods are created in increasing order (pod-0, then pod-1, etc) and the controller will wait until each pod is ready before continuing. When scaling down, the pods are removed in the opposite order. The alternative policy is `Parallel` which will create pods in parallel to match the desired scale without waiting, and on scale down will delete all pods at once. |
| podSecurityContext | object | `{}` |  |
| ports | list | `[{"containerPort":80,"name":"http","protocol":"TCP"},{"containerPort":443,"name":"https","protocol":"TCP"}]` | A list of Port objects that are exposed by the service. These ports are applied to the main container, or the proxySidecar container (if enabled). The port list is also used to generate Network Policies that allow ingress into the pods. |
| preStopCommand | list | `["/bin/sleep","10"]` | Before a pod gets terminated, Kubernetes sends a SIGTERM signal to every container and waits for period of time (10s by default) for all containers to exit gracefully. If your app doesn't handle the SIGTERM signal or if it doesn't exit within the grace period, Kubernetes will kill the container and any inflight requests that your app is processing will fail.  Make sure you set this to SHORTER than the terminationGracePeriod (30s default) setting.  https://docs.flagger.app/tutorials/zero-downtime-deployments#graceful-shutdown |
| priorityClassName | `string` | `nil` | Set a different priority class to the pods, by default the default priority class is given to pods. Priority class could be used to prioritize pods over others and allow them to evict other pods with lower priorities. |
| prometheusRules.CPUThrottlingHigh | object | `{"for":"15m","severity":"warning","threshold":5}` | Container is being throttled by the CGroup - needs more resources. This value is appropriate for applications that are highly sensitive to request latency. Insensitive workloads might need to raise this percentage to avoid alert noise. |
| prometheusRules.ContainerWaiting | object | `{"for":"1h","severity":"warning"}` | Pod container waiting longer than threshold |
| prometheusRules.KubeStatefulSetGenerationMismatch | object | `{"for":"15m","severity":"warning"}` | StatefulSet generation mismatch due to possible roll-back |
| prometheusRules.KubeStatefulSetReplicasMismatch | object | `{"for":"15m","severity":"warning"}` | Deployment has not matched the expected number of replicas |
| prometheusRules.KubeStatefulSetUpdateNotRolledOut | object | `{"for":"15m","severity":"warning"}` | StatefulSet update has not been rolled out |
| prometheusRules.PodContainerTerminated | object | `{"for":"1m","over":"10m","reasons":["ContainerCannotRun","DeadlineExceeded"],"severity":"warning","threshold":0}` | Monitors Pods for Containers that are terminated either for unexpected reasons like ContainerCannotRun. If that number breaches the $threshold (1) for $for (1m), then it will alert. |
| prometheusRules.PodCrashLoopBackOff | object | `{"for":"10m","severity":"warning"}` | Pod is in a CrashLoopBackOff state and is not becoming healthy. |
| prometheusRules.PodNotReady | object | `{"for":"15m","severity":"warning"}` | Pod has been in a non-ready state for more than a specific threshold |
| prometheusRules.additionalRuleLabels | `map` | `{}` | Additional custom labels attached to every PrometheusRule |
| prometheusRules.enabled | `bool` | `true` | Whether or not to enable the prometheus-alerts chart. |
| proxySidecar.enabled | Boolean | `false` | Enables injecting a pre-defined reverse proxy sidecar container into the Pod containers list. |
| proxySidecar.env | list | `[]` | Environment Variables for the primary container. These are all run through the tpl function (the key name and value), so you can dynamically name resources as you need. |
| proxySidecar.envFrom | list | `[]` | Pull all of the environment variables listed in a ConfigMap into the Pod. See https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#configure-all-key-value-pairs-in-a-configmap-as-container-environment-variables for more details. |
| proxySidecar.image.pullPolicy | String | `"IfNotPresent"` | Always, Never or IfNotPresent |
| proxySidecar.image.repository | String | `"nginx"` | The Docker image name and repository for the sidecar |
| proxySidecar.image.tag | String | `"latest"` | The Docker tag for the sidecar |
| proxySidecar.name | String | `"proxy"` | The name of the proxy sidecar container |
| proxySidecar.resources | object | `{}` | A PodSpec "Resources" object for the proxy container |
| proxySidecar.volumeMounts | list | `[]` | List of VolumeMounts that are applied to the proxySidecar container - these must refer to volumes set in the `Values.volumes` parameter. |
| readinessProbe | string | `nil` | A PodSpec container "readinessProbe" configuration object. Note that this readinessProbe will be applied to the proxySidecar container instead if that is enabled. *This is required* |
| replicaCount | `int` | `2` | The number of Pods to start up by default. If the `autoscaling.enabled` parameter is set, then this serves as the "start scale" for an application. Setting this to `null` prevents the setting from being applied at all in the PodSpec, leaving it to Kubernetes to use the default value (1). https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#replicas |
| resources | object | `{}` |  |
| revisionHistoryLimit | `int` | `3` | The default revisionHistoryLimit in Kubernetes is 10 - which is just really noisy. Set our default to 3. https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy |
| runbookUrl | string | `"https://github.com/Nextdoor/k8s-charts/blob/main/charts/simple-app/README.md"` | The URL of the runbook for this service. |
| secrets | `Map` | `{}` | Map of environment variables to plaintext secrets, KMS, or Bitnami Sealed Secrets encrypted secrets. |
| secretsEngine | String | `"plaintext"` | Secrets Engine determines the type of Secret Resource that will be created (`KMSSecret`, `SealedSecret`, `Secret`). kms || sealed || plaintext are possible values. |
| securityContext | object | `{}` |  |
| service.name | `string` | `nil` | Optional override for the Service name. Can be used to create a simpler more friendly service name that is not specific to the application name. |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| startupProbe | string | `nil` | A PodSpec container "startupProbe" configuration object. Note that this startupProbe will be applied to the proxySidecar container instead if that is enabled. |
| targetArchitecture | `string` | `"amd64"` | If set, this value will be used in the .spec.nodeSelector to ensure that these pods specifically launch on the desired target host architecture. If set to null/empty-string, then this value will not be set. |
| targetOperatingSystem | `string` | `"linux"` | If set, this value will be used in the .spec.nodeSelector to ensure that these pods specifically launch on the desired target Operating System. Must be set. |
| terminationGracePeriodSeconds | string | `nil` | https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#hook-handler-execution |
| tests.connection.args | list | `["{{ include \"nd-common.fullname\" . }}"]` | A list of arguments passed into the command. These are run through the tpl function. |
| tests.connection.command | list | `["curl","--retry-connrefused","--retry","5"]` | The command used to trigger the test. |
| tests.connection.enabled | bool | `true` | Controls whether or not this Helm test component is enabled. |
| tests.connection.image.repository | string | `nil` | Sets the image-name that will be used in the "connection" integration test. If this is left empty, then the .image.repository value will be used instead (and the .image.tag will also be used). |
| tests.connection.image.tag | string | `nil` | Sets the tag that will be used in the "connection" integration test. If this is left empty, the default is "latest" |
| tolerations | list | `[]` |  |
| topologyKey | `string` | `"topology.kubernetes.io/zone"` | The topologyKey to use when asking Kubernetes to schedule the pods in a particular distribution. The default is to spread across zones evenly. Other options could be `kubernetes.io/hostname` to spread across EC2 instances, or `node.kubernetes.io/instance-type` to spread across instance types for example. |
| topologySkew | `int` | `1` | The maxSkew setting applied to the default TopologySpreadConstraint if `enableTopologySpread` is set to `true`. |
| topologySpreadConstraints | `string` | `[]` | An array of custom TopologySpreadConstraint settings applied to the PodSpec within the Deployment. Each of these TopologySpreadObjects should conform to the [`pod.spec.topologySpreadConstraints`](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/#api) API - but the `labelSelector` field should be left out, it will be inserted automatically for you. |
| updateStrategy | `StatefulSetUpdateStrategy` | `nil` | updateStrategy indicates the StatefulSetUpdateStrategy that will be employed to update Pods in the StatefulSet when a revision is made to Template.  https://v1-18.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#statefulsetupdatestrategy-v1-apps |
| virtualService.annotations | object | `{}` | Any annotations you wish to add to the `VirtualService` resource. See https://istio.io/latest/docs/reference/config/annotations/ for more details. |
| virtualService.corsPolicy | `map` | `{}` | If set, this will populate the corsPolicy setting for the VirtualService. See https://istio.io/latest/docs/reference/config/networking/virtual-service/#CorsPolicy for more details. |
| virtualService.enabled | Boolean | `false` | Maps the Service to an Istio IngressGateway, exposing the service outside of the Kubernetes cluster. |
| virtualService.fault | `map` | `{}` | Pass in an optional [`HTTPFaultInjection`](https://istio.io/latest/docs/reference/config/networking/virtual-service/#HTTPFaultInjection) configuration here to specify faults such as delaying or aborting the proxying of requests to the service.  If a configuration here is set, maintenanceMode.enabled MUST be set to 'false' (as that creates a very specific fault injection).  Otherwise, we fail to render the chart. |
| virtualService.gateways | list | `[]` | The name of the Istio `Gateway` resource that this `VirtualService` will register with. You can get a list of the avaialable `Gateways` by running `kubectl -n istio-system get gateways`. Not specifying a Gateway means that you are creating a VirtualService routing definition only inside of the Kubernetes cluster, which is totally reasonable if you want to do that.  Must be in the form of $namespace/$gateway. Eg, "istio-system/default-gateway". |
| virtualService.hosts | list | `["{{ include \"nd-common.fullname\" . }}"]` | A list of destination hostnames that this VirtualService will accept traffic for. Multiple names can be listed here. See https://istio.io/latest/docs/reference/config/networking/virtual-service/#VirtualService for more details. |
| virtualService.maintenanceMode.enabled | `bool` | `false` | Set to true if you want to create a specialized HTTP fault injection that aborts the proxying of requests to your service. You can also set the HTTP response that is returned when this mode is set. |
| virtualService.maintenanceMode.httpStatus | `int` | `503` | The HTTP response code that is returned when maintenanceMode is enabled. |
| virtualService.matches | `map[]` | `{}` | A list of Istio `HTTPMatchRequest` objects that will be applied to the VirtualService. This is the more advanced and customizable way of controlling which paths get sent to your backend. These are added _in addition_ to the `paths` or `path` settings. See https://istio.io/latest/docs/reference/config/networking/virtual-service/#HTTPMatchRequest for examples. |
| virtualService.path | string | `"/"` | The default path prefix that the `VirtualService` will match requests against to pass to the default `Service` object in this deployment. |
| virtualService.paths | `string[]` | `[]` | List of optional path prefixes that the `VirtualService` will use to match requests against and will pass to the `Service` object in this deployment. This list replaces the `path` prefix above - use one or the other, do not use both. |
| virtualService.port | int | `80` | This is the backing Pod port _number_ to route traffic to. This must match a `containerPort` in the `Values.ports` list. |
| virtualService.retries | `map` | `{}` | Pass in an optional [`HTTPRetry`](https://istio.io/latest/docs/reference/config/networking/virtual-service/#HTTPRetry) configuration here to control how services retry their failed requests to the backend service. The default behavior is to retry 2 times if a 503 is returned. |
| virtualService.tls | string | `""` |  |
| volumeClaimRetentionPolicy | `map` | `nil` | : https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#persistentvolumeclaim-retention |
| volumeClaimTemplates | `PersistentVolumeClaim[]` | `nil` | volumeClaimTemplates is a list of claims that pods are allowed to reference. The StatefulSet controller is responsible for mapping network identities to claims in a way that maintains the identity of a pod. Every claim in this list must have at least one matching (by name) volumeMount in one container in the template. A claim in this list takes precedence over any volumes in the template, with the same name.  https://v1-18.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#persistentvolumeclaim-v1-core |
| volumeMounts | list | `[]` | List of VolumeMounts that are applied to the application container - these must refer to volumes set in the `Values.volumes` parameter. |
| volumes | list | `[]` | A list of 'volumes' that can be mounted into the Pod. See https://kubernetes.io/docs/concepts/storage/volumes/. |
| volumesString | string | `""` | A stringified list of 'volumes' similar to the `Values.volumes` parameter, but this one gets run through the `tpl` function so that you can use templatized values if you need to. See https://kubernetes.io/docs/concepts/storage/volumes/. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
