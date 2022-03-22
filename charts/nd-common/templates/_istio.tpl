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
{{- $portsToExclude := default (list) .Values.istio.excludeInboundPorts }}
{{- if and .Values.monitor.portNumber .Values.monitor.enabled }}
{{- $portsToExclude := append $portsToExclude .Values.monitor.portNumber }}
traffic.sidecar.istio.io/excludeInboundPorts: {{ join ", " $portsToExclude }}
{{- else }}
{{- if gt (len $portsToExclude) 0 }}
traffic.sidecar.istio.io/excludeInboundPorts: {{ join ", " $portsToExclude }}
{{- end }}
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

{{- end }}
{{- end }}
