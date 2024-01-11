{{/*

The "istioAnnotations" function creates a series of common and well known Istio
Annotations that impact the behavior of the Istio Service mesh with regards to
your application pod.

*/}}
{{- define "nd-common.istioAnnotations" -}}
{{- if .Values.istio.enabled }}
{{- /*
Ensures that the application does not start up until after the Istio
proxy container is ready to pass traffic. This prevents race
conditions.
*/ -}}
proxy.istio.io/config: '{ "holdApplicationUntilProxyStarts": true }'

{{- /*
Explicitly exclude our "metrics" port from being proxied by the Istio service,
and instead let traffic flow right into it. Also beacuse a user might have set
this annotation on their own, we need to merge our value with whatever they've
supplied.
*/ -}}
{{- $inboundPorts := (include "nd-common.istioExcludedInboundPorts" . )}}
{{- if gt (len $inboundPorts) 0 }}
traffic.sidecar.istio.io/excludeInboundPorts: {{ $inboundPorts | quote }}
{{- end }}

{{- /*
Allow excluding custom ports for outbound traffic.
*/ -}}
{{- $outboundPorts := (include "nd-common.istioExcludedOutboundPorts" . )}}
{{- if gt (len $outboundPorts) 0 }}
traffic.sidecar.istio.io/excludeOutboundPorts: {{ $outboundPorts | quote }}
{{- end }}

{{- /* 
If the service has any ports exposed at all, we're going to make the
Istio Sidecar wait to shut down until after the application stops
listening on the port. This ensures that the app is able to complete
whatever its shutdown process is (like flushing data out of memory to a
downstream source) before the network connectivity to the application
is cut off.
*/ -}}
{{- if .Values.istio.preStopCommand }}
proxy.istio.io/overrides: >-
  { 
    "containers": [
      { 
        "name": "istio-proxy",
        "lifecycle": {
          "preStop": {
            "exec": {
              "command": {{ .Values.istio.preStopCommand | toJson }}
            }
          }
        }
      }
    ]
  } 
{{- else if and .Values.ports (gt (len .Values.ports) 0) }}
proxy.istio.io/overrides: >-
  { 
    "containers": [
      { 
        "name": "istio-proxy",
        "lifecycle": {
          "preStop": {
            "exec": {
              "command": [
                "/bin/sh",
                "-c",
                "while [ $(netstat -plunt | grep tcp | egrep -v 'envoy|pilot-agent' | wc -l | xargs) -ne 0 ]; do sleep 1; done"
              ]
            }
          }
        }
      }
    ]
  } 
{{- end }}

{{- /*

Prepare the set of resource annotations for the istio-sidecar.
Motivation: Due to an incident, we found out that once one of the values is set through annotation. It overides the other values which is what led to the incident.
            This behaviour is not documents nor it makes sense in any ways.
Description: Once a value is set to any of the istio.(proxyCPU, proxyCPULimit, proxyMemory, proxyMemoryLimit), all the 4 annotations will get created.
             Fallbacking to the current implemented default resources for any annotation that is not specifically set:
                Limits:
                  cpu:                2
                  memory:             1Gi
                Requests:
                  cpu:                100m
                  memory:             128Mi
Usage: To setup the values follow the regular k8s resources structure under the istio key, like the bellow example:
  istio:
   resources:
     requests:
       cpu: 10m
       memory: 10Mi
     limits:
       memory: 60Mi
*/ -}}
{{- with .Values.istio.resources }}
{{- if .requests }}
sidecar.istio.io/proxyCPU: {{ .requests.cpu | default "100m" | quote }}
sidecar.istio.io/proxyMemory: {{ .requests.memory | default "128Mi" | quote }}
{{- else }}
sidecar.istio.io/proxyCPU: "100m"
sidecar.istio.io/proxyMemory: "128Mi"
{{- end }}
{{- if .limits }}
sidecar.istio.io/proxyCPULimit: {{ .limits.cpu | default "2" | quote }}
sidecar.istio.io/proxyMemoryLimit: {{ .limits.memory | default "1Gi" | quote }}
{{- else }}
sidecar.istio.io/proxyCPULimit: "2"
sidecar.istio.io/proxyMemoryLimit: "1Gi"
{{- end }}
{{- end }}

{{- end }}
{{- end }}

{{/*

Build a comma-separated list of inbound ports to exclude from Istio routing.

*/}}
{{- define "nd-common.istioExcludedInboundPorts" -}}
{{- $ports := list }}
{{- with .Values.istio.excludeInboundPorts }}
{{- range $port := index . }}
{{- $portStr := $port | toString }}
{{- $ports = tpl $portStr $ | append $ports }}
{{- end }}
{{- end }}
{{- if and .Values.monitor.portNumber .Values.monitor.enabled }}
{{- $ports = append $ports .Values.monitor.portNumber }}
{{- end }}
{{- join ", " $ports }}
{{- end }}

{{/*

Build a comma-separated list of outbound ports to exclude from Istio routing.

*/}}
{{- define "nd-common.istioExcludedOutboundPorts" -}}
{{- $ports := list }}
{{- with .Values.istio.excludeOutboundPorts }}
{{- range $port := index . }}
{{- $portStr := $port | toString }}
{{- $ports = tpl $portStr $ | append $ports }}
{{- end }}
{{- end }}
{{- join ", " $ports }}
{{- end }}

{{/*

The "istioLabels" function creates a few common labels that the Istio team (and
Kiali teams) have decided make sense for tracking applications inside of a
mesh.

*/}}
{{- define "nd-common.istioLabels" -}}
{{- $_tag := include "nd-common.imageTag" . -}}
{{- $tag  := $_tag | replace "@" "_" | replace ":" "_" | trunc 63 | quote -}}

{{- /* https://istio.io/latest/docs/ops/configuration/mesh/injection-concepts/ */ -}}
sidecar.istio.io/inject: {{ eq true .Values.istio.enabled | quote }}

{{- /*
Explicitly disable or enable Metrics Merging - we want to keep our Envoy
sidecar metrics separate from the Application metrics and not force the two to
be merged, but we also want to allow a developer to make this choice if it
makes sense. The default is False here, but can be overridden by
.Values.istio.metricsMerging being set to "true".

See https://istio.io/latest/docs/ops/integrations/prometheus/#option-1-metrics-merging

*/}}
{{- if eq true .Values.istio.metricsMerging }}
prometheus.istio.io/merge-metrics: "true"
prometheus.io/scrape: "true"
prometheus.io/port: {{ .Values.monitor.portNumber | quote }}
prometheus.io/path: {{ .Values.monitor.path }}
{{- else }}
prometheus.istio.io/merge-metrics: "false"
{{- end }}

{{- /* https://istio.io/latest/docs/ops/deployment/requirements/ */ -}}
{{- if not (hasKey .Values.podLabels "app") }}
app: {{ .Release.Name }}
{{- end }}
version: {{ $tag }}

{{- end }}
