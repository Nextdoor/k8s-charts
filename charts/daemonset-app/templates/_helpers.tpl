Creates a Container "ports" map based on .Values.ports. We do this because we
have customized the values that can be put into the list of "port" maps to
simplify exposing a customer-facing port number (eg 80) while maintaining an
internal application port-number (eg, 8080)
*/}}
{{- define "daemonset-app.containerPorts" -}}
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
{{- define "daemonset-app.servicePorts" -}}
{{- range $port := .Values.ports }}
- port: {{ default $port.containerPort $port.port }}
  targetPort: {{ $port.name }}
  protocol: {{ $port.protocol }}
  name: {{ $port.name }}
{{- end }}
{{- end -}}
