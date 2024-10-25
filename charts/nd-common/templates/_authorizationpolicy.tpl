{{- /*

This function creates the following two AuthorizationPolicy objects:

  1. To allow same-namespace access (this can probably be migrated to a
     Kyverno ClusterPolicy that applies this on all namespaces, but for
     now adding here for smooth transition for "allow" AuthorizationPolicies
     to be created too)

  2. To allowNamespaces to have ingress access to the service (a drop-in
     replacement of the NetworkPolicy we make defunct when a service is to
     be accessed from a multi-cluster setup

These objects are generally pretty simple, but we re-use them in a few places
and it's nice to have one common way to make them.

AuthorizationPolicies can be used in lieu of NetworkPolicies in a multi-
cluster setup

Via https://istio.io/latest/docs/concepts/security/#allow-nothing-deny-all-and-allow-all-policy:

> Note the “deny by default” behavior applies only if the workload has at least one authorization
policy with the ALLOW action.

- */}}
{{- define "nd-common.authorizationPolicy" }}
{{- if .Values.istio.enabled }}
{{- /*

Create a default AuthorizationPolicy that allows local namespace ingress

See note above: after a while, wWe can probably have this as part of a
Kyverno ClusterPolicy that's added to all namespaces.

- */}}
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-local-namespace-ingress
spec:
  selector:
    matchLabels:
      {{- include "nd-common.selectorLabels" . | nindent 6 }}
  action: ALLOW
  rules:
  - from:
    - source:
        namespaces: [{{ .Release.Namespace }}]

{{- if .Values.ports }}
{{- if gt (len .Values.ports) 0 }}
{{- if gt (len .Values.network.allowedNamespaces) 0 }}
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-{{ include "nd-common.fullname" . }}-ingress
spec:
  selector:
    matchLabels:
      {{- include "nd-common.selectorLabels" . | nindent 6 }}
  action: ALLOW
  rules:
  - from:
    - source:
        namespaces:
        {{- range .Values.network.allowedNamespaces }}
        - {{ . | quote }}
        {{- end }}
    to:
    - operation:
        ports:
        {{- range $port := .Values.ports }}
        - {{ $port.containerPort | quote }}
        {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
