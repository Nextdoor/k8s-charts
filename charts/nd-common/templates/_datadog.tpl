{{/*

The "datadogAnnotations" function creates a series of datadog-specific
annotations. These annotations influence how the Datadog Agent might read the
metrics from the pods, collect logs, etc.

*/}}
{{- define "nd-common.datadogAnnotations" -}}
{{- /*

If the Datadog Agent is enabled, AND we're in an Istio Service Mesh, AND we
have been asked to scrape the metrics from the pod... _then_ we scrape the
metrics. Otherwise, we do not auto-populate Datadog with all of our application
metrics by default.
*/ -}}

{{- if and .Values.datadog.enabled .Values.monitor.enabled .Values.datadog.scrapeMetrics -}}
{{- $metricsToScrape := default "*" .Values.datadog.metricsToScrape -}}
ad.datadoghq.com/{{ .Chart.Name }}.check_names: '["prometheus"]'
ad.datadoghq.com/{{ .Chart.Name }}.init_configs: '[{}]'
ad.datadoghq.com/{{ .Chart.Name }}.instances: |-
  [
    {
      "prometheus_url": "{{ .Values.monitor.scheme }}://%%host%%:{{ .Values.monitor.portNumber }}{{ .Values.monitor.path }}",
      "namespace": "{{ .Values.datadog.metricsNamespace }}",
      "metrics": [ {{ join ", " .Values.datadog.metricsToScrape }} ]
    }
  ]
{{- end }}

{{/*
This is datalog logging configuration. We take the .Values.scrapeLogs and
.Values.scrapeLogsProcessingRules map and convert into list of objects converted
into json supported by datadog config. If source and service tag values not provided
we add default values to it.
*/}}

{{- if and .Values.datadog.enabled .Values.datadog.scrapeLogs.enabled }}
ad.datadoghq.com/{{ .Release.Name }}.logs: |-
  [
    {
      "source": {{- default .Release.Name .Values.datadog.scrapeLogs.source | toJson }},
      "service": {{- default .Release.Name .Values.datadog.service | toJson }},
      "log_processing_rules": {{- .Values.datadog.scrapeLogsProcessingRules | toJson }}
    }
  ]
{{- end }}

{{- end }}

{{/*

The "datadogLabels" function creates common Datadog labels that can be applied
to Pods. These labels help configure the Datadog Tracing libraries. This
function automatically checks if `.Values.datadog.enabled` is True, so you do
not need to add that logic into your template.

https://docs.datadoghq.com/getting_started/tagging/unified_service_tagging/?tab=kubernetes

*/}}
{{- define "nd-common.datadogLabels" -}}
{{- $_tag := include "nd-common.imageTag" . -}}
{{- $tag  := $_tag | replace "@" "_" | replace ":" "_" | trunc 63 | quote -}}
{{- if .Values.datadog.enabled -}}
{{- with .Values.datadog.env -}}
tags.datadoghq.com/env: {{ . | quote }}
{{- end }}
tags.datadoghq.com/service: {{ default .Release.Name .Values.datadog.service | quote }}
tags.datadoghq.com/version: {{ $tag }}
{{- end }}
{{- end }}

{{/*

The "datadogEnv" function creates the default Environment variables that the
Datadog Client libraries want.

*/}}
{{- define "nd-common.datadogEnv" -}}
{{- if .Values.datadog.enabled -}}
# https://www.datadoghq.com/blog/monitor-kubernetes-docker/#instrument-your-code-to-send-metrics-to-dogstatsd
- name: DOGSTATSD_HOST_IP
  valueFrom:
    fieldRef:
      fieldPath: status.hostIP
# https://docs.datadoghq.com/agent/docker/apm/?tab=standard#docker-apm-agent-environment-variables
- name: DD_AGENT_HOST
  valueFrom:
    fieldRef:
      fieldPath: status.hostIP
# https://docs.datadoghq.com/getting_started/tagging/unified_service_tagging/?tab=kubernetes#full-configuration
{{- if .Values.datadog.env }}
- name: DD_ENV
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['tags.datadoghq.com/env']
{{- end }}
- name: DD_SERVICE
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['tags.datadoghq.com/service']
- name: DD_VERSION
  valueFrom:
    fieldRef:
      fieldPath: metadata.labels['tags.datadoghq.com/version']
{{- end }}
{{- end }}
