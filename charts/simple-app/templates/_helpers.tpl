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

{{/*
This function generates an extended set of labels by combining the base labels 
from the "nd-common.labels" template with additional custom labels. 

The additional labels include:
  - helm.sh/chart-name: Specifies the name of the chart (hardcoded as "simple-app").
  - helm.sh/chart-version: Includes the chart version dynamically from .Chart.Version.
*/}}
{{- define "simple-app.labels" -}}
{{- $baseLabels := include "nd-common.labels" . | fromYaml -}}
{{- $extendedLabels := merge $baseLabels (dict
    "helm.sh/chart-name" "simple-app"
    "helm.sh/chart-version" .Chart.Version
) -}}
{{- $extendedLabels | toYaml -}}
{{- end -}}

{{/*
True when Datadog triggers use the shared KEDA ClusterTriggerAuthentication
instead of this chart's bound-token TriggerAuthentication. Compared as a string
so an Argo CD/Helm `--set` or `--set-string` "true"/"false" override works.
*/}}
{{- define "simple-app.kedaSharedAuth" -}}
{{- $shared := .Values.autoscaling.keda.sharedTriggerAuthentication | default dict -}}
{{- if eq (printf "%v" $shared.enabled) "true" -}}true{{- end -}}
{{- end -}}

{{/*
authenticationRef body for the Datadog trigger.
*/}}
{{- define "simple-app.kedaDatadogAuthRef" -}}
{{- if eq (include "simple-app.kedaSharedAuth" .) "true" -}}
name: {{ required "autoscaling.keda.sharedTriggerAuthentication.name is required" .Values.autoscaling.keda.sharedTriggerAuthentication.name }}
kind: ClusterTriggerAuthentication
{{- else -}}
name: {{ include "nd-common.fullname" . }}-datadog-auth
{{- end -}}
{{- end -}}
