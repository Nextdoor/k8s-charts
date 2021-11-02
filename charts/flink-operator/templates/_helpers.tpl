{{- define "flink-operator.imageFqdn" -}}
{{- $tag := default .Chart.AppVersion .Values.image.tag }}
{{- if hasPrefix "sha256:" $tag }}
{{- .Values.image.repository }}@{{ $tag }}
{{- else }}
{{- .Values.image.repository }}:{{ $tag }}
{{- end }}
{{- end }}
