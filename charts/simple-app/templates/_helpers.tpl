{{/*
Expand the name of the chart.
*/}}
{{- define "simple-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

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

{{/*
Common labels
*/}}
{{- define "simple-app.labels" -}}
{{- $tag := default .Chart.AppVersion .Values.image.tag -}}
helm.sh/chart: {{ include "simple-app.chart" . }}
app.kubernetes.io/version: {{ $tag | replace ":" "_" | trunc 63 | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "simple-app.selectorLabels" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "simple-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "simple-app.name" . }}
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
{{- $tag := default .Chart.AppVersion .Values.image.tag }}
{{- if hasPrefix "sha256:" $tag }}
{{- .Values.image.repository }}@{{ $tag }}
{{- else }}
{{- .Values.image.repository }}:{{ $tag }}
{{- end }}
{{- end }}

{{- define "simple-app.proxyImageFqdn" -}}
{{- $tag := .Values.proxySidecar.image.tag }}
{{- if hasPrefix "sha256:" $tag }}
{{- .Values.proxySidecar.image.repository }}@{{ $tag }}
{{- else }}
{{- .Values.proxySidecar.image.repository }}:{{ $tag }}
{{- end }}
{{- end }}
