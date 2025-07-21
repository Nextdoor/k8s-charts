{{/*
Expand the name of the chart.
*/}}
{{- define "nd-common.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "nd-common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nd-common.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create a container name.
*/}}
{{- define "nd-common.containerName" -}}
{{- default .Chart.Name .Values.containerName | trunc 63 | trimSuffix "-" }}
{{- end }}


{{- /*
Common labels

*app.kubernetes.io/<labels>*
https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/

*version*
Istio recommends a generic "version" label, but we also think its just
a nice generic label to add on top of the standard app.kubernetes.io/version
label.

*tags.datadoghq.com/<labels>*
https://docs.datadoghq.com/getting_started/tagging/unified_service_tagging/?tab=kubernetes
*/}}
{{- define "nd-common.labels" -}}
{{- $_tag := include "nd-common.imageTag" . }}
{{- $tag  := $_tag | replace "@" "_" | replace ":" "_" | trunc 63 | quote -}}
helm.sh/chart: {{ include "nd-common.chart" . }}
app.kubernetes.io/version: {{ $tag }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "nd-common.datadogLabels" . }}
{{ include "nd-common.selectorLabels" . }}
{{ include "nd-common.goldilocksLabels" . }}
{{- end }}

{{/*
Selector labels - two functions here:
  * one for "matchLabels"
  * one for "matchExpressions"
*/}}
{{- define "nd-common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nd-common.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
{{- define "nd-common.selectorLabelsExpression" -}}
- key: app.kubernetes.io/name
  operator: In
  values: [{{ include "nd-common.name" . }}]
- key: app.kubernetes.io/instance
  operator: In
  values: [{{ .Release.Name }}]
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "nd-common.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "nd-common.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*

Gathers the application image tag. This allows overriding the tag with a master
`forceTag` setting, as well as the more common mechanism of setting the `tag`
setting.

*/}}
{{- define "nd-common.imageTag" -}}
{{- if .Values.image -}}
{{- default .Chart.AppVersion (default .Values.image.tag .Values.image.forceTag) }}
{{- else -}}
{{ .Chart.AppVersion }}
{{- end -}}
{{- end -}}

{{/*

Generates a fully qualified Docker image name.

*/}}
{{- define "nd-common.imageFqdn" -}}
{{- $tag := include "nd-common.imageTag" . }}
{{- if hasPrefix "sha256:" $tag }}
{{- .Values.image.repository }}@{{ $tag }}
{{- else }}
{{- .Values.image.repository }}:{{ $tag }}
{{- end }}
{{- end }}

{{/*
overrideCommonLabels

Merges user-defined override labels into a standard set of base labels.

The base labels come from the "nd-common.labels" template, which includes:
- Standard Kubernetes labels like `app.kubernetes.io/version`
- Helm metadata like `helm.sh/chart` and `app.kubernetes.io/managed-by`
- Datadog labels via "nd-common.datadogLabels"
- Selector labels via "nd-common.selectorLabels"
- Goldilocks labels via "nd-common.goldilocksLabels"

Use this when you want to:
- Add custom labels such as `tags.datadoghq.com/service` or `taskworker.nextdoor.com/swimlane-name`
- Override existing labels dynamically using Helm templating (e.g., `releaseToken`)
- Maintain consistent labeling across resources while allowing per-resource customization

### Parameters (via dict):
- overrides: (required) A map of key-value label overrides.
             Values can include template expressions (evaluated using `tpl`).
- ctx:       (required) The Helm context to use for rendering `tpl`.
             Typically passed as the root context (`$`).

### Example usage:
```yaml
labels:
  {{- include "nd-common.overrideCommonLabels" (dict
        "ctx" $
        "overrides" (dict
          "tags.datadoghq.com/service" (printf "nextdoor-%s-tw" $id)
          "tags.datadoghq.com/version" ($.Values.parameters.releaseToken | default "release")
        )
    ) | nindent 4 }}
*/}}

{{- define "nd-common.overrideCommonLabels" -}}

{{- /* Get the context from .ctx (usually $) to access .Values, .Release, etc. */ -}}
{{- $ctx := .ctx }}

{{- /*
Compute the base labels using the "nd-common.labels" template,
which returns standardized labels such as:
  - app.kubernetes.io/version
  - tags.datadoghq.com/service
  - helm.sh/chart
  - and other selectors

The output of "nd-common.labels" is a multi-line YAML string,
so we parse it with `fromYaml` to convert it into a map
that we can merge overrides into.
*/ -}}
{{- $base := include "nd-common.labels" $ctx | fromYaml }}

{{- /* Get the overrides map from input */ -}}
{{- $overrides := .overrides }}

{{- /* Create a copy of the base labels so we don't accidentally change the original */ -}}
{{- $merged := deepCopy $base }}

{{- /*
Go through each override label.
Render its value as a template using the root context,
then add it to the merged labels.
*/ -}}
{{- range $k, $v := $overrides }}
{{- $_ := set $merged $k (tpl $v $ctx) }}
{{- end }}

{{- /* Output the merged labels as valid YAML */ -}}
{{ toYaml $merged }}

{{- end }}
