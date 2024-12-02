{{/*
Gathers the application image tag. This allows overriding the tag with a master
`forceTag` setting, as well as the more common mechanism of setting the `tag`
setting.
*/}}
{{- define "simple-app.proxyImageFqdn" -}}
{{- $tag := .Values.proxySidecar.image.tag | default (include "nd-common.imageTag" .) }}
{{- if hasPrefix "sha256:" $tag }}
{{- .Values.proxySidecar.image.repository }}@{{ $tag }}
{{- else }}
{{- .Values.proxySidecar.image.repository }}:{{ $tag }}
{{- end }}
{{- end }}

{{- define "nd-common.extendedLabels" -}}
{{- $baseLabels := include "nd-common.labels" . | fromYaml -}}
{{- $extendedLabels := merge $baseLabels (dict
    "helm.chart.simple-app/version" .Chart.Version
) -}}
{{- $extendedLabels | toYaml -}}
{{- end -}}




