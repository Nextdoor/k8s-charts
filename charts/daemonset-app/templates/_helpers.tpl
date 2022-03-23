{{/*
Expand the name of the chart.
*/}}
{{- define "daemonset-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "daemonset-app.fullname" -}}
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
{{- define "daemonset-app.chart" -}}
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
{{- define "daemonset-app.labels" -}}
{{- $_tag := include "nd-common.imageTag" . }}
{{- $tag  := $_tag | replace "@" "_" | replace ":" "_" | trunc 63 | quote -}}
{{- if not (hasKey .Values.podLabels "app") }}
app: {{ .Release.Name }}
{{- end }}
version: {{ $tag }}
helm.sh/chart: {{ include "daemonset-app.chart" . }}
app.kubernetes.io/version: {{ $tag }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "daemonset-app.selectorLabels" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "daemonset-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "daemonset-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "daemonset-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "daemonset-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Proxy and Main App Image Names
*/}}
{{- define "daemonset-app.imageFqdn" -}}
{{- $tag := include "nd-common.imageTag" . }}
{{- if hasPrefix "sha256:" $tag }}
{{- .Values.image.repository }}@{{ $tag }}
{{- else }}
{{- .Values.image.repository }}:{{ $tag }}
{{- end }}
{{- end }}