{{- /*

This function creates the an AuthorizationPolicy objects that (a) allows same-
namespace access, and, also (b) if allowNamespaces is passed in, to allow ingress
from them to the service.

These objects are generally pretty simple, but we re-use them in a few places
and it's nice to have one common way to make them.

AuthorizationPolicies can be used in lieu of NetworkPolicies in a multi-
cluster setup

Via https://istio.io/latest/docs/concepts/security/#allow-nothing-deny-all-and-allow-all-policy:

> Note the “deny by default” behavior applies only if the workload has at least one authorization
policy with the ALLOW action.

- */}}
{{- define "nd-common.authorizationPolicy" }}
{{- if and .Values.istio.enabled (.Capabilities.APIVersions.Has "security.istio.io/v1beta1") }}
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: {{ include "nd-common.fullname" . }}-ingress
spec:
  selector:
    matchLabels:
      {{- include "nd-common.selectorLabels" . | nindent 6 }}
  action: ALLOW
  rules:
  - from:
    - source:
        namespaces: [{{ .Release.Namespace }}]
  {{- if and .Values.ports (gt (len .Values.ports) 0) }}
  {{- if gt (len .Values.network.allowedNamespaces) 0 }}
  - from:
    - source:
        namespaces:
        {{- toYaml .Values.network.allowedNamespaces | nindent 8 }}
    to:
    - operation:
        ports:
        {{- range $port := .Values.ports }}
        - {{ $port.containerPort | quote }}
        {{- end }}
  {{- end }}
  {{- with .Values.virtualService }}
  {{- if and .enabled (gt (len .gateways) 0) }}
  - from:
    - source:
        namespaces:
        {{- range .gateways }}
        {{- $gwNamespace := first (splitList "/" .)  }}
        - {{ $gwNamespace | quote }}
        {{- end }}
    to:
    - operation:
        ports:
        {{- range $port := $.Values.ports }}
        - {{ $port.containerPort | quote }}
        {{- end }}
  {{- end }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}
