# prometheus-alerts

![Version: 0.2.3](https://img.shields.io/badge/Version-0.2.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

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
| containerRules.KubeDeploymentGenerationMismatch | object | `{"for":"15m","severity":"warning"}` | Deployment generation mismatch due to possible roll-back |
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
| containerRules.KubePodCrashLooping | object | `{"for":"15m","severity":"warning"}` | Pod is crash looping |
| containerRules.KubePodNotReady | object | `{"for":"15m","severity":"warning"}` | Pod has been in a non-ready state for more than a specific threshold |
| containerRules.KubeStatefulSetGenerationMismatch.for | string | `"15m"` |  |
| containerRules.KubeStatefulSetGenerationMismatch.severity | string | `"warning"` |  |
| containerRules.KubeStatefulSetReplicasMismatch.for | string | `"15m"` |  |
| containerRules.KubeStatefulSetReplicasMismatch.severity | string | `"warning"` |  |
| containerRules.KubeStatefulSetUpdateNotRolledOut.for | string | `"15m"` |  |
| containerRules.KubeStatefulSetUpdateNotRolledOut.severity | string | `"warning"` |  |
| containerRules.PodContainerOOMKilled | object | `{"for":"1m","over":"60m","severity":"warning","threshold":0}` | Sums up all of the OOMKilled events per pod over the $over time (60m). If that number breaches the $threshold (0) for $for (1m), then it will alert. |
| containerRules.PodContainerTerminated | object | `{"for":"1m","over":"10m","reasons":["ContainerCannotRun","DeadlineExceeded"],"severity":"warning","threshold":0}` | Monitors Pods for Containers that are terminated either for unexpected reasons like ContainerCannotRun. If that number breaches the $threshold (1) for $for (1m), then it will alert. |
| containerRules.enabled | bool | `true` | Whether or not to enable the container rules template |
| defaults.additionalRuleLabels | object | `{}` | Additional custom labels attached to every PrometheusRule |
| defaults.runbookUrl | string | `"https://github.com/Nextdoor/k8s-charts/blob/main/charts/prometheus-alerts/runbook.md"` | The prefix URL to the runbook_urls that will be applied to each PrometheusRule |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)
