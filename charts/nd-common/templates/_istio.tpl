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
If monitoring is enabled, and we're in an Istio environment, then we
default to using the Isto metrics-merging feature where the sidecar
scrapes the metrics.
*/}}
{{- if .Values.monitor.enabled }}
prometheus.io/scrape: "true"
prometheus.io/port: {{ .Values.monitor.portNumber | quote }}
prometheus.io/path: {{ .Values.monitor.path }}
{{- end }}
{{- end }}

{{- end }}
