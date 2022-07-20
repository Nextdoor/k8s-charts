{{/*
This function creates a NetworkPolicy object. These objects are generally
pretty simple, but we re-use them in a few places and it's nice to have one
common way to make them.

The intention here is to open up a service for access from within the
Kubernetes network, as our default is to block all traffic.
*/}}

{{- define "nd-common.networkPolicy" }}
{{- if .Values.ports }}
{{- if gt (len .Values.ports) 0 }}
{{- if gt (len .Values.network.allowedNamespaces) 0 }}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: {{ include "nd-common.fullname" . }}-ingress
  labels:
    {{- include "nd-common.labels" . | nindent 4 }}
spec:
  policyTypes: [Ingress]
  podSelector:
    matchLabels:
      {{- include "nd-common.selectorLabels" . | nindent 6 }}
  ingress:
    - ports:
      {{- range $port := .Values.ports }}
      - port: {{ $port.containerPort }}
        protocol: {{ $port.protocol }}
      {{- end }}
      from:
        {{- range .Values.network.allowedNamespaces }}
        {{- if eq . "*" }}
        - namespaceSelector: {}
        {{- else }}
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: {{ . }}
        {{- end }}
        {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
