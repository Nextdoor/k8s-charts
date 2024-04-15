
# prometheus-alerts

Helm Chart that provisions a series of common Prometheus Alerts

![Version: 1.5.0](https://img.shields.io/badge/Version-1.5.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

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

### 1.4.x -> 1.5.x

**NOTE: New metrics added**

We have added a new metric which attempts to detect if you have misconfigured
your selectors. After upgrading, you may get alerted. You should respond to the
alert appropriately by reading the alert information and making changes to your
selectors.

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
| file://../nd-common | nd-common | 0.3.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| alertManager.alertmanagerConfig | string | `"default"` | Which AlertManager should this config be picked up by? |
| alertManager.enabled | bool | `false` | Not enabled by default - flip this to true to enable this resource. |
| alertManager.groupBy | list | `["alertname","namespace"]` | The labels by which incoming alerts are grouped together. For example, multiple alerts coming in for cluster=A and alertname=LatencyHigh would be batched into a single group.  To aggregate by all possible labels use the special value '...' as the sole label name, for example:  group_by: ['...'] This effectively disables aggregation entirely, passing through all alerts as-is. This is unlikely to be what you want, unless you have a very low alert volume or your upstream notification system performs its own grouping.  |
| alertManager.groupInterval | string | `"5m"` | How long to wait before sending a notification about new alerts that are added to a group of alerts for which an initial notification has already been sent. (Usually ~5m or more.) |
| alertManager.groupWait | string | `"30s"` | How long to initially wait to send a notification for a group of alerts. Allows to wait for an inhibiting alert to arrive or collect more initial alerts for the same group. (Usually ~0s to few minutes.) |
| alertManager.repeatInterval | string | `"1h"` | How long to wait before sending a notification again if it has already been sent successfully for an alert. (Usually ~3h or more). |
| chart_name | string | `"prometheus-rules"` |  |
| chart_source | string | `"https://github.com/Nextdoor/k8s-charts"` |  |
| containerRules.AlertRulesSelectorsValidity | object | `{"for":"1h","severity":"warning"}` | Does a basic lookup using the defined selectors to see if we can see any info for a given selector. This is the "watcher for the watcher". If we get alerted by this, we likely have a bad selector and our alerts are not going to ever fire. |
| containerRules.CPUThrottlingHigh | object | `{"for":"15m","severity":"warning","threshold":5}` | Container is being throttled by the CGroup - needs more resources. This value is appropriate for applications that are highly sensitive to request latency. Insensitive workloads might need to raise this percentage to avoid alert noise. |
| containerRules.ContainerWaiting.for | string | `"1h"` |  |
| containerRules.ContainerWaiting.severity | string | `"warning"` |  |
| containerRules.KubeDaemonSetMisScheduled.for | string | `"15m"` |  |
| containerRules.KubeDaemonSetMisScheduled.severity | string | `"warning"` |  |
| containerRules.KubeDaemonSetNotScheduled.for | string | `"10m"` |  |
| containerRules.KubeDaemonSetNotScheduled.severity | string | `"warning"` |  |
| containerRules.KubeDaemonSetRolloutStuck.for | string | `"15m"` |  |
| containerRules.KubeDaemonSetRolloutStuck.severity | string | `"warning"` |  |
| containerRules.KubeDeploymentGenerationMismatch | object | `{"for":"15m","severity":"warning"}` | Deployment generation mismatch due to possible roll-back |
| containerRules.KubeHpaMaxedOut.for | string | `"15m"` |  |
| containerRules.KubeHpaMaxedOut.severity | string | `"warning"` |  |
| containerRules.KubeHpaReplicasMismatch.for | string | `"15m"` |  |
| containerRules.KubeHpaReplicasMismatch.severity | string | `"warning"` |  |
| containerRules.KubeJobCompletion.for | string | `"12h"` |  |
| containerRules.KubeJobCompletion.severity | string | `"warning"` |  |
| containerRules.KubeJobFailed.for | string | `"15m"` |  |
| containerRules.KubeJobFailed.severity | string | `"warning"` |  |
| containerRules.KubeStatefulSetGenerationMismatch.for | string | `"15m"` |  |
| containerRules.KubeStatefulSetGenerationMismatch.severity | string | `"warning"` |  |
| containerRules.KubeStatefulSetReplicasMismatch.for | string | `"15m"` |  |
| containerRules.KubeStatefulSetReplicasMismatch.severity | string | `"warning"` |  |
| containerRules.KubeStatefulSetUpdateNotRolledOut.for | string | `"15m"` |  |
| containerRules.KubeStatefulSetUpdateNotRolledOut.severity | string | `"warning"` |  |
| containerRules.PodContainerOOMKilled | object | `{"for":"1m","over":"60m","severity":"warning","threshold":0}` | Sums up all of the OOMKilled events per pod over the $over time (60m). If that number breaches the $threshold (0) for $for (1m), then it will alert. |
| containerRules.PodContainerTerminated | object | `{"for":"1m","over":"10m","reasons":["ContainerCannotRun","DeadlineExceeded"],"severity":"warning","threshold":0}` | Monitors Pods for Containers that are terminated either for unexpected reasons like ContainerCannotRun. If that number breaches the $threshold (1) for $for (1m), then it will alert. |
| containerRules.PodCrashLoopBackOff | object | `{"for":"10m","severity":"warning"}` | Pod is in a CrashLoopBackOff state and is not becoming healthy. |
| containerRules.PodNotReady | object | `{"for":"15m","severity":"warning"}` | Pod has been in a non-ready state for more than a specific threshold |
| containerRules.enabled | bool | `true` | Whether or not to enable the container rules template |
| defaults.additionalRuleLabels | `map` | `{}` | Additional custom labels attached to every PrometheusRule |
| defaults.daemonsetNameSelector | `string` | `"{{ .Release.Name }}-.*"` | Pattern used to scope down the DaemonSet alerts to pods that are part of this general application. Set to `None` if you want to disable this selector and apply the rules to all the DaemonSets in the namespace. This string is run through the `tpl` function. |
| defaults.deploymentNameSelector | `string` | `"{{ .Release.Name }}-.*"` | Pattern used to scope down the Deployment alerts to pods that are part of this general application. Set to `None` if you want to disable this selector and apply the rules to all the Deployments in the namespace. This string is run through the `tpl` function. |
| defaults.hpaNameSelector | `string` | `"{{ .Release.Name }}-.*"` | Pattern used to scope down the HorizontalPodAutoscaler alerts to pods that are part of this general application. Set to `None` if you want to disable this selector and apply the rules to all the HorizontalPodAutoscalers in the namespace. This string is run through the `tpl` function. |
| defaults.jobNameSelector | `string` | `"{{ .Release.Name }}-.*"` | Pattern used to scope down the alerts to only Jobs that are part of this general application. Set to `None` if you want to disable this selector and apply the rules to all Jobs in the namespace. This string is run through the `tpl` function. |
| defaults.podNameSelector | `string` | `"{{ .Release.Name }}-.*"` | Pattern used to scope down the alerts to only Pods that are part of this general application. Set to `None` if you want to disable this selector and apply the rules to all Pods in the namespace. This string is run through the `tpl` function. |
| defaults.runbookUrl | `string` | `"https://github.com/Nextdoor/k8s-charts/blob/main/charts/prometheus-alerts/runbook.md"` | The prefix URL to the runbook_urls that will be applied to each PrometheusRule |
| defaults.statefulsetNameSelector | `string` | `"{{ .Release.Name }}-.*"` | Pattern used to scope down the StatefulSet alerts to pods that are part of this general application. Set to `None` if you want to disable this selector and apply the rules to all the StatefulSets in the namespace. This string is run through the `tpl` function. |
| fullname | `string` | `nil` | Optional prefix to be used for naming all of the resources. If not supplied, then .Release.Name is used. The full name with this value is `.Chart.Name-.Release.Name`. |
| fullnameOverride | `string` | `nil` | Optional complete override for the entire fullname used by the resources in this chart. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
