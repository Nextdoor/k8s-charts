# istio-alerts

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

A Helm chart that provisions a series of alerts for istio VirtualServices

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| diranged | <matt@nextdoor.com> |  |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| alertManager.alertmanagerConfig | string | `"default"` | Which AlertManager should this config be picked up by? |
| alertManager.enabled | bool | `false` | Not enabled by default - flip this to true to enable this resource. |
| alertManager.groupBy | list | `["alertname","namespace"]` | The labels by which incoming alerts are grouped together. For example, multiple alerts coming in for cluster=A and alertname=LatencyHigh would be batched into a single group.  To aggregate by all possible labels use the special value '...' as the sole label name, for example:  group_by: ['...'] This effectively disables aggregation entirely, passing through all alerts as-is. This is unlikely to be what you want, unless you have a very low alert volume or your upstream notification system performs its own grouping.  |
| alertManager.groupInterval | string | `"5m"` | How long to wait before sending a notification about new alerts that are added to a group of alerts for which an initial notification has already been sent. (Usually ~5m or more.) |
| alertManager.groupWait | string | `"30s"` | How long to initially wait to send a notification for a group of alerts. Allows to wait for an inhibiting alert to arrive or collect more initial alerts for the same group. (Usually ~0s to few minutes.) |
| alertManager.repeatInterval | string | `"1h"` | How long to wait before sending a notification again if it has already been sent successfully for an alert. (Usually ~3h or more). |
| chart_name | string | `"istio-alerts"` |  |
| chart_source | string | `"https://github.com/Nextdoor/k8s-charts"` |  |
| defaults.additionalRuleLabels | object | `{}` | Additional custom labels attached to every PrometheusRule |
| defaults.runbookUrl | string | `"https://github.com/Nextdoor/k8s-charts/blob/main/charts/istio-alerts/runbook.md"` | The prefix URL to the runbook_urls that will be applied to each PrometheusRule |
| serviceRules.destinationServiceName | string | `".*"` | Narrow down the alerts to a particular Destination Service if there are multiple services that require different thresholds within the same namespace. |
| serviceRules.enabled | bool | `true` | Whether to enable the service rules template |
| serviceRules.highRequestLatency.enabled | bool | `true` | Whether to enable the monitor on latency returned by the VirtualService. |
| serviceRules.highRequestLatency.for | string | `"15m"` | How long to evaluate the latency of services. |
| serviceRules.highRequestLatency.percentile | float | `0.95` | Which percentile to monitor - should be between 0 and 1. Default is 95th percentile. |
| serviceRules.highRequestLatency.severity | string | `"warning"` | Severity of the latency monitor |
| serviceRules.highRequestLatency.threshold | float | `0.5` | The threshold for considering the latency monitor to be alarming. This is in seconds. |
| serviceRules.http5XXMonitor | object | `{"enabled":true,"for":"5m","severity":"critical","threshold":0.0005}` | Configuration related to the 5xx monitor for the VirtualService. |
| serviceRules.http5XXMonitor.enabled | bool | `true` | Whether to enable the monitor on 5xxs returned by the VirtualService. |
| serviceRules.http5XXMonitor.for | string | `"5m"` | How long to evaluate the rate of 5xxs over. |
| serviceRules.http5XXMonitor.severity | string | `"critical"` | Severity of the 5xx monitor |
| serviceRules.http5XXMonitor.threshold | float | `0.0005` | The threshold for considering the 5xx monitor to be alarming. Default is 0.05% error rate, i.e 99.95% reliability. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
