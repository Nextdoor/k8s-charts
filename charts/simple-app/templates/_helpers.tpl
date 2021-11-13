{{/*
Expand the name of the chart.
*/}}
{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "simple-app.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "simple-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
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
{{- define "simple-app.labels" -}}
{{- $_tag := include "simple-app.imageTag" . }}
{{- $tag  := $_tag | replace ":" "_" | trunc 63 | quote -}}
{{- if not (hasKey .Values.podLabels "app") }}
app: {{ .Release.Name }}
{{- end }}
version: {{ $tag }}
helm.sh/chart: {{ include "simple-app.chart" . }}
app.kubernetes.io/version: {{ $tag }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "simple-app.selectorLabels" . }}
{{- if .Values.datadog.enabled }}
# https://docs.datadoghq.com/getting_started/tagging/unified_service_tagging/?tab=kubernetes
tags.datadoghq.com/env: {{ .Values.datadog.env | quote }}
tags.datadoghq.com/service: {{ default .Release.Name .Values.datadog.service | quote }}
tags.datadoghq.com/version: {{ $tag }}
{{- end }}
{{- end }}
{{- /*
https://docs.datadoghq.com/agent/cluster_agent/admission_controller/
(Disabled for now, here for future reference. Disabled because we can get
the same value through the Kubernetes downward API, which doesn't introduce
a potential Pod launching failure point.)
# admission.datadoghq.com/enabled: "true"
*/}}

{{/*
Selector labels
*/}}
{{- define "simple-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "simple-app.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "simple-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "simple-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Proxy and Main App Image Names
*/}}
{{- define "simple-app.imageFqdn" -}}
{{- $tag := include "simple-app.imageTag" . }}
{{- if hasPrefix "sha256:" $tag }}
{{- .Values.image.repository }}@{{ $tag }}
{{- else }}
{{- .Values.image.repository }}:{{ $tag }}
{{- end }}
{{- end }}

{{/*
Gathers the application image tag. This allows overriding the tag with a master
`forceTag` setting, as well as the more common mechanism of setting the `tag`
setting.
*/}}
{{- define "simple-app.imageTag" -}}
{{- default .Chart.AppVersion (default .Values.image.tag .Values.image.forceTag) }}
{{- end }}

{{- define "simple-app.proxyImageFqdn" -}}
{{- $tag := include "simple-app.imageTag" . }}
{{- if hasPrefix "sha256:" $tag }}
{{- .Values.proxySidecar.image.repository }}@{{ $tag }}
{{- else }}
{{- .Values.proxySidecar.image.repository }}:{{ $tag }}
{{- end }}
{{- end }}
