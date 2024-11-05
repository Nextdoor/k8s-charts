{{- define "datadog-monitors.shared-tags" -}}
- "service:{{ default $.Release.Name .Values.serviceName }}"
- "namespace:{{ .Release.Namespace }}"
{{- with .Values.team }}
- "team:{{ . }}"
{{- end }}
{{- end }}
