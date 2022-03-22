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
