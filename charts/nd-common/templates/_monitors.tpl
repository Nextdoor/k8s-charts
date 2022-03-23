{{/*
The monitoring port needs to be exposed on a Pod in order for Prometheus or
Datadog to scrape it. We automatically open that port up as long as
.Values.monitor.enabled and .Values.monitor.portNumber are set. We also use
this function to error out if the user tries to set the same Application and
Monitoring port number.
*/}}

{{- define "nd-common.monitorPodPorts" }}
{{- $monitoringPort := .Values.monitor.portNumber }}
{{- /* If no monitors are turned on, do not expose the port */ -}}
{{- if .Values.monitor.enabled -}}

{{- /* Loop through the exposed container ports and make sure none conflict with this metrics port */ -}}
{{- range .Values.ports }}
{{- if eq $monitoringPort .containerPort }}
{{- fail "You must set .Values.monitor.portNumber to a unique value that is not in any of the .Values.ports[].containerPort settings" }}
{{- end }}
{{- end }}

{{- /* Finally print out the monitoring port config */ -}}
- name: {{ .Values.monitor.portName }}
  containerPort: {{ .Values.monitor.portNumber }}
  protocol: TCP
{{- end }}
{{- end }}
  
{{/*

This function creates an optional `PodMonitor` resource for monitoring metrics
from our pods in Prometheus.

*/}}
{{- define "nd-common.podMonitor" }}
{{- if .Values.monitor.enabled }}
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: {{ include "nd-common.fullname" . }}
  {{- with .Values.monitor.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "nd-common.labels" . | nindent 4 }}
    {{- with .Values.monitor.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  sampleLimit: {{ default 25000 .Values.monitor.sampleLimit }}
  selector:
    matchLabels:
      {{- include "nd-common.selectorLabels" . | nindent 6 }}
  podMetricsEndpoints:
    - port: {{ .Values.monitor.portName }}
      path: {{ .Values.monitor.path }}
      scheme: {{ .Values.monitor.scheme }}
      {{- with .Values.monitor.interval }}
      interval: {{ . }}
      {{- end }}
      {{- with .Values.monitor.scrapeTimeout }}
      scrapeTimeout: {{ . }}
      {{- end }}
      relabelings:
        {{- if .Values.monitor.relabelings }}
        {{- toYaml .Values.monitor.relabelings | nindent 8 }}
        {{- else }}
        # Standard app.kubernetes.io labels: instance, name, version
        - regex: __meta_kubernetes_pod_label_(app_kubernetes_io_(instance|name|version))
          replacement: $1
          action: labelmap

        # Standard tags.datadoghq.com labels: service, version
        - regex: __meta_kubernetes_pod_label_(tags_datadoghq_com_(service|version))
          replacement: $1
          action: labelmap

        # Map the pod name into the pod_name label
        - sourceLabels: [__meta_kubernetes_pod_name]
          action: replace
          targetLabel: pod_name
        {{- end }}
      {{- with .Values.monitor.metricRelabelings }}
      metricRelabelings:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.monitor.tlsConfig }}
      tlsConfig:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}
{{- end }}
