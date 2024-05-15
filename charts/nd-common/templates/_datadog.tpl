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
{{- /*
This is datadog logging configuration. If source and service tag values not provided
we add default values to it.
*/ -}}
{{- if and .Values.datadog.enabled .Values.datadog.scrapeLogs.enabled }}
ad.datadoghq.com/{{ include "nd-common.containerName" . }}.logs: |-
  [
    {
      "source": {{ default .Chart.Name .Values.datadog.scrapeLogs.source | quote }},
      "service": {{ default .Chart.Name .Values.datadog.service | quote }},
      "log_processing_rules": {{ tpl (toJson .Values.datadog.scrapeLogs.processingRules) $ }}
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
{{- if .Values.datadog }}
{{- $_tag := include "nd-common.imageTag" . -}}
{{- $tag  := $_tag | replace "@" "_" | replace ":" "_" | trunc 63 | quote -}}
{{- if .Values.datadog.enabled -}}
{{- with .Values.datadog.env -}}
tags.datadoghq.com/env: {{ . | quote }}
{{ end -}}
tags.datadoghq.com/service: {{ default .Release.Name .Values.datadog.service | quote }}
tags.datadoghq.com/version: {{ $tag }}
{{- end }}
{{- end }}
{{- end }}

{{/*

The "datadogEnv" function creates the default Environment variables that the
Datadog Client libraries want.

*/}}
{{- define "nd-common.datadogEnv" -}}
{{- if .Values.datadog.enabled -}}
# https://docs.datadoghq.com/developers/dogstatsd/?tab=kubernetes#origin-detection-over-udp
{{- if not .Values.datadog.disableEntityId }}
- name: DD_ENTITY_ID
  valueFrom:
    fieldRef:
      fieldPath: metadata.uid
{{- end }}
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
