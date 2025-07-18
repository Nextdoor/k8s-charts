{{/*
Gathers the application image tag. This allows overriding the tag with a master
`forceTag` setting, as well as the more common mechanism of setting the `tag`
setting.
*/}}
{{- define "rollout-app.proxyImageFqdn" -}}
{{- $tag := .Values.proxySidecar.image.tag | default (include "nd-common.imageTag" .) }}
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
{{- define "rollout-app.containerPorts" -}}
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
{{- define "rollout-app.servicePorts" -}}
{{- range $port := .Values.ports }}
- port: {{ default $port.containerPort $port.port }}
  targetPort: {{ $port.name }}
  protocol: {{ $port.protocol }}
  name: {{ $port.name }}
{{- end }}
{{- end -}}

{{/*
This function generates an extended set of labels by combining the base labels 
from the "nd-common.labels" template with additional custom labels. 

The additional labels include:
  - helm.sh/chart-name: Specifies the name of the chart (hardcoded as "rollout-app").
  - helm.sh/chart-version: Includes the chart version dynamically from .Chart.Version.
*/}}
{{- define "rollout-app.labels" -}}
{{- $baseLabels := include "nd-common.labels" . | fromYaml -}}
{{- $extendedLabels := merge $baseLabels (dict
    "helm.sh/chart-name" "rollout-app"
    "helm.sh/chart-version" .Chart.Version
) -}}
{{- $extendedLabels | toYaml -}}
{{- end -}}

{{- /*
The following functions will append datadog annotations to stable and canary ReplicaSets if
datadog monitoring is enabled. This function also handles cases where
.Values.canary.stableMetadata and .Values.canary.canaryMetadata is configured, merging
the two values such that any annotation mappings requested by the user are kept.
For more information on adding tags using annotations, see:
https://docs.datadoghq.com/containers/kubernetes/tag/?tab=datadogoperator
*/ -}}
{{- define "rollout-app.stableMetadata" }}
{{- $stableMetadata := ( default (dict) .Values.canary.stableMetadata ) }}
{{- $ddStableAnnotations := dict "ad.datadoghq.com/tags" (printf "%s: %s" "argo_rollouts_replicaset_type" "stable") }}
{{- /*
If users are trying to add customer annotations to a stable or canary ReplicaSet alongside having
DataDog enabled, we need to ensure that we merge the DataDog key:value fields in addition to their
key:value fields under the annotations field.
*/ -}}
{{- if .Values.datadog.enabled }}
{{- $stableMetadata = merge (dict 
  "annotations" (merge ($stableMetadata.annotations | default dict) $ddStableAnnotations)
) $stableMetadata }}
{{- end }}
{{- /* Convert the configured stable metadata to correct yaml */ -}}
{{- toYaml $stableMetadata }}
{{- end -}}

{{- define "rollout-app.canaryMetadata" }}
{{- $canaryMetadata := ( default (dict) .Values.canary.canaryMetadata ) }}
{{- $ddCanaryAnnotations := dict "ad.datadoghq.com/tags" (printf "%s: %s" "argo_rollouts_replicaset_type" "canary") }}
{{- /*
If users are trying to add customer annotations to a stable or canary ReplicaSet alongside having
DataDog enabled, we need to ensure that we merge the DataDog key:value fields in addition to their
key:value fields under the annotations field.
*/ -}}
{{- if .Values.datadog.enabled }}
{{- $canaryMetadata = merge (dict 
  "annotations" (merge ($canaryMetadata.annotations | default dict) $ddCanaryAnnotations)
) $canaryMetadata }}
{{- end }}
{{- /* Convert the configured canary metadata to correct yaml */ -}}
{{- toYaml $canaryMetadata }}
{{- end -}}