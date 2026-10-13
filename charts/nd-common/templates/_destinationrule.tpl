{{- /*

DestinationRule helpers.

Istio only applies locality-aware routing to an upstream when a DestinationRule
for that host exists (priority-based failover needs `outlierDetection`), and
Istio 1.31's zone-aware load balancing is configured through
`trafficPolicy.loadBalancer.zoneAwareLbSetting` on the same object. These
helpers let an application chart render that rule from values.

Notes:
  - `zoneAwareLbSetting` and `localityLbSetting` are mutually exclusive in
    Istio (istiod rejects a rule that carries both), so rendering fails early
    when both are configured.
  - `zoneAwareLbSetting.enabled: false` makes istiod emit `routing_enabled: 0%`,
    which leaves traffic behaviour unchanged. The rule can therefore ship before
    client proxies have self-discovery, and the later flip to `true` is a single
    values change that takes effect on the next xDS push, without pod restarts.

*/ -}}

{{- /*
Renders the trafficPolicy body (as YAML) from .Values.destinationRule. Returns
"{}" when nothing is configured.
*/ -}}
{{- define "nd-common.destinationRuleTrafficPolicy" -}}
{{- $dr := .Values.destinationRule }}
{{- $lb := deepCopy (default (dict) $dr.loadBalancer) }}
{{- if $dr.zoneAwareLb.configure }}
{{- if hasKey $lb "localityLbSetting" }}
{{- fail "destinationRule.loadBalancer.localityLbSetting cannot be combined with destinationRule.zoneAwareLb.configure=true: Istio accepts only one of localityLbSetting and zoneAwareLbSetting on a DestinationRule" }}
{{- end }}
{{- $za := dict "enabled" $dr.zoneAwareLb.enabled }}
{{- with $dr.zoneAwareLb.minClusterSize }}
{{- $_ := set $za "minClusterSize" . }}
{{- end }}
{{- with $dr.zoneAwareLb.failover }}
{{- $_ := set $za "failover" . }}
{{- end }}
{{- $_ := set $lb "zoneAwareLbSetting" $za }}
{{- end }}
{{- $policy := dict }}
{{- with $dr.connectionPool }}{{- $_ := set $policy "connectionPool" . }}{{- end }}
{{- with $dr.outlierDetection }}{{- $_ := set $policy "outlierDetection" . }}{{- end }}
{{- with $lb }}{{- $_ := set $policy "loadBalancer" . }}{{- end }}
{{- with $dr.tls }}{{- $_ := set $policy "tls" . }}{{- end }}
{{- toYaml $policy }}
{{- end -}}

{{- /*
Renders one DestinationRule. Takes a dict:
  root:    the chart context ($)
  name:    resource name
  host:    Service name (the namespace and cluster domain are appended)
  subsets: optional list of subsets (passed through verbatim)
Renders nothing unless .Values.istio.enabled and .Values.destinationRule.enabled.
*/ -}}
{{- define "nd-common.destinationRuleFor" -}}
{{- $root := .root }}
{{- if and $root.Values.istio.enabled $root.Values.destinationRule.enabled }}
{{- $policy := include "nd-common.destinationRuleTrafficPolicy" $root }}
---
apiVersion: networking.istio.io/v1
kind: DestinationRule
metadata:
  name: {{ .name }}
  labels:
    {{- include "nd-common.labels" $root | nindent 4 }}
  {{- with $root.Values.destinationRule.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  host: {{ .host }}.{{ $root.Release.Namespace }}.svc.cluster.local
  {{- if ne (trim $policy) "{}" }}
  trafficPolicy:
    {{- $policy | nindent 4 }}
  {{- end }}
  {{- with .subsets }}
  subsets:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end -}}

{{- /*
The DestinationRule for the chart's primary Service, named after the release,
with .Values.destinationRule.subsets passed through.
*/ -}}
{{- define "nd-common.destinationRule" -}}
{{- include "nd-common.destinationRuleFor" (dict "root" . "name" (include "nd-common.fullname" .) "host" (include "nd-common.serviceName" .) "subsets" .Values.destinationRule.subsets) }}
{{- end -}}
