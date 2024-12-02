{{/*
This function generates an extended set of labels by combining the base labels 
from the "nd-common.labels" template with additional custom labels. 

The additional labels include:
  - helm.chart/name: Specifies the name of the chart (hardcoded as "daemonset-app").
  - helm.chart/version: Includes the chart version dynamically from .Chart.Version.
*/}}
{{- define "daemonset-app.labels" -}}
{{- $baseLabels := include "nd-common.labels" . | fromYaml -}}
{{- $extendedLabels := merge $baseLabels (dict
    "helm.chart/name" "daemonset-app"
    "helm.chart/version" .Chart.Version
) -}}
{{- $extendedLabels | toYaml -}}
{{- end -}}