{{/*
The Service resource is  created any time the "ports" key has ports.

NOTE: We _always_ create a `Service` object pointing to our `Deployment`. This 
is because the Istio Service Mesh relies on both "client" and "service"
workloads both having `Service` objects pointing to them in order to
configure locality aware load balancing. See
https://github.com/istio/istio/issues/39792#issuecomment-1189669761 for
details.
*/}}

{{- define "nd-common.serviceName" }}
{{- default (include "nd-common.fullname" $) .Values.service.name }}
{{- end }}

{{- define "nd-common.service" }}
{{- if and .Values.ports (gt (len .Values.ports) 0) }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "nd-common.serviceName" $ }}
  labels:
    {{- include "nd-common.labels" $ | nindent 4 }}
  annotations:
    {{/*
    This is only used for type=LoadBalancer Services which run in AWS.
    */}}
    service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags: kubernetes_namespace={{ .Release.Namespace }}
spec:
  type: {{ .Values.service.type }}
  ports:
    {{- include "nd-common.servicePorts" $ | nindent 4 }}
  selector:
    {{- include "nd-common.selectorLabels" $ | nindent 4 }}
{{- end }}

---
{{/*
The Service resource is created any time the Values.monitor.enabled is set true - because we use
a ServiceMonitor in this chart to monitor pods. We are separating out the Service resource from
above service resource because we don't want to expose the metrics port over the service mesh.
We are achiving this by setting the annotation networking.istio.io/exportTo: nullnullnull.
This is recommended by istio community. This pattern simplifies our template actually,
and at the same time will reduce the number of service ports that our istiod processes are
monitoring.
*/}}
{{- if .Values.monitor.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "nd-common.serviceName" $ }}-metrics
  labels:
    {{- include "nd-common.labels" $ | nindent 4 }}
  annotations:
    networking.istio.io/exportTo: nullnullnull
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.monitor.portNumber }}
      targetPort: {{ .Values.monitor.portNumber }}
      name: {{ .Values.monitor.portName }}
  selector:
    {{- include "nd-common.selectorLabels" $ | nindent 4 }}
{{- end }}

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
