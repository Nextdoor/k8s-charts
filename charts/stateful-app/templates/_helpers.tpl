{{- define "stateful-app.proxyImageFqdn" -}}
{{- $tag := .Values.proxySidecar.image.tag }}
{{- if hasPrefix "sha256:" $tag }}
{{- .Values.proxySidecar.image.repository }}@{{ $tag }}
{{- else }}
{{- .Values.proxySidecar.image.repository }}:{{ $tag }}
{{- end }}
{{- end }}

{{/*
This function generates an extended set of labels by combining the base labels 
from the "nd-common.labels" template with additional custom labels. 

The additional labels include:
  - helm.chart/name: Specifies the name of the chart (hardcoded as "stateful-app").
  - helm.chart/version: Includes the chart version dynamically from .Chart.Version.
*/}}
{{- define "stateful-app.labels" -}}
{{- $baseLabels := include "nd-common.labels" . | fromYaml -}}
{{- $extendedLabels := merge $baseLabels (dict
    "helm.sh/chartName" "stateful-app"
    "helm.sh/chartVersion" .Chart.Version
) -}}
{{- $extendedLabels | toYaml -}}
{{- end -}}