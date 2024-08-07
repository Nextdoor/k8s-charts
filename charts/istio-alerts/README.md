# istio-alerts

![Version: 0.5.3](https://img.shields.io/badge/Version-0.5.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A Helm chart that provisions a series of alerts for istio VirtualServices

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| diranged | <matt@nextdoor.com> |  |
| laikan57 | <akennedy@nextdoor.com> |  |

## Upgrade Notes

### 0.3.x -> 0.4.x

**BREAKING: http5XXMonitor no longer alerts per source client workload.**

In version 0.2.x, there was a change to the default `http5XXMonitor` which
introduced calculation of the error rate per source workload. This 0.4.x
release reverts this behavior by default while allowing you to opt in to custom
selectors via the `monitorGroupingLabels` option.

### 0.2.x -> 0.3.x

**BREAKING: The DestinationServiceSelectorValidity alert rule requires kube-state-metrics.**

An alert was introduced in 0.3.x that requires kube-state-metrics to be installed in the cluster. If
you do not have kube-state-metrics installed, you will need to disable the alert by setting
`serviceRules.destinationServiceSelectorValidity.enabled` to `false`. This alert is used to detect
if the destinationServiceSelector is actually selecting series for a service that exists.

### 0.2.x

**BREAKING: http5XXMonitor now calculcates the 5XX error rate for each client**
source workload using the `source_workload` label, and will alert if any
`source_workload`'s error rate exceeds the specified `threshold`.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| chart_name | string | `"istio-alerts"` |  |
| chart_source | string | `"https://github.com/Nextdoor/k8s-charts"` |  |
| defaults.additionalRuleLabels | object | `{}` | Additional custom labels attached to every PrometheusRule |
| defaults.runbookUrl | string | `"https://github.com/Nextdoor/k8s-charts/blob/main/charts/istio-alerts/runbook.md"` | The prefix URL to the runbook_urls that will be applied to each PrometheusRule |
| serviceRules.destinationServiceName | string | `".*"` | Narrow down the alerts to a particular Destination Service if there are multiple services that require different thresholds within the same namespace. |
| serviceRules.destinationServiceSelectorValidity | object | `{"enabled":true,"for":"1h","severity":"warning"}` | Does a basic lookup using the defined selectors to see if we can see any info for a given selector. This is the "watcher for the watcher". If we get alerted by this, we likely have a bad selector and our alerts are not going to ever fire. |
| serviceRules.destinationServiceSelectorValidity.enabled | bool | `true` | Whether to enable the monitor on the selector for the VirtualService. |
| serviceRules.destinationServiceSelectorValidity.for | string | `"1h"` | How long to evaluate. |
| serviceRules.destinationServiceSelectorValidity.severity | string | `"warning"` | Severity of the monitor |
| serviceRules.enabled | bool | `true` | Whether to enable the service rules template |
| serviceRules.highRequestLatency | object | `{"enabled":true,"for":"15m","percentile":0.95,"severity":"warning","threshold":0.5}` | Configuration related to the latency monitor for the VirtualService. |
| serviceRules.highRequestLatency.enabled | bool | `true` | Whether to enable the monitor on latency returned by the VirtualService. |
| serviceRules.highRequestLatency.for | string | `"15m"` | How long to evaluate the latency of services. |
| serviceRules.highRequestLatency.percentile | float | `0.95` | Which percentile to monitor - should be between 0 and 1. Default is 95th percentile. |
| serviceRules.highRequestLatency.severity | string | `"warning"` | Severity of the latency monitor |
| serviceRules.highRequestLatency.threshold | float | `0.5` | The threshold for considering the latency monitor to be alarming. This is in seconds. |
| serviceRules.http5XXMonitor | object | `{"enabled":true,"for":"5m","monitorGroupingLabels":["destination_service_name","reporter"],"severity":"critical","threshold":0.0005}` | Configuration related to the 5xx monitor for the VirtualService. |
| serviceRules.http5XXMonitor.enabled | bool | `true` | Whether to enable the monitor on 5xxs returned by the VirtualService. |
| serviceRules.http5XXMonitor.for | string | `"5m"` | How long to evaluate the rate of 5xxs over. |
| serviceRules.http5XXMonitor.monitorGroupingLabels | list | `["destination_service_name","reporter"]` | The set of labels to use when evaluating the ratio of the 5XX. |
| serviceRules.http5XXMonitor.severity | string | `"critical"` | Severity of the 5xx monitor |
| serviceRules.http5XXMonitor.threshold | float | `0.0005` | The threshold for considering the 5xx monitor to be alarming. Default is 0.05% error rate, i.e 99.95% reliability. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
