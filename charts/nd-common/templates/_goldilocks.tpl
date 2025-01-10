{{/*

The "goldilocksLabels" function creates common Goldilocks labels that can be applied
to workloads(like: deployment, statefulset, etc...). These labels help configure the Goldilocks VPAs. This
function automatically checks if `.Values.datadog.enabled` is True, so you do
not need to add that logic into your template.

https://docs.datadoghq.com/getting_started/tagging/unified_service_tagging/?tab=kubernetes

*/}}
{{- define "nd-common.goldilocksLabels" -}}
{{- with .Values.goldilocks }}
{{- if .enabled -}}
goldilocks.fairwinds.com/enabled: "true"
goldilocks.fairwinds.com/vpa-update-mode: {{ default "off" .updateMode | quote }}
{{- end }}
{{- end }}