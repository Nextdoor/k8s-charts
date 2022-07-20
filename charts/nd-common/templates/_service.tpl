{{/*
The Service resource is  created any time the "ports" key has ports. It is
also created any time the Values.monitor.enabled is set true - because we use
a ServiceMonitor in this chart to monitor pods.

NOTE: We _always_ create a `Service` object pointing to our `Deployment`. This 
is because the Istio Service Mesh relies on both "client" and "service"
workloads both having `Service` objects pointing to them in order to
configure locality aware load balancing. See
https://github.com/istio/istio/issues/39792#issuecomment-1189669761 for
details.
*/}}

{{- define "nd-common.service" }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "nd-common.fullname" $ }}
  labels:
    {{- include "nd-common.labels" $ | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    {{- include "nd-common.servicePorts" $ | nindent 4 }}

    {{- /*
    Always create a "monitor" port reference, even if the developer is not
    setting up monitoring. This is because a Service resource must have a ports
    key with at least one port defined in it. If they are not setting up
    monitoring, then no ServiceMonitor will be created anyways, and this will
    just be a blank pointer to an unused port.
    */}}
    - port: {{ .Values.monitor.portNumber }}
      targetPort: {{ .Values.monitor.portNumber }}
      name: {{ .Values.monitor.portName }}
  selector:
    {{- include "nd-common.selectorLabels" $ | nindent 4 }}
{{- end }}

{{/*
This is the Service-side of the Ports mapping - we take the .Values.ports map
and turn it into a list of ports that are exposed by the Service resource.
Again, we do not use all of the values, we only use the values that make sense.
*/}}
{{- define "nd-common.servicePorts" -}}
{{- range $port := .Values.ports }}
- port: {{ default $port.containerPort $port.port }}
  targetPort: {{ $port.name }}
  protocol: {{ $port.protocol }}
  name: {{ $port.name }}
{{- end }}
{{ end }}
