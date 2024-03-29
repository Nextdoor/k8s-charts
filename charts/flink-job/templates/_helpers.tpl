{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "flink-job-cluster.name" -}}
{{- if .flavor -}}
{{- printf "%s-%s" (default .Chart.Name .Values.nameOverride) .flavor | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "flink-job-cluster.fullname" -}}
{{- if .flavor -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" .Values.fullnameOverride .flavor | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .flavor | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .flavor | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- else -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "flink-job-cluster.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "flink-job.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "flink-job.selectorLabels" -}}
app.kubernetes.io/name: {{ include "flink-job-cluster.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "flink-job.labels" -}}
{{- $_tag := default .Chart.AppVersion .Values.image.tag -}}
{{- $tag  := $_tag | replace "@" "_" | replace ":" "_" | trunc 63 | quote -}}
helm.sh/chart: {{ include "flink-job.chart" . }}
app.kubernetes.io/version: {{ $tag }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "flink-job.selectorLabels" . }}
{{- end }}

{{/*
Image name
*/}}
{{- define "flink-job-cluster.imageFqdn" -}}
{{- $tag := default .Chart.AppVersion .Values.image.tag }}
{{- if hasPrefix "sha256:" $tag }}
{{- .Values.image.repository }}@{{ $tag }}
{{- else }}
{{- .Values.image.repository }}:{{ $tag }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "flink-job.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- if .flavor }}
{{- default (include "flink-job-cluster.name" .) .Values.serviceAccount.name }}
{{- else }}
{{- default (include "flink-job-cluster.fullname" .) .Values.serviceAccount.name }}
{{- end }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}