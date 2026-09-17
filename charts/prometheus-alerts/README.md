# prometheus-alerts

Helm Chart that provisions a series of common Prometheus Alerts

![Version: 1.10.1](https://img.shields.io/badge/Version-1.10.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

[deployments]: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
[hpa]: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

This chart provides a default deployment for a simple application that operates
in a [Deployment][deployments]. The chart automatically configures various
defaults for you like the Kubernetes [Horizontal Pod Autoscaler][hpa].

## Important Note on Changs to this chart!

If you make changes to the queries in this chart, you must also go duplicate
those changes in the `charts/simple-app`, `charts/daemonset-app` and
`charts/stateful-app` charts.

## Upgrade Notes

### 1.10.0 -> 1.10.1

**NEW (opt-in): `KubeDeploymentLowAvailability`, a Deployment-level capacity
alert.**

Nothing changes for you on upgrade: the alert ships **disabled**. Its key is
commented out in `values.yaml`, and the rule is only rendered when the key is
present.

When enabled it fires once for a Deployment when fewer than `availableRatio` of
its desired replicas have been available for `for` **and** the pods it owns
restarted more than `restartThreshold` times in `restartWindow`.

#### What it is for

Sustained, severe capacity loss in a single Deployment: most of the desired
replicas are missing, and the pods that should be providing them keep
restarting. It reports that as one alert for the Deployment, which is what the
alerts that already exist cannot do:

- **The per-pod crash-loop alert** is keyed on the pod. A Deployment whose pods
  keep crashing produces a new alert identity for every replacement pod, and
  each one clears as soon as its pod is deleted. Accurate per pod, and unusable
  as a description of one workload-wide incident once a Deployment has more than
  a handful of replicas.
- **A generation or rollout-convergence alert** only asks whether the rollout
  converged. It says nothing about a converged Deployment running on a fraction
  of its replicas, it needs a long `for` so that healthy rollouts are not
  flagged, and it is noisy for workloads that are rescaled continuously.

This alert sits between the two and complements both: one alert per Deployment,
raised only when capacity has actually been lost.

#### What it is not

- **Not a rollout-failure detector.** A bad rollout that keeps enough replicas
  available never trips it, and neither does one whose pods fail without
  restarting - stuck `Pending`, image pull failures, admission rejections. Keep
  whatever rollout-progress alerting you have; this does not replace it.
- **Not a replacement for the per-pod alert.** Expect `PodCrashLoopBackOff`
  alongside it. That one names the failing pods; this one says the workload is
  not recovering.
- **Not something every chart consumer needs**, which is why it is off by
  default. If your Deployments are small, or the per-pod alert already gives you
  a volume of alerts you are happy with, leave it alone. It earns its place on
  large, frequently rescaled Deployments, where per-pod alerts are too granular
  to act on and a rollout-convergence alert is either too slow or too noisy.

#### Enabling it

Uncomment the block in `values.yaml`, or set it in your own values. The values
below are the recommended defaults; any subset can be changed:

```yaml
containerRules:
  deployments:
    KubeDeploymentLowAvailability:
      severity: warning
      for: 15m
      availableRatio: 0.5
      restartThreshold: 5
      restartWindow: 15m
      labels: {}
```

Because the key is commented out by default it does not appear in the generated
values table below; the block above is the reference. Removing the key again (or
setting it to `null`) disables the alert.

Things to know before you enable it:

- **Both halves of the condition are deliberate.** Low availability on its own
  is not evidence of failure: an autoscaler scale-up routinely leaves
  available/spec below the ratio for tens of minutes with zero restarts.
  Dropping the restart half would page on normal scaling.
- **It needs the `namespace_workload_pod:kube_pod_owner:relabel_nd` recording
  rule**, which maps a pod to its owning Deployment via the ReplicaSet and must
  be provided by the Prometheus that evaluates these rules. Without it the
  restart half of the expression is always empty and the alert silently never
  fires, so do not enable it unless your Prometheus has that rule.
- **Restarts are counted across every pod of the Deployment**, which is what
  lets the alert survive pod replacement.
- **A genuine recovery splits the episode.** If the Deployment recovers for
  longer than one evaluation and then fails again, you get two alerts. Wrapping
  the whole expression in `max_over_time((...)[30m:1m])` bridges gaps of up to
  30 minutes and turns such an episode into one alert, at the cost of resolving
  up to 30 minutes late. The rule ships without it; add it locally if the extra
  grouping is worth the delayed resolve to you.
- **`defaults.deploymentNameSelector: 'None'` disables this alert too.** The
  selector helper only tests truthiness, so the literal string `None` renders as
  `deployment=~"None"` and matches nothing. That is pre-existing behaviour for
  every Deployment alert in this chart, and `DeploymentSelectorValidity` fires
  when it happens.

### 1.9.x -> 1.10.x

**CHANGE: `PodCrashLoopBackOff` now uses a `max_over_time` lookback.**

`CrashLoopBackOff` is a *waiting* state, so a container that keeps restarting
(an OOM loop, for example) alternates between `CrashLoopBackOff` and `Running`
and its metric disappears on every restart. The alert used to fall out of
`pending` each time that happened, restarting its `for` timer, so a pod that was
plainly crash looping either never fired or fired and resolved over and over.

The alert expression now evaluates the metric through a `max_over_time` lookback
controlled by the new `containerRules.pods.PodCrashLoopBackOff.window` value
(default `5m`), which bridges those brief `Running` phases.

What changes for you after upgrading:

- Fewer and longer `PodCrashLoopBackOff` alerts for the same underlying crash
  loop, instead of a series of short ones.
- The alert resolves up to `window` after the last `CrashLoopBackOff`
  observation, so it can stay firing briefly after a real fix. The description
  annotation now says "within the last `<window>`" to make that explicit.
- A pod that is deleted while crash looping keeps its alert open for up to
  `window` after deletion, because the lookback still sees its last samples.
- `window` must be strictly shorter than `for`. The chart refuses to render
  otherwise, because a `window` at or above `for` lets a single
  `CrashLoopBackOff` observation page on its own.

### 1.6.x -> 1.7.x

**CHANGE: Default selectors changed to be more generic.**

We have changed the default selectors to be more generic. This means that if you
deploy multiple applications to the same namespace, and one of those
applications uses this chart, then by default all applications will be monitored
by these alerts. You can change this behavior by modifying the
.Values.defaults.*NameSelector regex values.

### 1.5.x -> 1.6.x

**CHANGE: The AlertSelectorValidity alert rules added.**

We have added a new metric which attempts to detect if you have misconfigured
your selectors. After upgrading, you may get alerted. You should respond to the
alert appropriately by reading the alert information and making changes to your
selectors.

### 1.4.x -> 1.5.x

**BREAKING: Values files schema has been updated to group alerts by resource type**

Motivation: We have regrouped alerts to be able to turn them on and off by
resource type.

As an example:

> Value `.Values.containerRules.ContainerWaiting` has been migrated to
> `.Values.containerRules.pods.ContainerWaiting`. Please update your values
> files.

The helm chart will produce errors if you do not migrate your values files.

### 1.1.x -> 1.2.x

**CHANGE: Resource Names have changed**

Due to hitting resource-name limits, the `prometheus-alerts.fullname` function
has been rewritten to follow more standard practices. Previously the names of
the `ExternalSecret` or `Secret` resources could be so long that they'd be
truncated and would no longer work properly, causing alerts to be lost.

See the `.Values.fullname` and `.Values.fullnameOverride` flags to help tune
your resource names.

### 0.2.x -> 1.0.x

**BREAKING: All PrometheusRules are now scoped to `.Release.Name` resources by default**

All of the `PrometheusRules` within this chart are now scoped to try to
narrowly match resources that have the {{ .Release.Name }} prefix. This means
that rather than looking at _all_ `Deployment` resources in a Namespace, we're
now only looking at deployment=~{{ .Release.Name }} by default now.

The motivation for this change is to allow the `prometheus-rules` chart to be
applied to each individual `Application` within a Namespace, without
conflicting.

This behavior can be tuned via the `defaults.podNameSelector`,
`defaults.jobNameSelector`, `defaults.deploymentNameSelector`,
`defaults.statefulsetNameSelector`, `defaults.daemonsetNameSelector` and
`defaults.hpaNameSelector` values below.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../nd-common | nd-common | 0.5.6 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| chart_name | string | `"prometheus-rules"` |  |
| chart_source | string | `"https://github.com/Nextdoor/k8s-charts"` |  |
| containerRules.daemonsets.DaemonsetSelectorValidity | object | `{"enabled":true,"for":"1h","labels":{},"severity":"warning"}` | Does a basic lookup using the defined selectors to see if we can see any info for a given selector. This is the "watcher for the watcher". If we get alerted by this, we likely have a bad selector and our alerts are not going to ever fire. |
| containerRules.daemonsets.KubeDaemonSetMisScheduled.for | string | `"15m"` |  |
| containerRules.daemonsets.KubeDaemonSetMisScheduled.labels | object | `{}` |  |
| containerRules.daemonsets.KubeDaemonSetMisScheduled.severity | string | `"warning"` |  |
| containerRules.daemonsets.KubeDaemonSetNotScheduled.for | string | `"10m"` |  |
| containerRules.daemonsets.KubeDaemonSetNotScheduled.labels | object | `{}` |  |
| containerRules.daemonsets.KubeDaemonSetNotScheduled.severity | string | `"warning"` |  |
| containerRules.daemonsets.KubeDaemonSetRolloutStuck.for | string | `"15m"` |  |
| containerRules.daemonsets.KubeDaemonSetRolloutStuck.labels | object | `{}` |  |
| containerRules.daemonsets.KubeDaemonSetRolloutStuck.severity | string | `"warning"` |  |
| containerRules.daemonsets.enabled | bool | `true` | Enables the DaemonSet resource rules |
| containerRules.deployments.DeploymentSelectorValidity | object | `{"enabled":true,"for":"1h","labels":{},"severity":"warning"}` | Does a basic lookup using the defined selectors to see if we can see any info for a given selector. This is the "watcher for the watcher". If we get alerted by this, we likely have a bad selector and our alerts are not going to ever fire. |
| containerRules.deployments.KubeDeploymentGenerationMismatch | object | `{"for":"15m","labels":{},"severity":"warning"}` | Deployment generation mismatch due to possible roll-back |
| containerRules.deployments.enabled | bool | `true` | Enables the Deployment resource rules |
| containerRules.enabled | bool | `true` | Whether or not to enable the container rules template |
| containerRules.hpas.HpaSelectorValidity | object | `{"enabled":true,"for":"1h","labels":{},"severity":"warning"}` | Does a basic lookup using the defined selectors to see if we can see any info for a given selector. This is the "watcher for the watcher". If we get alerted by this, we likely have a bad selector and our alerts are not going to ever fire. |
| containerRules.hpas.KubeHpaMaxedOut.for | string | `"15m"` |  |
| containerRules.hpas.KubeHpaMaxedOut.labels | object | `{}` |  |
| containerRules.hpas.KubeHpaMaxedOut.severity | string | `"warning"` |  |
| containerRules.hpas.KubeHpaReplicasMismatch.for | string | `"15m"` |  |
| containerRules.hpas.KubeHpaReplicasMismatch.labels | object | `{}` |  |
| containerRules.hpas.KubeHpaReplicasMismatch.severity | string | `"warning"` |  |
| containerRules.hpas.enabled | bool | `true` | Enables the HorizontalPodAutoscaler resource rules |
| containerRules.jobs.JobSelectorValidity | object | `{"enabled":true,"for":"1h","labels":{},"severity":"warning"}` | Does a basic lookup using the defined selectors to see if we can see any info for a given selector. This is the "watcher for the watcher". If we get alerted by this, we likely have a bad selector and our alerts are not going to ever fire. |
| containerRules.jobs.KubeJobCompletion.for | string | `"12h"` |  |
| containerRules.jobs.KubeJobCompletion.labels | object | `{}` |  |
| containerRules.jobs.KubeJobCompletion.severity | string | `"warning"` |  |
| containerRules.jobs.KubeJobFailed.for | string | `"15m"` |  |
| containerRules.jobs.KubeJobFailed.labels | object | `{}` |  |
| containerRules.jobs.KubeJobFailed.severity | string | `"warning"` |  |
| containerRules.jobs.enabled | bool | `true` | Enables the Job resource rules |
| containerRules.pods.CPUThrottlingHigh | object | `{"for":"15m","labels":{},"severity":"warning","threshold":5}` | Container is being throttled by the CGroup - needs more resources. This value is appropriate for applications that are highly sensitive to request latency. Insensitive workloads might need to raise this percentage to avoid alert noise. |
| containerRules.pods.ContainerWaiting.for | string | `"1h"` |  |
| containerRules.pods.ContainerWaiting.labels | object | `{}` |  |
| containerRules.pods.ContainerWaiting.severity | string | `"warning"` |  |
| containerRules.pods.PodContainerOOMKilled | object | `{"for":"1m","labels":{},"over":"60m","severity":"warning","threshold":0}` | Sums up all of the OOMKilled events per pod over the $over time (60m). If that number breaches the $threshold (0) for $for (1m), then it will alert. |
| containerRules.pods.PodContainerTerminated | object | `{"for":"1m","labels":{},"over":"10m","reasons":["ContainerCannotRun","DeadlineExceeded"],"severity":"warning","threshold":0}` | Monitors Pods for Containers that are terminated either for unexpected reasons like ContainerCannotRun. If that number breaches the $threshold (1) for $for (1m), then it will alert. |
| containerRules.pods.PodCrashLoopBackOff | object | `{"for":"10m","labels":{},"severity":"warning","window":"5m"}` | Pod has been in a CrashLoopBackOff state and is not becoming healthy. |
| containerRules.pods.PodCrashLoopBackOff.window | string | `"5m"` | Lookback (`max_over_time`) that keeps this alert active across the brief Running phases of a crash loop. Must be strictly shorter than `for`. |
| containerRules.pods.PodNotReady | object | `{"for":"15m","labels":{},"severity":"warning"}` | Pod has been in a non-ready state for more than a specific threshold |
| containerRules.pods.PodSelectorValidity | object | `{"enabled":true,"for":"1h","labels":{},"severity":"warning"}` | Does a basic lookup using the defined selectors to see if we can see any info for a given selector. This is the "watcher for the watcher". If we get alerted by this, we likely have a bad selector and our alerts are not going to ever fire. |
| containerRules.pods.enabled | bool | `true` | Enables the Pod resource rules |
| containerRules.statefulsets.KubeStatefulSetGenerationMismatch.for | string | `"15m"` |  |
| containerRules.statefulsets.KubeStatefulSetGenerationMismatch.labels | object | `{}` |  |
| containerRules.statefulsets.KubeStatefulSetGenerationMismatch.severity | string | `"warning"` |  |
| containerRules.statefulsets.KubeStatefulSetReplicasMismatch.for | string | `"15m"` |  |
| containerRules.statefulsets.KubeStatefulSetReplicasMismatch.labels | object | `{}` |  |
| containerRules.statefulsets.KubeStatefulSetReplicasMismatch.severity | string | `"warning"` |  |
| containerRules.statefulsets.KubeStatefulSetUpdateNotRolledOut.for | string | `"15m"` |  |
| containerRules.statefulsets.KubeStatefulSetUpdateNotRolledOut.labels | object | `{}` |  |
| containerRules.statefulsets.KubeStatefulSetUpdateNotRolledOut.severity | string | `"warning"` |  |
| containerRules.statefulsets.StatefulsetSelectorValidity | object | `{"enabled":true,"for":"1h","labels":{},"severity":"warning"}` | Does a basic lookup using the defined selectors to see if we can see any info for a given selector. This is the "watcher for the watcher". If we get alerted by this, we likely have a bad selector and our alerts are not going to ever fire. |
| containerRules.statefulsets.enabled | bool | `true` | Enables the StatefulSet resource rules |
| defaults.additionalRuleLabels | `map` | `{}` | Additional custom labels attached to every PrometheusRule |
| defaults.daemonsetNameSelector | `string` | `".*"` | Pattern used to scope down the DaemonSet alerts to pods that are part of this general application. Set to `None` if you want to disable this selector and apply the rules to all the DaemonSets in the namespace. This string is run through the `tpl` function. |
| defaults.deploymentNameSelector | `string` | `".*"` | Pattern used to scope down the Deployment alerts to pods that are part of this general application. Set to `None` if you want to disable this selector and apply the rules to all the Deployments in the namespace. This string is run through the `tpl` function. |
| defaults.grafanaUrl | `string` | `"https://grafana.corp.nextdoor.com"` | Base URL (no trailing slash) of the Grafana used for the pre-filled Loki `logs_url` deep-link on the Job alerts (`KubeJobFailed`, `KubeJobCompletion`). Opens Explore scoped to the Job's `cluster`, `k8s_namespace_name`, and `k8s_job_name`. The central Grafana's Loki holds every cluster's logs, so one host serves all environments. Empty disables it. |
| defaults.hpaNameSelector | `string` | `".*"` | Pattern used to scope down the HorizontalPodAutoscaler alerts to pods that are part of this general application. Set to `None` if you want to disable this selector and apply the rules to all the HorizontalPodAutoscalers in the namespace. This string is run through the `tpl` function. |
| defaults.jobNameSelector | `string` | `".*"` | Pattern used to scope down the alerts to only Jobs that are part of this general application. Set to `None` if you want to disable this selector and apply the rules to all Jobs in the namespace. This string is run through the `tpl` function. |
| defaults.podNameSelector | `string` | `".*"` | Pattern used to scope down the alerts to only Pods that are part of this general application. Set to `None` if you want to disable this selector and apply the rules to all Pods in the namespace. This string is run through the `tpl` function. |
| defaults.runbookUrl | `string` | `"https://github.com/Nextdoor/k8s-charts/blob/main/charts/prometheus-alerts/runbook.md"` | The prefix URL to the runbook_urls that will be applied to each PrometheusRule |
| defaults.statefulsetNameSelector | `string` | `".*"` | Pattern used to scope down the StatefulSet alerts to pods that are part of this general application. Set to `None` if you want to disable this selector and apply the rules to all the StatefulSets in the namespace. This string is run through the `tpl` function. |
| fullname | `string` | `nil` | Optional prefix to be used for naming all of the resources. If not supplied, then .Release.Name is used. The full name with this value is `.Chart.Name-.Release.Name`. |
| fullnameOverride | `string` | `nil` | Optional complete override for the entire fullname used by the resources in this chart. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
