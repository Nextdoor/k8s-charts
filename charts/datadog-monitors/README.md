# datadog-monitors

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

datadog monitor alerts template

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| scohen | <scohen@nextdoor.com> |  |

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../nd-common | nd-common | 0.3.6 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| monitors | `map[string]interface{}` | `{"resourceName":{"enabled":false,"message":"More than ten pods are failing in ({{kube_cluster_name.name}} cluster). \n The threshold of ten pods varies depending on your infrastructure. Change the threshold to suit your needs.","name":"[kubernetes] Monitor Kubernetes Failed Pods in Namespaces","options":{"evaluationDelay":300,"groupbySimpleMonitor":false,"includeTags":false,"newGroupDelay":300,"noDataTimeframe":30,"notifyBy":[],"notifyNoData":false,"renotifyInterval":0,"renotifyOccurrences":0,"renotifyStatus":[],"requireFullWindow":false,"thresholdWindows":{"alertWindow":"5m","recoveryWindow":"10m"},"thresholds":{"critical":"1","warning":"0.28"}},"priority":"2","query":"change(avg(last_5m),last_5m):sum:kubernetes_state.pod.status_phase{phase:failed} by {kube_cluster_name,kube_namespace} > 10","tags":{"tagname":"tagvalue"},"type":"query alert"}}` | List of monitors |
| monitors.resourceName | `map[string]interface{}` | `{"enabled":false,"message":"More than ten pods are failing in ({{kube_cluster_name.name}} cluster). \n The threshold of ten pods varies depending on your infrastructure. Change the threshold to suit your needs.","name":"[kubernetes] Monitor Kubernetes Failed Pods in Namespaces","options":{"evaluationDelay":300,"groupbySimpleMonitor":false,"includeTags":false,"newGroupDelay":300,"noDataTimeframe":30,"notifyBy":[],"notifyNoData":false,"renotifyInterval":0,"renotifyOccurrences":0,"renotifyStatus":[],"requireFullWindow":false,"thresholdWindows":{"alertWindow":"5m","recoveryWindow":"10m"},"thresholds":{"critical":"1","warning":"0.28"}},"priority":"2","query":"change(avg(last_5m),last_5m):sum:kubernetes_state.pod.status_phase{phase:failed} by {kube_cluster_name,kube_namespace} > 10","tags":{"tagname":"tagvalue"},"type":"query alert"}` | Required: monitor resource name, Required unique monitor resource name(needed to allow value overrides and used a datadog monitor resource name) |
| monitors.resourceName.enabled | `boolean` | `false` | Optional: whether to enable the monitor, defaults to true |
| monitors.resourceName.message | `string` | `"More than ten pods are failing in ({{kube_cluster_name.name}} cluster). \n The threshold of ten pods varies depending on your infrastructure. Change the threshold to suit your needs."` | Required: monitor message |
| monitors.resourceName.name | `string` | `"[kubernetes] Monitor Kubernetes Failed Pods in Namespaces"` | Require: monitor name |
| monitors.resourceName.options | `map[string]interface{}` | `{"evaluationDelay":300,"groupbySimpleMonitor":false,"includeTags":false,"newGroupDelay":300,"noDataTimeframe":30,"notifyBy":[],"notifyNoData":false,"renotifyInterval":0,"renotifyOccurrences":0,"renotifyStatus":[],"requireFullWindow":false,"thresholdWindows":{"alertWindow":"5m","recoveryWindow":"10m"},"thresholds":{"critical":"1","warning":"0.28"}}` | Optional: monitor options |
| monitors.resourceName.options.evaluationDelay | `string` | `300` | Optional: Time in seconds to wait before evaluating the monitor |
| monitors.resourceName.options.groupbySimpleMonitor | `boolean` | `false` | Optional: A Boolean indicating Whether or not to group by simple monitor, triggers a single alert or multiple alerts when any group breaches the threshold. |
| monitors.resourceName.options.includeTags | `boolean` | `false` | Optional: A Boolean indicating whether notifications from this monitor automatically insert its triggering tags into the title. |
| monitors.resourceName.options.newGroupDelay | `string` | `300` | Optional: Time in seconds to allow a host to boot and applications to fully start before starting the evaluation. |
| monitors.resourceName.options.noDataTimeframe | `int` | `30` | Optional: The number of minutes before a monitor notifies after data stops reporting. Datadog recommends at least 2x the monitor timeframe for metric alerts or 2 minutes for service checks. If omitted, 2x the evaluation timeframe is used for metric alerts, and 24 hours is used for service checks. |
| monitors.resourceName.options.notifyBy | `string[]` | `[]` | Optional: List of labels indicating the granularity for a monitor to alert on. Only available for monitors with groupings. |
| monitors.resourceName.options.notifyNoData | `boolean` | `false` | Optional: A Boolean indicating whether this monitor notifies when data stops reporting. |
| monitors.resourceName.options.renotifyInterval | `int` | `0` | Optional: The number of minutes after the last notification before a monitor re-notifies on the current status. |
| monitors.resourceName.options.renotifyOccurrences | `string[]` | `0` | Optional: The number of times re-notification messages should be sent on the current status at the provided re-notification interval. |
| monitors.resourceName.options.renotifyStatus | `string[]` | `[]` | Optional: The types of statuses for which re-notification messages should be sent(Valid values are alert, warn, no data). |
| monitors.resourceName.options.requireFullWindow | `boolean` | `false` | Optional: A Boolean indicating whether this monitor requires full window of data before it will fire, We highly recommend you set this to false for sparse metrics, otherwise some evaluations are skipped. |
| monitors.resourceName.options.thresholdWindows | `map[string]string` | `{"alertWindow":"5m","recoveryWindow":"10m"}` | Optional: Threshold windows to finetune alerting |
| monitors.resourceName.options.thresholdWindows.alertWindow | `string` | `"5m"` | Optional: Describes how long an anomalous metric must be anomalous before the alert fires. |
| monitors.resourceName.options.thresholdWindows.recoveryWindow | `string` | `"10m"` | Optional: Describes how long an anomalous metric must be normal before the alert recovers. |
| monitors.resourceName.options.thresholds | `map[string]string` | `{"critical":"1","warning":"0.28"}` | Optional: monitor thresholds |
| monitors.resourceName.options.thresholds.critical | `string` | `"1"` | Optional: monitor critical threshold |
| monitors.resourceName.options.thresholds.warning | `string` | `"0.28"` | Optional: monitor warning threshold |
| monitors.resourceName.priority | `string` | `"2"` | Optional: monitor piority |
| monitors.resourceName.query | `string` | `"change(avg(last_5m),last_5m):sum:kubernetes_state.pod.status_phase{phase:failed} by {kube_cluster_name,kube_namespace} > 10"` | Required: monitor query |
| monitors.resourceName.tags | `map[string]string` | `{"tagname":"tagvalue"}` | Optional: Additional monitor tags(will be added on top of the default tags:service, team, namespace) |
| monitors.resourceName.type | `string` | `"query alert"` | Optional: monitor type, if not specified will default to 'query alert' Datadog monitor types to type values mapping: - anomaly: `query alert` - APM: `query alert` or `trace-analytics alert` - composite: `composite` - custom: `service check` - forecast: `query alert` - host: `service check` - integration: `query alert` or `service check` - live process: `process alert` - logs: `log alert` - metric: `query alert` - network: `service check` - outlier: `query alert` - process: `service check` - rum: `rum alert` - SLO: `slo alert` - watchdog: `event-v2 alert` - event-v2: `event-v2 alert` - audit: `audit alert` - error-tracking: `error-tracking alert` - database-monitoring: `database-monitoring alert` - network-performance: `network-performance alert` - service-discovery: `service-discovery alert` |
| serviceName | `string` | `nil` | Optional shared pagerduty service name for monitors, will turn to a tag for alerts - if not provided, the .Release.name will be used by default |
| team | `string` | `nil` | Optional shared pagerduty team name for monitors, will turn to a tag for alerts - if not provided, the tag will not be added |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
