# datadog-monitors

datadog monitor alerts template

![Version: 0.0.7](https://img.shields.io/badge/Version-0.0.7-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

## Sample datadog monitors:
```
serviceName: eks
team: cloudeng
monitors:
  failed-pods:
    enabled: false
    name: "[kubernetes] Monitor Kubernetes Failed Pods in Namespaces"
    message: "More than ten pods are failing in ({{kube_cluster_name.name}} cluster). \n The threshold of ten pods varies depending on your infrastructure. Change the threshold to suit your needs."
    priority: "2"
    query: "change(avg(last_5m),last_5m):sum:kubernetes_state.pod.status_phase{phase:failed} by {kube_cluster_name,kube_namespace} > 10"
    type: "query alert"
  datadog-log-alert-test:
    query: "logs(\"source:nagios AND status:error\").index(\"default\").rollup(\"count\").last(\"1h\") > 5"
    type: "log alert"
    name: "Test log alert made from DatadogMonitor"
    message: "1-2-3 testing"
    tags:
      test: datadog
      team: data
    priority: 5
    options:
      enableLogsSample: true
      evaluationDelay: 300
      includeTags: true
      locked: false
      notifyNoData: true
      noDataTimeframe: 30
      renotifyInterval: 1440

```

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../nd-common | nd-common | 0.5.4 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| monitors | `map[string]interface{}` | {} | List of monitors |
| monitors.resourceName | `map[string]interface{}` | {} | Required: monitor resource name, Required unique monitor resource name(needed to allow value overrides and used a datadog monitor resource name) |
| monitors.resourceName.enabled | `boolean` | true | Optional: whether to enable the monitor, defaults to true |
| monitors.resourceName.message | `string` | "" | Required: monitor message |
| monitors.resourceName.name | `string` | "" | Require: monitor name |
| monitors.resourceName.options | `map[string]interface{}` | {} | Optional: monitor options </br>Available options:</br> `thresholds.critical: "1"` # Optional: monitor critical threshold</br> `thresholds.warning: "0.28"` # Optional: monitor warning threshold</br> `evaluationDelay: 300` # Optional: Time in seconds to wait before evaluating the monitor</br> `groupbySimpleMonitor:` false # Optional: A Boolean indicating Whether or not to group by simple monitor, triggers a single alert or multiple alerts when any group breaches the threshold.</br> `includeTags: false` # Optional: A Boolean indicating whether notifications from this monitor automatically insert its triggering tags into the title.</br> `newGroupDelay: 300` # Optional: Time in seconds to allow a host to boot and applications to fully start before starting the evaluation.</br> `notifyNoData: false` # Optional: A Boolean indicating whether this monitor notifies when data stops reporting.</br> `noDataTimeframe: 30` # Optional: The number of minutes before a monitor notifies after data stops reporting. Datadog recommends at least 2x the monitor timeframe for metric alerts or 2 minutes for service checks. If omitted, 2x the evaluation timeframe is used for metric alerts, and 24 hours is used for service checks.</br> `renotifyInterval: 0` # Optional: The number of minutes after the last notification before a monitor re-notifies on the current status.</br> `renotifyOccurrences: 0` # Optional: The number of times re-notification messages should be sent on the current status at the provided re-notification interval.</br> `renotifyStatus: []` # Optional: The types of statuses for which re-notification messages should be sent(Valid values are alert, warn, no data).</br> `notifyBy: []` # Optional: List of labels indicating the granularity for a monitor to alert on. Only available for monitors with groupings.</br> `notifyAudit:` False # Optional: A Boolean indicating whether this monitor should notify when an event is audited.</br> `notifyTags: []` # Optional: List of tags to notify on this monitor.</br> `requireFullWindow:` false # Optional: A Boolean indicating whether this monitor requires full window of data before it will fire, We highly recommend you set this to false for sparse metrics, otherwise some evaluations are skipped.</br> `thresholdWindows.recoveryWindow: "10m"` # Optional: Describes how long an anomalous metric must be normal before the alert recovers.</br> `thresholdWindows.alertWindow: "5m"` Optional: Describes how long an anomalous metric must be anomalous before the alert fires. |
| monitors.resourceName.priority | `string` | "" | Optional: monitor piority |
| monitors.resourceName.query | `string` | "" | Required: monitor query |
| monitors.resourceName.tags | `map[string]string` | `[service:<servicename>, namespace:<namespace>]` | Optional: Additional monitor tags(will be added on top of the default tags:service, team, namespace) example:</br>   tags:</br>     tagname1: tagvalue1</br>     tagname2: tagvalue2</br> |
| monitors.resourceName.type | `string` | `"query alert"` | Optional: monitor type, if not specified will default to 'query alert' </br> Datadog monitor types to type values mapping:</br> - anomaly: `query alert`</br> - APM: `query alert` or `trace-analytics alert`</br> - composite: `composite`</br> - custom: `service check`</br> - forecast: `query alert`</br> - host: `service check`</br> - integration: `query alert` or `service check`</br> - live process: `process alert`</br> - logs: `log alert`</br> - metric: `query alert`</br> - network: `service check`</br> - outlier: `query alert`</br> - process: `service check`</br> - rum: `rum alert`</br> - SLO: `slo alert`</br> - watchdog: `event-v2 alert`</br> - event-v2: `event-v2 alert`</br> - audit: `audit alert`</br> - error-tracking: `error-tracking alert`</br> - database-monitoring: `database-monitoring alert`</br> - network-performance: `network-performance alert`</br> - service-discovery: `service-discovery alert` |
| serviceName | `string` | `nil` | Optional shared pagerduty service name for monitors, will turn to a tag for alerts - if not provided, the .Release.name will be used by default |
| team | `string` | `nil` | Optional shared pagerduty team name for monitors, will turn to a tag for alerts - if not provided, the tag will not be added |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)