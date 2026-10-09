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
Optional istio-proxy container override that gives the sidecar its own locality.

Istio only fills the Envoy bootstrap locality from the pod labels
topology.istio.io/locality or istio-locality (or from cloud instance metadata);
it does not read the Kubernetes topology.kubernetes.io/{region,zone} pod labels.
Zone-aware load balancing (DestinationRule zoneAwareLbSetting) is decided inside
the client proxy and needs that locality, so without it the feature is silently
inert. This renders a container named istio-proxy with image "auto", which the
Istio injector merges into the real sidecar (a supported customization), adding
env entries that build the label Istio reads from the Kubernetes topology labels.
The values resolve at container start, after scheduling. pilot-agent loads
ISTIO_METAJSON_LABELS into its static labels and merges the real pod labels on
top, so nothing else about the proxy changes.
*/}}
{{- define "simple-app.istioLocalityContainer" -}}
{{- if .Values.istio.locality.enabled }}
{{- if not .Values.istio.enabled }}
{{- fail "istio.locality.enabled requires istio.enabled=true: the istio-proxy override is only merged by the sidecar injector" }}
{{- end }}
{{- if not .Values.istio.labelsEnabled }}
{{- fail "istio.locality.enabled requires istio.labelsEnabled=true (sidecar mode): without sidecar injection the istio-proxy override would be created as a real container" }}
{{- end }}
{{- range .Values.extraContainers }}
{{- if eq (.name | default "") "istio-proxy" }}
{{- fail "istio.locality.enabled renders its own istio-proxy container override; remove the istio-proxy entry from extraContainers or set istio.locality.enabled=false" }}
{{- end }}
{{- end }}
- name: istio-proxy
  image: auto
  env:
    - name: POD_REGION
      valueFrom:
        fieldRef:
          fieldPath: metadata.labels['topology.kubernetes.io/region']
    - name: POD_ZONE
      valueFrom:
        fieldRef:
          fieldPath: metadata.labels['topology.kubernetes.io/zone']
    - name: ISTIO_METAJSON_LABELS
      value: '{"topology.istio.io/locality":"$(POD_REGION)/$(POD_ZONE)"}'
{{- end }}
{{- end -}}
