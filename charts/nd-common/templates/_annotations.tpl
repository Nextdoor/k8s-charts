{{/*

The "podAnnotations" function includes a number of broadly useful annotations
that should be applied to Pod resources created by our charts.

*/}}
{{- define "nd-common.podAnnotations" -}}
kubectl.kubernetes.io/default-container: {{ include "nd-common.containerName" . }}
{{- with .Values.secrets }}
checksum/secrets: {{ toYaml . | sha256sum }}
{{- end }}
{{ include "nd-common.istioAnnotations" . }}
{{ include "nd-common.datadogAnnotations" . }}
{{- end }}
