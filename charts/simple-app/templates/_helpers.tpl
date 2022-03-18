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
{{- $_tag := include "nd-common.imageTag" . }}
{{- $tag  := $_tag | replace "@" "_" | replace ":" "_" | trunc 63 | quote -}}
{{- if not (hasKey .Values.podLabels "app") }}
app: {{ .Release.Name }}
{{- end }}
version: {{ $tag }}
helm.sh/chart: {{ include "simple-app.chart" . }}
app.kubernetes.io/version: {{ $tag }}
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
{{- $tag := include "nd-common.imageTag" . }}
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
{{- define "simple-app.proxyImageFqdn" -}}
{{- $tag := include "nd-common.imageTag" . }}
{{- if hasPrefix "sha256:" $tag }}
{{- .Values.proxySidecar.image.repository }}@{{ $tag }}
{{- else }}
{{- .Values.proxySidecar.image.repository }}:{{ $tag }}
{{- end }}
{{- end }}

{{/*
Creates a Container "ports" map based on .Values.ports. We do this because we
have customized the values that can be put into the list of "port" maps to
simplify exposing a customer-facing port number (eg 80) while maintaining an
internal application port-number (eg, 8080)
*/}}
{{- define "simple-app.containerPorts" -}}
{{- range $p := index .Values.ports }}
- name: {{ required "Must set a port name" $p.name }}
  containerPort: {{ required "Must set a containerPort" $p.containerPort }}
  {{- with $p.protocol }}
  protocol: {{ . }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
This is the Service-side of the Ports mapping - we take the .Values.ports map
and turn it into a list of ports that are exposed by the Service resource.
Again, we do not use all of the values, we only use the values that make sense.
*/}}
{{- define "simple-app.servicePorts" -}}
{{- range $port := .Values.ports }}
- port: {{ default $port.containerPort $port.port }}
  targetPort: {{ $port.name }}
  protocol: {{ $port.protocol }}
  name: {{ $port.name }}
{{- end }}
{{- end -}}

{{/*
This is datalog logging configuration. We take the .Values.scrapeLogs and
.Values.scrapeLogsProcessingRules map and convert into list of objects converted
into json supported by datadog config. If source and service tag values not provided
we add default values to it.
*/}}
{{- define "simple-app.datadogScrapeLoggingConfig" -}}
{{- if and .Values.datadog.enabled .Values.datadog.scrapeLogs.enabled }}
- source: {{- default (include "simple-app.name" .) .Values.datadog.scrapeLogs.source }}
  service: {{- default (include "simple-app.name" .) .Values.datadog.service }}
{{- if .Values.datadog.scrapeLogsProcessingRules }}
  log_processing_rules: {{- .Values.datadog.scrapeLogsProcessingRules }}
{{- end }}
{{- end }}
{{- end -}}