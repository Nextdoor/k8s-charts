{{/*

The "nd-common.topologySpreadConstraints" function turns on a standard
topologySpreadConstraint for pods to spread them evenly by zone within a given
maximum skew.

In your Values.yaml file, the following value keys are used and/or required:

** .Values.topologySpreadConstraints **

This is a list of maps that conform to the TopologySpreadConstraints API at
https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/#api.
These will be set up in-order as the first priority.

** .Values.enableTopologySpread **

This boolean setting enables or disables a "default" topologySpreadConstraint
that forces pods to be launched evenly across zones.

** .Values.topologyKey **

This setting is used by the default TopologySpreadConstraint that we configure
to evenly distribute pods across AZs. The default value if not supplied is
`topology.kubernetes.io/zone`.

** .Values.topologySkew **

This translates into the "maximum skew" for the default
TopologySpreadConstraint. The default value if not supplied is `1`.

*/}}
{{- define "nd-common.topologySpreadConstraints" -}}
{{- range $c := index .Values.topologySpreadConstraints -}}
{{- if $c.labelSelector -}}
{{- fail "Do not set labelSelector in .Values.toplogySpreadConstraints maps." -}}
{{- end -}}
- maxSkew: {{ required "Must set maxSkew in .Values.topologySpreadConstraints maps." $c.maxSkew }}
  topologyKey: {{ required "Must set topologyKey in .Values.topologySpreadConstraints maps." $c.topologyKey }}
  whenUnsatisfiable: {{ required "Must set whenUnsatisfiable in .Values.topologySpreadConstraints maps." $c.whenUnsatisfiable }}
  {{- with $c.minDomains }}
  minDomains: {{ . }}
  {{- end }}
  labelSelector:
    matchLabels:
      {{- include "nd-common.selectorLabels" $ | nindent 6 }}
{{- end -}}
{{- if .Values.enableTopologySpread -}}
- maxSkew: {{ default 1 .Values.topologySkew }}
  topologyKey: {{ default "topology.kubernetes.io/zone" .Values.topologyKey }}
  whenUnsatisfiable: DoNotSchedule
  labelSelector:
    matchLabels:
      {{- include "nd-common.selectorLabels" $ | nindent 6 }}
{{- end }}
{{- end }}
