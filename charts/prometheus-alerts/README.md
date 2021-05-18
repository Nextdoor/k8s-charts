# prometheus-alerts

![Version: 0.1.4](https://img.shields.io/badge/Version-0.1.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

Helm Chart that provisions a series of common Prometheus Alerts

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| diranged | matt@nextdoor.com |  |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| alertManager.alertmanagerConfig | string | `"default"` | Which AlertManager should this config be picked up by? |
| alertManager.enabled | bool | `false` | Not enabled by default - flip this to true to enable this resource. |
| alertManager.groupBy | list | `["alertname","namespace"]` | The labels by which incoming alerts are grouped together. For example, multiple alerts coming in for cluster=A and alertname=LatencyHigh would be batched into a single group. To aggregate by all possible labels use the special value '...' as the sole label name, for example: group_by: ['...'] This effectively disables aggregation entirely, passing through all alerts as-is. This is unlikely to be what you want, unless you have a very low alert volume or your upstream notification system performs its own grouping. |
| alertManager.groupInterval | string | `"5m"` | How long to wait before sending a notification about new alerts that are added to a group of alerts for which an initial notification has already been sent. (Usually ~5m or more.) |
| alertManager.groupWait | string | `"30s"` | How long to initially wait to send a notification for a group of alerts. Allows to wait for an inhibiting alert to arrive or collect more initial alerts for the same group. (Usually ~0s to few minutes.) |
| alertManager.repeatInterval | string | `"1h"` | How long to wait before sending a notification again if it has already been sent successfully for an alert. (Usually ~3h or more). |
| chart_name | string | `"prometheus-rules"` |  |
| chart_source | string | `"https://github.com/Nextdoor/k8s-charts"` |  |
| containerRules.CPUThrottlingHigh.for | string | `"15m"` |  |
| containerRules.CPUThrottlingHigh.severity | string | `"warning"` |  |
| containerRules.CPUThrottlingHigh.threshold | int | `65` |  |
| containerRules.KubeContainerWaiting.for | string | `"1h"` |  |
| containerRules.KubeContainerWaiting.severity | string | `"warning"` |  |
| containerRules.KubeDaemonSetMisScheduled.for | string | `"15m"` |  |
| containerRules.KubeDaemonSetMisScheduled.severity | string | `"warning"` |  |
| containerRules.KubeDaemonSetNotScheduled.for | string | `"10m"` |  |
| containerRules.KubeDaemonSetNotScheduled.severity | string | `"warning"` |  |
| containerRules.KubeDaemonSetRolloutStuck.for | string | `"15m"` |  |
| containerRules.KubeDaemonSetRolloutStuck.severity | string | `"warning"` |  |
| containerRules.KubeDeploymentGenerationMismatch.for | string | `"15m"` |  |
| containerRules.KubeDeploymentGenerationMismatch.severity | string | `"warning"` |  |
| containerRules.KubeDeploymentReplicasMismatch.for | string | `"15m"` |  |
| containerRules.KubeDeploymentReplicasMismatch.severity | string | `"warning"` |  |
| containerRules.KubeHpaMaxedOut.for | string | `"15m"` |  |
| containerRules.KubeHpaMaxedOut.severity | string | `"warning"` |  |
| containerRules.KubeHpaReplicasMismatch.for | string | `"15m"` |  |
| containerRules.KubeHpaReplicasMismatch.severity | string | `"warning"` |  |
| containerRules.KubeJobCompletion.for | string | `"12h"` |  |
| containerRules.KubeJobCompletion.severity | string | `"warning"` |  |
| containerRules.KubeJobFailed.for | string | `"15m"` |  |
| containerRules.KubeJobFailed.severity | string | `"warning"` |  |
| containerRules.KubePodCrashLooping.for | string | `"15m"` |  |
| containerRules.KubePodCrashLooping.severity | string | `"warning"` |  |
| containerRules.KubePodNotReady.for | string | `"15m"` |  |
| containerRules.KubePodNotReady.severity | string | `"warning"` |  |
| containerRules.KubeStatefulSetGenerationMismatch.for | string | `"15m"` |  |
| containerRules.KubeStatefulSetGenerationMismatch.severity | string | `"warning"` |  |
| containerRules.KubeStatefulSetReplicasMismatch.for | string | `"15m"` |  |
| containerRules.KubeStatefulSetReplicasMismatch.severity | string | `"warning"` |  |
| containerRules.KubeStatefulSetUpdateNotRolledOut.for | string | `"15m"` |  |
| containerRules.KubeStatefulSetUpdateNotRolledOut.severity | string | `"warning"` |  |
| containerRules.PodContainerTerminated.for | string | `"10m"` |  |
| containerRules.PodContainerTerminated.reasons[0] | string | `"OOMKilled"` |  |
| containerRules.PodContainerTerminated.reasons[1] | string | `"Error"` |  |
| containerRules.PodContainerTerminated.reasons[2] | string | `"ContainerCannotRun"` |  |
| containerRules.PodContainerTerminated.severity | string | `"warning"` |  |
| containerRules.PodContainerTerminated.threshold | int | `0` |  |
| containerRules.enabled | bool | `true` | Whether or not to enable the container rules template |
| defaults.additionalRuleLabels | object | `{}` | Additional custom labels attached to every PrometheusRule |
| defaults.runbookUrl | string | `"https://github.com/Nextdoor/k8s-charts/blob/main/charts/prometheus-alerts/runbook.md"` | The prefix URL to the runbook_urls that will be applied to each PrometheusRule |
| namespaceRules.KubeQuotaAlmostFull.for | string | `"10m"` |  |
| namespaceRules.KubeQuotaAlmostFull.severity | string | `"warning"` |  |
| namespaceRules.KubeQuotaAlmostFull.threshold | int | `90` |  |
| namespaceRules.KubeQuotaFullyUsed.for | string | `"10m"` |  |
| namespaceRules.KubeQuotaFullyUsed.severity | string | `"critical"` |  |
| namespaceRules.KubeQuotaFullyUsed.threshold | int | `99` |  |
| namespaceRules.enabled | bool | `true` | Whether or not to enable the namespace rules template |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)
