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
