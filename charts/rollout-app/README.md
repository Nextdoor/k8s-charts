# rollout-app

Argo Rollout-based Application Helm Chart

![Version: 1.6.0](https://img.shields.io/badge/Version-1.6.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

[analysistemplate]: https://argoproj.github.io/argo-rollouts/features/analysis/?query=AnalysisTemplate#background-analysis
[argo_rollouts]: https://argoproj.github.io/argo-rollouts/
[bluegreen]: https://argoproj.github.io/argo-rollouts/features/bluegreen/
[canary]: https://argoproj.github.io/argo-rollouts/features/canary/
[experiment]: https://argoproj.github.io/argo-rollouts/features/experiment/
[rollout]: https://argoproj.github.io/argo-rollouts/features/specification/

This chart launches a horizontally scalable application through the use of the
Argo [`Rollout`][rollout] custom resource. See the [Argo Rollouts - Kubernetes
Progressive Delivery Controller][argo_rollouts] for more information about
how these work, and the various custom resource definitions.

## Upgrade Notes

### 1.5.x -> 1.6.x

**NEW: Enabled migration capabilities from `simple-app` to `rollout-app`**

Beginning with this version, you can now migrate from `simple-app` to `rollout-app` with no downtime between your services.
To enable this, you will need to set the `migrate.inProgress` value to `true` in your values file.
Additionally, you may need to set the `migrate.workloadRef.name` value to the name of the dependency chart you are migrating from.
Check the `migrate.workloadRef.scaleDown` field for strategies available for scaling down the Deployment.
The default value is `onsuccess`, meaning that the Deployment be scaled down only after the Rollout becomes healthy (extremely safe!).
For more information on steps to migrate, check out the documentation here:
# https://nextdoor.atlassian.net/wiki/spaces/ENG/pages/4013359115/Canary+Deployments+At+Nextdoor

### 1.4.x -> 1.5.x

**NEW: Allow rollouts per availability-zone and added support for canary `dynamicStableScale` field**

Beginning with this version, if serves up high cross-zone traffic, you may wish to enable
same-zone locality awareness by spinning up Rollouts in each AZ. You can do this with the
`rolloutZones` and `rolloutZonesTransition` parameters.

Also, for cost-consciousness we added support for the [dynamicStableScale](https://argo-rollouts.readthedocs.io/en/stable/features/canary/#dynamic-stable-scale-with-traffic-routing)
option.

### 1.3.x -> 1.4.x

**NEW: Allow access from cross-cluster, in-mesh services**

Beginning with this version, if your app is on the mesh, we'll create
analogous [AuthorizationPolicies](https://istio.io/latest/docs/reference/config/security/authorization-policy/) to the already existing NetworkPolicies,
as they act as drop-in replacements for a multi-clustered, multi-primary setup.

`network.allowAll`, if set, will update your NetworkPolicies to allow
access from anywhere, including  other services running in a different
cluster in a multi-cluter, multi-primary Istio environment.

### 1.2.x -> 1.3.x

**NEW: Maintenance Mode and Custom HTTP Fault Injections**

`virtualService.fault` allows you to set custom [HTTP fault injections](https://istio.io/latest/docs/reference/config/networking/virtual-service/#HTTPFaultInjection)
at the client side (like delays or abort) before proxying to the service.

`virtualService.maintenanceMode.enabled` will set a very specific fault that
aborts the request with a 5xx (or whatever is set at `httpStatus`) and disable
scale-down behavior of the HPA.

If maintenanceMode is enabled, fault must be `{}`. If there's a fault configuration,
then maintenanceMode must be disabled. Otherwise the chart won't render.

### 1.1.x -> 1.2.x

**NEW: Templated Termination Grace Period**

`terminationGracePeriodSeconds` now supports template variables. This allows
one to compute the termination grace period based on additional criteria.

### 0.7.x -> 1.0.x

**BREAKING: Istio Alerts have changed**

The Istio Alerts chart was updated to 4.0.0 which updates the alert on the 5XX
rate to only aggregate per service, rather than including the client source workload.

Additionally, it added an alert which will attempt to detect if your selector
criteria is valid or not. This requires kube-state-metrics to be installed and
can be disabled via your values file if you do not wish to install
kube-state-metrics.

### 0.2.x -> 0.3.x

**BREAKING: Istio Alerts have changed**

Review https://github.com/Nextdoor/k8s-charts/pull/231 carefully - the `5xx`
and `HighLatency` alarms have changed in makeup and you may need to adjust the
thresholds for your application now.

### 0.1.x -> 0.2.x

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

### 0.0.x -> 0.1.x

**NEW: Optional sidecar and init containers**

We have added the ability to define init and sidecar containers for your pod.
This can be helpful if your application requires bootstrapping or additional
applications to function. They can be added via `initContainers` and
`extraContainers` parameters respectively. It is important to note that these
containers are defined using native helm definition rather than the template
scheme this chart provides.

## Rollout Resources Supported

### [`Rollout`][rollout]

The [`templates/rollout.yaml`](templates/rollout.yaml) template controls the
creation of the [`Rollout`][rollout] resource. This resource is the replacement
for the standard Kubernetes `Deployment` resource, but has two new deployment
strategies - [`BlueGreen`][bluegreen] and [`Canary`][canary].

The `.strategy` value can be set to `blueGreen` or `canary` to control which
behavior you are looking for in your `Rollout` resource. From there, you can
customize the deployment behavior through the `.blueGreen` or `.canary` values.

### [`AnalysisTemplate`][analysistemplate] (_Not Supported_)

At this time, you will need to create your own
[`AnalysisTemplate`][analysistemplate] resources to describe how to analyze the
behavior of an application and decide if it is healthy or not. In future
releases, we may build support into this chart to manage those resources.

_You can refer to an `AnalysisTemplate` you have created through the
`.blueGreen.postPromotionAnalysis`, `.blueGreen.prePromotionAnalysis` and
`.canary.analysis` parameters_.

### [`Experiment`][experiment] (_Not Supported_)

At this time, you will need to create your own [`Experiment`][experiment]
resources. These resources are highly customized, and likely not worth trying
to build in any default experiments into this chart.

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
| file://../nd-common | nd-common | 0.5.2 |
| https://k8s-charts.nextdoor.com | istio-alerts | 0.5.3 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| args | list | `[]` | The arguments passed to the command. If unspecified the container defaults are used. The exact rules of how commadn and args are interpreted can be # found at: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/ |
| autoscaling.behavior | `map` | `{"scaleDown":{"policies":[{"periodSeconds":60,"type":"Pods","value":5},{"periodSeconds":60,"type":"Percent","value":25}],"selectPolicy":"Min","stabilizationWindowSeconds":300},"scaleUp":{"policies":[{"periodSeconds":60,"type":"Pods","value":4},{"periodSeconds":60,"type":"Percent","value":100}],"selectPolicy":"Max","stabilizationWindowSeconds":0}}` | Controls the way that the AutoScaler scales up and down. We use this to control the speed in which the scaler responds to scaleUp and scaleDown events. Explicitly set this to `null` to let Kubernetes set its default policy. |
| autoscaling.behavior.scaleDown.policies[0] | `map` | `{"periodSeconds":60,"type":"Pods","value":5}` | Allow up to 5 pods to be removed within a 60 second window. |
| autoscaling.behavior.scaleDown.policies[1] | `map | `{"periodSeconds":60,"type":"Percent","value":25}` | On larger deployments, we want to limit the scale-down so that we don't have to bounce too quickly back up if the scale-down was too aggressive. Limit is 25% of the containers every minute. |
| autoscaling.behavior.scaleDown.selectPolicy | `string` | `"Min"` | Ensure that we can scale down up to 5 pods at a time, so that our scale-down rate is graceful in general. We'd rather scale down quickly than constantly be bouncing around.  50 -> 45 -> 40 -> 35 -> 30 -> 25 -> 20 -> 15 -> 12 -> 9 -> 7 -> 6 -> 5 -> 4 -> 3 -> 2 -> 1  |
| autoscaling.behavior.scaleDown.stabilizationWindowSeconds | `int` | `300` | https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#stabilization-window  The stabilization window is used to restrict the flapping of replica count when the metrics used for scaling keep fluctuating. The autoscaling algorithm uses this window to infer a previous desired state and avoid unwanted changes to workload scale.  For example, in the following example snippet, a stabilization window is specified for scaleDown.    behavior:     scaleDown:       stabilizationWindowSeconds: 300  When the metrics indicate that the target should be scaled down the algorithm looks into previously computed desired states, and uses the highest value from the specified interval. In the above example, all desired states from the past 5 minutes will be considered.  This approximates a rolling maximum, and avoids having the scaling algorithm frequently remove Pods only to trigger recreating an equivalent Pod just moments later.  |
| autoscaling.behavior.scaleUp.policies[0] | `map` | `{"periodSeconds":60,"type":"Pods","value":4}` | Increase by no more than 4 pods per 60 seconds.  Eg: 1 -> 5 -> 9 -> 13... |
| autoscaling.behavior.scaleUp.policies[1] | `map` | `{"periodSeconds":60,"type":"Percent","value":100}` | Increase by up to 100% of the pods per 60 seconds.  Eg: 1 -> 2 -> 4 -> 8 -> 16... |
| autoscaling.behavior.scaleUp.selectPolicy | `string` | `"Max"` | When evaluating the desired scale for the service, pick from one of the below behaviors based on which one scales up the most pods.  So, when scaling from 1 pod, the pattern looks like this:  1 -> 5 -> 10 -> 20 -> 40 -> 80  (over 5 minutes)  |
| autoscaling.behavior.scaleUp.stabilizationWindowSeconds | `int` | `0` | https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#stabilization-window  The stabilization window is used to restrict the flapping of replica count when the metrics used for scaling keep fluctuating. The autoscaling algorithm uses this window to infer a previous desired state and avoid unwanted changes to workload scale.  For example, in the following example snippet, a stabilization window is specified for scaleDown.    behavior:     scaleDown:       stabilizationWindowSeconds: 300  When the metrics indicate that the target should be scaled down the algorithm looks into previously computed desired states, and uses the highest value from the specified interval. In the above example, all desired states from the past 5 minutes will be considered.  This approximates a rolling maximum, and avoids having the scaling algorithm frequently remove Pods only to trigger recreating an equivalent Pod just moments later.  |
| autoscaling.enabled | bool | `false` | Controls whether or not an HorizontalPodAutoscaler resource is created. |
| autoscaling.maxReplicas | int | `100` | Sets the maximum number of Pods to run |
| autoscaling.minReplicas | int | `1` | Sets the minimum number of Pods to run |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Configures the HPA to target a particular CPU utilization percentage |
| blueGreen.antiAffinity | `map` | `nil` | Check out the Anti Affinity document document for more information. |
| blueGreen.autoPromotionEnabled | `bool` | `nil` | The AutoPromotionEnabled will make the rollout automatically promote the new ReplicaSet to the active service once the new ReplicaSet is healthy. This field is defaulted to true if it is not specified. |
| blueGreen.autoPromotionSeconds | `int` | `nil` | The AutoPromotionSeconds will make the rollout automatically promote the new ReplicaSet to active Service after the AutoPromotionSeconds time has passed since the rollout has entered a paused state. If the AutoPromotionEnabled field is set to true, this field will be ignored |
| blueGreen.maxUnavailable | `int` | `nil` | The maximum number of pods that can be unavailable during the update. Value can be an absolute number (ex: 5) or a percentage of desired pods (ex: 10%). This can not be 0 if MaxSurge is 0. |
| blueGreen.postPromotionAnalysis | `map` | `nil` | Configures the [Analysis](https://argoproj.github.io/argo-rollouts/features/analysis/#bluegreen-pre-promotion-analysis) after the traffic switch to new version. If the analysis run fails or errors out, the Rollout enters an aborted state and switch traffic back to the previous stable Replicaset. If `scaleDownDelaySeconds` is specified, the controller will cancel any AnalysisRuns at time of `scaleDownDelay` to scale down the ReplicaSet. If it is omitted, and post analysis is specified, it will scale down the ReplicaSet only after the AnalysisRun completes (with a minimum of 30 seconds). |
| blueGreen.prePromotionAnalysis | `map` | `nil` | Configures the [Analysis](https://argoproj.github.io/argo-rollouts/features/analysis/#bluegreen-pre-promotion-analysis) before it switches traffic to the new version. The AnalysisRun can be used to block the Service selector switch until the AnalysisRun finishes successful. The success or failure of the analysis run decides if the Rollout will switch traffic, or abort the Rollout completely. |
| blueGreen.previewReplicaCount | `int` | `nil` | The PreviewReplicaCount field will indicate the number of replicas that the new version of an application should run. Once the application is ready to promote to the active service, the controller will scale the new ReplicaSet to the value of the spec.replicas. The rollout will not switch over the active service to the new ReplicaSet until it matches the spec.replicas count.  This feature is mainly used to save resources during the testing phase. If the application does not need a fully scaled up application for the tests, this feature can help save some resources.  If omitted, the preview ReplicaSet stack will be scaled to 100% of the replicas. |
| blueGreen.scaleDownDelayRevisionLimit | `int` | `nil` | The ScaleDownDelayRevisionLimit limits the number of old active ReplicaSets to keep scaled up while they wait for the scaleDownDelay to pass after being removed from the active service.  If omitted, all ReplicaSets will be retained for the specified scaleDownDelay |
| blueGreen.scaleDownDelaySeconds | `int` | `nil` | The ScaleDownDelaySeconds is used to delay scaling down the old ReplicaSet after the active Service is switched to the new ReplicaSet. |
| canary.abortScaleDownDelaySeconds | `int` | `nil` | Can be used in conjuction with dynamicStableScale to control how quickly the canary ReplicaSet is scaled down. If dynamicStableScale is set, and the rollout is aborted, the canary ReplicaSet will dynamically scale down as traffic shifts back to stable. If you wish to leave the canary ReplicaSet scaled up while aborting a bit longer ([default 30s](https://argo-rollouts.readthedocs.io/en/stable/features/scaledown-aborted-rs/)), an explicit value can be set here. |
| canary.analysis | `map` | `nil` | Configure the background [Analysis](https://argoproj.github.io/argo-rollouts/features/analysis/) to execute during the rollout. If the analysis is unsuccessful the rollout will be aborted. |
| canary.antiAffinity | `map` | `nil` | Check out the Anti Affinity document document for more information. |
| canary.canaryMetadata | `map` | `nil` | Metadata which will be attached to the canary pods. This metadata will only exist during an update, since there are no canary pods in a fully promoted rollout. |
| canary.dynamicStableScale | `bool` | `nil` | When true, dynamically reduces the scale of the stable ReplicaSet during an update such that it scales down as the traffic weight increases to canary.  Advantage include savings on spinup of new nodes when replica counts are high and less likely for HPAs to scale stable down as overall pod counts stay the same for similar traffic split.  By default (if false), the stable ReplicaSet is left scaled to 100% during the update. This has the advantage that if an abort occurs, traffic can be immediately shifted back to the stable ReplicaSet without delay (if set to true, and the rollout is aborted, the canary ReplicaSet will dynamically scale down as traffic shifts back to stable |
| canary.maxSurge | `int` or `string` | `nil` | The maximum number of pods that can be scheduled above the original number of pods. Value can be an absolute number (ex: 5) or a percentage of total pods at the start of the update (ex: 10%). This can not be 0 if MaxUnavailable is 0. Absolute number is calculated from percentage by rounding up. By default, a value of 1 is used.# Example: when this is set to 30%, the new RC can be scaled up by 30% immediately when the rolling update starts. Once old pods have been killed, new RC can be scaled up further, ensuring that total number of pods running at any time during the update is at most 130% of original pods. +optional |
| canary.maxUnavailable | `int` or `string` | `nil` | The maximum number of pods that can be unavailable during the update. Value can be an absolute number (ex: 5) or a percentage of total pods at the start of update (ex: 10%). Absolute number is calculated from percentage by rounding down. This can not be 0 if  MaxSurge is 0. By default, a fixed value of 1 is used. Example: when this is set to 30%, the old RC can be scaled down by 30% immediately when the rolling update starts. Once new pods are ready, old RC can be scaled down further, followed by scaling up the new RC, ensuring that at least 70% of original number of pods are available at all times during the update. +optional |
| canary.scaleDownDelayRevisionLimit | `int` | `nil` | Limits the number of old RS that can run at one time before getting scaled down. Defaults to nil |
| canary.scaleDownDelaySeconds | `int` | `nil` | Adds a delay before scaling down the previous ReplicaSet when the canary strategy is used with traffic routing (default 30 seconds). A delay in scaling down the previous ReplicaSet is needed after switching the stable service selector to point to the new ReplicaSet, in order to give time for traffic providers to re-target the new pods. This value is ignored with basic, replica-weighted canary without traffic routing. |
| canary.stableMetadata | `map` | `nil` | metadata which will be attached to the stable pods |
| canary.steps | `map[]` | `[{"setWeight":20},{"pause":{"duration":"5m"}},{"setWeight":40},{"pause":{"duration":"5m"}},{"setWeight":80}]` | This **required** parameter defines the canary rollout process. Strictly speaking, the Argo Rollouts controller does not require that you define a set of steps .. but the ArgoCD integration with Argo Rollouts does require that these steps be defined, otherwise it fails.  Read the [documentation here](https://argoproj.github.io/argo-rollouts/features/canary/#example) to learn more about the available steps, and how you can configure them. |
| command | list | `[]` | The command run by the container. This overrides `ENTRYPOINT`. If not specified, the container's default entrypoint is used. The exact rules of how commadn and args are interpreted can be # found at: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/ |
| containerName | string | `""` |  |
| datadog.enabled | `bool` | `true` | Whether or not the various datadog labels and options should be included or not. |
| datadog.env | `string` | `nil` | The "env" tag to configure for the application - this maps to the Datadog environment concept for isolating traces/apm data. _We default to not setting this, so that the Datadog Agent's own "ENV" setting is used as the default behavior. Only override this in special cases._ |
| datadog.metricsNamespace | `string` | `"eks"` | The prefix to append to all metrics that are scraped by Datadog. We set this to one common value so that common metrics (like `istio_.*` or `go_.*`) are shared across all apps in Datadog for easier dashboard creation as well as comparision between applications. |
| datadog.metricsToScrape | `strings[]` | `["\"*\""]` | A list of strings that match the metric names that Datadog should scrape from the endpoint. This defaults to `"*"` to tell it to scrape ALL metrics - however, if your app exposes too many metrics (> 2000), Datadog will drop them all on the ground. |
| datadog.scrapeLogs.enabled | `bool` | `false` | If true, then it will enable application logging to datadog. |
| datadog.scrapeLogs.processingRules | `map[]` | `[]` | A list of map that sets different log processing rules. https://docs.datadoghq.com/agent/logs/advanced_log_collection/?tab=configurationfile |
| datadog.scrapeLogs.source | `string` | `nil` | If set, this configures the "source" tag. If this is not set, the tag defaults to the `.Release.Name` for the application. |
| datadog.scrapeMetrics | `bool` | `false` | If true, then we will configure the Datadog agent to scrape metrics from the application pod via the values set in the .Values.monitor.* map. |
| datadog.service | `string` | `nil` | If set, this configures the "service" tag. If this is not set, the tag defaults to the `.Release.Name` for the application. |
| enableOnlyGRPCProbing | `bool` | `false` | If enableOnlyGRPCProbing is set to true, then within when generating the livenessProbe and readinessProbe fields within the Rollout spec, only the GRPC ports will be used, skipping the creation of the HTTP ports. |
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
| istio.nativeSidecars.enabled | `bool|str` | `""` | Set to true if you want your app's proxy running as a Kubernetes native sidecar - in which case (1) PreStop commands should be updating initContainers of the Pod spec rather than containers, and (2) An appropriate annotation will be added to your Pod spec  We will default to 'true' when https://github.com/istio/istio/issues/48794 is flipped sometime in the future.  Set to an empty string "" or leave unset (nil) to omit the annotation. |
| istio.nativeSidecars.keepCustomPreStopOverride | `bool` | `true` | Set to "false" if you want to use Istio's default drain rather than our own default behavior for preStop command to be applied to istio-proxy.  IMPORTANT NOTE: In a future iteration, we will remove this toggle and remove the custom default preStop altogether, but for now it may be needed/wanted due to https://github.com/istio/istio/issues/51855 |
| istio.preStopCommand | `list <str>` | `nil` | If supplied, this is the command that will be passed into the `istio-proxy` sidecar container as a pre-stop function. This is used to delay the shutdown of the istio-proxy sidecar in some way or another. Our own default behavior is applied if this value is not set - which is that the sidecar will wait until it does not see the application container listening on any TCP ports, and then it will shut down.  eg: preStopCommand: [ /bin/sleep, "30" ] |
| kmsSecretsRegion | String | `nil` | AWS region where the KMS key is located |
| livenessProbe | object | `{"httpGet":{"path":"/","port":"http"}}` | A PodSpec container "livenessProbe" configuration object. Note that this livenessProbe will be applied to the proxySidecar container instead if that is enabled. |
| migrate | object | `{"inProgress":false,"workloadRef":{"name":null,"scaleDown":"progressively"}}` | Migrating from `simple-app` (kind: Deployment) to `rollout-app` (kind: Rollout)? This section handles the migrations from Nextdoor's regular Deployment kind (found in `simple-app`) to the Rollout kind (found in `rollout-app`). Not necessary for new services. !IMPORTANT!: You should only toggle the `inProgress` field to `true` if your Rollout pods are already up and accepting traffic, aka their status is `Ready`. Not doing so will result in downtime for your application. If you wish to migrate (`inProgress` field is `true`), the Pods you deploy will use the template found currently within the Deployment's template. Upon migration completion (toggling `inProgress` to `false`), the Deployment will be deleted, and the Pod's will have labels that match a rollout deployment. For more information on steps to migrate, check out the documentation here: https://nextdoor.atlassian.net/wiki/spaces/ENG/pages/4013359115/Canary+Deployments+At+Nextdoor |
| migrate.inProgress | `bool` | `false` | If true, your service will start to migrate from a Deployment to a Rollout. Ensure that the other fields under migrate are also set. !IMPORTANT!: You should only toggle the `inProgress` field to `true` if your Rollout pods are already up and accepting traffic, aka their status is `Ready`. Not doing so will result in downtime for your application. |
| migrate.workloadRef | `map` | `{"name":null,"scaleDown":"progressively"}` | The workloadRef field helps ensure that during the migration, traffic is still always being handled by *something*. The rollout CRD will divert traffic to the original Deployment, and depending on the scaleDownStrategy field, progressively starts scalng down traffic to the original Deployment as traffic towards the canary deployment ramps up. For more information on how this is used during migrations, see: https://argo-rollouts.readthedocs.io/en/stable/migrating/#reference-deployment-from-rollout |
| migrate.workloadRef.name | `string` | `nil` | The of the chart that you are migrating from. If you are migrating from `simple-app`, the value can be found within your Chart.yaml file as in the dependencies list. Typically just `simple-app`, but it can also be the value of alias if that is set. NOTE: If you are migrating from a deployment that utilizes multiple availability zones, ensure that you apply the values found within `deploymentZones` to `rolloutZones` as well as the topology values. |
| migrate.workloadRef.scaleDown | `string` | `"progressively"` | specifies how the Deployment should be scaled down. There are three options available: - `never`: the Deployment is not scaled down - `onsuccess`: the Deployment is scaled down after the Rollout becomes healthy - `progressively`: as the Rollout is scaled up the Deployment is scaled down, and the default choice for migrations For more information on the strategy, please visit: https://argo-rollouts.readthedocs.io/en/stable/migrating/#reference-deployment-from-rollout |
| minReadySeconds | string | `nil` | https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#min-ready-seconds |
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
| network.allowAll | `bool` | `false` | If set to "True", then the NetworkPolicies will be opened up and traffic auth will be managed by Istio's `AuthorizationPolicy` instead.  This assumes your app is part of the Istio service mesh |
| network.allowedNamespaces | `strings[]` | `[]` | A list of namespaces that are allowed to access the Pods in this application. If not supplied, then no `NetworkPolicy` or `AuthorizationPolicy` is created, and your application may be isolated to itself. Note, enabling `VirtualService` or `Ingress` configurations will create their own dedicated `NetworkPolicy` resources, so this is only intended for internal service-to-service communication grants. |
| nodeSelector | `map` | `{}` | A list of key/value pairs that will be added in to the nodeSelector spec for the pods. |
| podAnnotations | `Map` | `{}` | List of Annotations to be added to the PodSpec |
| podDisruptionBudget | object | `{"maxUnavailable":1}` | Set up a PodDisruptionBudget for the Deployment. See https://kubernetes.io/docs/tasks/run-application/configure-pdb/ for more details. |
| podLabels | `Map` | `{}` | List of Labels to be added to the PodSpec |
| podSecurityContext | object | `{}` |  |
| ports | `ContainerPort[]` | `[{"containerPort":80,"name":"http","port":null,"protocol":"TCP"}]` | A list of Port objects that are exposed by the service. These ports are applied to the main container, or the proxySidecar container (if enabled). The port list is also used to generate Network Policies that allow ingress into the pods. See https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.21/#containerport-v1-core for details.  **Note: We have added an optional "port" field to this list that allows the user to override the Service Port (for example 80) that a client  connects to, without altering the Container Port (say, 8080) that is listening for connections. |
| preStopCommand | list | `["/bin/sleep","10"]` | Before a pod gets terminated, Kubernetes sends a SIGTERM signal to every container and waits for period of time (10s by default) for all containers to exit gracefully. If your app doesn't handle the SIGTERM signal or if it doesn't exit within the grace period, Kubernetes will kill the container and any inflight requests that your app is processing will fail.  Make sure you set this to SHORTER than the terminationGracePeriod (30s default) setting.  https://docs.flagger.app/tutorials/zero-downtime-deployments#graceful-shutdown |
| priorityClassName | `string` | `nil` | Set a different priority class to the pods, by default the default priority class is given to pods. Priority class could be used to prioritize pods over others and allow them to evict other pods with lower priorities. |
| progressDeadlineSeconds | string | `nil` | https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#progress-deadline-seconds |
| prometheusRules.CPUThrottlingHigh | object | `{"for":"15m","severity":"warning","threshold":5}` | Container is being throttled by the CGroup - needs more resources. This value is appropriate for applications that are highly sensitive to request latency. Insensitive workloads might need to raise this percentage to avoid alert noise. |
| prometheusRules.ContainerWaiting | object | `{"for":"1h","severity":"warning"}` | Pod container waiting longer than threshold |
| prometheusRules.HpaMaxedOut | object | `{"for":"15m","severity":"warning"}` | HPA is running at max replicas |
| prometheusRules.HpaReplicasMismatch | object | `{"for":"15m","severity":"warning"}` | HPA has not matched descired number of replicas |
| prometheusRules.PodContainerTerminated | object | `{"for":"1m","over":"10m","reasons":["ContainerCannotRun","DeadlineExceeded"],"severity":"warning","threshold":0}` | Monitors Pods for Containers that are terminated either for unexpected reasons like ContainerCannotRun. If that number breaches the $threshold (1) for $for (1m), then it will alert. |
| prometheusRules.PodCrashLoopBackOff | object | `{"for":"10m","severity":"warning"}` | Pod is in a CrashLoopBackOff state and is not becoming healthy. |
| prometheusRules.PodNotReady | object | `{"for":"15m","severity":"warning"}` | Pod has been in a non-ready state for more than a specific threshold |
| prometheusRules.additionalRuleLabels | `map` | `{}` | Additional custom labels attached to every PrometheusRule |
| prometheusRules.enabled | `bool` | `true` | Whether or not to enable the container rules template |
| proxySidecar.enabled | Boolean | `false` | Enables injecting a pre-defined reverse proxy sidecar container into the Pod containers list. |
| proxySidecar.env | list | `[]` | Environment Variables for the primary container. These are all run through the tpl function (the key name and value), so you can dynamically name resources as you need. |
| proxySidecar.envFrom | list | `[]` | Pull all of the environment variables listed in a ConfigMap into the Pod. See https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#configure-all-key-value-pairs-in-a-configmap-as-container-environment-variables for more details. |
| proxySidecar.image.pullPolicy | String | `"IfNotPresent"` | Always, Never or IfNotPresent |
| proxySidecar.image.repository | String | `"nginx"` | The Docker image name and repository for the sidecar |
| proxySidecar.image.tag | String | `"latest"` | The Docker tag for the sidecar |
| proxySidecar.name | String | `"proxy"` | The name of the proxy sidecar container |
| proxySidecar.resources | object | `{}` | A PodSpec "Resources" object for the proxy container |
| proxySidecar.volumeMounts | list | `[]` | List of VolumeMounts that are applied to the proxySidecar container - these must refer to volumes set in the `Values.volumes` parameter. |
| readinessProbe | object | `{"httpGet":{"path":"/","port":"http"}}` | A PodSpec container "readinessProbe" configuration object. Note that this readinessProbe will be applied to the proxySidecar container instead if that is enabled. |
| replicaCount | `int` | `2` | The number of Pods to start up by default. If the `autoscaling.enabled` parameter is set, then this serves as the "start scale" for an application. Setting this to `null` prevents the setting from being applied at all in the PodSpec, leaving it to Kubernetes to use the default value (1). https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#replicas |
| resources | object | `{}` |  |
| revisionHistoryLimit | `int` | `3` | The default revisionHistoryLimit in Kubernetes is 10 - which is just really noisy. Set our default to 3. https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#clean-up-policy |
| rolloutZones | `string[]` | `[]` | If supplied, an individual `Rollout` (and optional `HPA`) is created for each of the Availability Zone strings passed in. The default usage of this parameter would be to ensure that each AZ in your infrastructure has its own Rollout and HPA for scaling that is independent of the others. This is useful for services that are accessed by zone-aware clients, where the load may be imbalanced from one zone to another. |
| rolloutZonesTransition | `bool` | `false` | During the transition from an individual zone rollout resources to using multiple rollout resources for AZs, flip this setting to `true` to enable the creation of BOTH the Zone-Aware AND Default Rollout resources. This ensures that during the rollover from one to the other configuration, you do not lose all of your pods. To go from using multiple rollout resources to just an individual rollout resource, flip this setting to `false`. |
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
| strategy | `string` | `"blueGreen"` | Chooses which Rollout strategy to use - either `blueGreen` or `canary`. Use `.Values.blueGreen` and `.Values.canary` to customize the actual behavior of the rollout. |
| targetArchitecture | `string` | `"amd64"` | If set, this value will be used in the .spec.nodeSelector to ensure that these pods specifically launch on the desired target host architecture. If set to null/empty-string, then this value will not be set. |
| targetOperatingSystem | `string` | `"linux"` | If set, this value will be used in the .spec.nodeSelector to ensure that these pods specifically launch on the desired target Operating System. Must be set. |
| terminationGracePeriodSeconds | string | `nil` | https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#hook-handler-execution |
| tests.connection.args | list | `["{{ include \"nd-common.fullname\" . }}"]` | A list of arguments passed into the command. These are run through the tpl function. |
| tests.connection.command | list | `["curl","--retry-connrefused","--retry","5"]` | The command used to trigger the test. |
| tests.connection.enabled | bool | `true` | Controls whether or not this Helm test component is enabled. |
| tests.connection.image.repository | string | `"curlimages/curl"` | Sets the image-name that will be used in the "connection" integration test. If this is left empty, then the .image.repository value will be used instead (and the .image.tag will also be used). By default, prefer the latest official version to handle cases where the app image provides either no curl binary or an outdated one. |
| tests.connection.image.tag | string | `nil` | Sets the tag that will be used in the "connection" integration test. If this is left empty, the default is "latest" |
| tolerations | list | `[]` |  |
| topologyKey | `string` | `"topology.kubernetes.io/zone"` | The topologyKey to use when asking Kubernetes to schedule the pods in a particular distribution. The default is to spread across zones evenly. Other options could be `kubernetes.io/hostname` to spread across EC2 instances, or `node.kubernetes.io/instance-type` to spread across instance types for example. |
| topologySkew | `int` | `1` | The maxSkew setting applied to the default TopologySpreadConstraint if `enableTopologySpread` is set to `true`. |
| topologySpreadConstraints | `string` | `[]` | An array of custom TopologySpreadConstraint settings applied to the PodSpec within the Deployment. Each of these TopologySpreadObjects should conform to the [`pod.spec.topologySpreadConstraints`](https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/#api) API - but the `labelSelector` field should be left out, it will be inserted automatically for you. |
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
| volumeMounts | list | `[]` | List of VolumeMounts that are applied to the application container - these must refer to volumes set in the `Values.volumes` parameter. |
| volumes | list | `[]` | A list of 'volumes' that can be mounted into the Pod. See https://kubernetes.io/docs/concepts/storage/volumes/. |
| volumesString | string | `""` | A stringified list of 'volumes' similar to the `Values.volumes` parameter, but this one gets run through the `tpl` function so that you can use templatized values if you need to. See https://kubernetes.io/docs/concepts/storage/volumes/. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
