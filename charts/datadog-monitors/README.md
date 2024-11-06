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
| monitors | `map[string]interface{}` | `{"resourceName":{"enabled":false,"message":null,"name":null,"options":[],"priority":null,"query":null,"tags":[],"type":"query alert"}}` | List of monitors |
| monitors.resourceName | `map[string]interface{}` | `{"enabled":false,"message":null,"name":null,"options":[],"priority":null,"query":null,"tags":[],"type":"query alert"}` | Required: monitor resource name, Required unique monitor resource name(needed to allow value overrides and used a datadog monitor resource name) |
| monitors.resourceName.enabled | `boolean` | `false` | Optional: whether to enable the monitor, defaults to true |
| monitors.resourceName.message | `string` | `nil` | Required: monitor message example: message: "More than ten pods are failing in ({{kube_cluster_name.name}} cluster). \n The threshold of ten pods varies depending on your infrastructure. Change the threshold to suit your needs." |
| monitors.resourceName.name | `string` | `nil` | Require: monitor name example: name: "[kubernetes] Monitor Kubernetes Failed Pods in Namespaces" |
| monitors.resourceName.options | `map[string]interface{}` | `[]` | Optional: monitor options example: (`map[string]string`) Optional: monitor thresholds thresholds:   (`string`) Optional: monitor critical threshold   critical: "1"   (`string`) Optional: monitor warning threshold   warning: "0.28" (`string`) Optional: Time in seconds to wait before evaluating the monitor evaluationDelay: 300 (`boolean`) Optional: A Boolean indicating Whether or not to group by simple monitor, triggers a single alert or multiple alerts when any group breaches the threshold. groupbySimpleMonitor: false (`boolean`) Optional: A Boolean indicating whether notifications from this monitor automatically insert its triggering tags into the title. includeTags: False (`string`) Optional: Time in seconds to allow a host to boot and applications to fully start before starting the evaluation. newGroupDelay: 300 (`boolean`) Optional: A Boolean indicating whether this monitor notifies when data stops reporting. notifyNoData: False (`int`) Optional: The number of minutes before a monitor notifies after data stops reporting. Datadog recommends at least 2x the monitor timeframe for metric alerts or 2 minutes for service checks. If omitted, 2x the evaluation timeframe is used for metric alerts, and 24 hours is used for service checks. noDataTimeframe: 30 (`int`) Optional: The number of minutes after the last notification before a monitor re-notifies on the current status. renotifyInterval: 0 (`string[]`) Optional: The number of times re-notification messages should be sent on the current status at the provided re-notification interval. renotifyOccurrences: 0 (`string[]`) Optional: The types of statuses for which re-notification messages should be sent(Valid values are alert, warn, no data). renotifyStatus: [] (`string[]`) Optional: List of labels indicating the granularity for a monitor to alert on. Only available for monitors with groupings. notifyBy: [] (`boolean`) Optional: A Boolean indicating whether this monitor requires full window of data before it will fire, We highly recommend you set this to false for sparse metrics, otherwise some evaluations are skipped. requireFullWindow: false (`map[string]string`) Optional: Threshold windows to finetune alerting thresholdWindows:   (`string`) Optional: Describes how long an anomalous metric must be normal before the alert recovers.   recoveryWindow: "10m"   (`string`) Optional: Describes how long an anomalous metric must be anomalous before the alert fires.   alertWindow: "5m" |
| monitors.resourceName.priority | `string` | `nil` | Optional: monitor piority example: priority: "2" |
| monitors.resourceName.query | `string` | `nil` | Required: monitor query example: query: "change(avg(last_5m),last_5m):sum:kubernetes_state.pod.status_phase{phase:failed} by {kube_cluster_name,kube_namespace} > 10" |
| monitors.resourceName.tags | `map[string]string` | `[]` | Optional: Additional monitor tags(will be added on top of the default tags:service, team, namespace) example:   tags:     tagname1: tagvalue1     tagname2: tagvalue2 |
| monitors.resourceName.type | `string` | `"query alert"` | Optional: monitor type, if not specified will default to 'query alert' Datadog monitor types to type values mapping: - anomaly: `query alert` - APM: `query alert` or `trace-analytics alert` - composite: `composite` - custom: `service check` - forecast: `query alert` - host: `service check` - integration: `query alert` or `service check` - live process: `process alert` - logs: `log alert` - metric: `query alert` - network: `service check` - outlier: `query alert` - process: `service check` - rum: `rum alert` - SLO: `slo alert` - watchdog: `event-v2 alert` - event-v2: `event-v2 alert` - audit: `audit alert` - error-tracking: `error-tracking alert` - database-monitoring: `database-monitoring alert` - network-performance: `network-performance alert` - service-discovery: `service-discovery alert` |
| serviceName | `string` | `nil` | Optional shared pagerduty service name for monitors, will turn to a tag for alerts - if not provided, the .Release.name will be used by default |
| team | `string` | `nil` | Optional shared pagerduty team name for monitors, will turn to a tag for alerts - if not provided, the tag will not be added |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
