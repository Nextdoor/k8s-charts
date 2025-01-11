{{/*

The "goldilocksLabels" function creates common Goldilocks labels that can be applied
to workloads(like: deployment, statefulset, etc...). These labels help configure the Goldilocks VPAs. This
function automatically checks if `.Values.goldilocks.enabled` is True, so you do
not need to add that logic into your template.

https://goldilocks.docs.fairwinds.com/advanced/#cli-usage-not-recommended

*/}}
{{- define "nd-common.goldilocksLabels" -}}
{{- with .Values.goldilocks }}
{{- if .enabled -}}
goldilocks.fairwinds.com/enabled: "true"
goldilocks.fairwinds.com/vpa-update-mode: {{ default "off" .updateMode | quote }}
{{- end }}
{{- end }}
