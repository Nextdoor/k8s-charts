{{- define "istio-alerts.alias" -}}
  {{- if eq .Chart.Name "istio-alerts" -}}
    {{- $path := splitList "/" .Template.Name -}}
    {{- if gt (len $path) 3 -}}
    {{- (index $path 2) | lower -}}
    {{- end -}}
  {{- else -}}
    {{- .Chart.Name | lower -}}
  {{- end -}}
{{- end -}}

{{- define "istio-alerts.namespaceSelectorIstioForMetrics" -}}
destination_service_namespace="{{ .Release.Namespace }}"
{{- end }}

{{- define "istio-alerts.destinationServiceSelectorForIstioMetrics" -}}
{{- if .Values.serviceRules.destinationServiceName -}}
destination_service_name=~"{{ tpl .Values.serviceRules.destinationServiceName $ }}", {{ include "istio-alerts.namespaceSelectorIstioForMetrics" $ }}
{{- else if (include "istio-alerts.alias" $) -}}
destination_service_name="{{ include "istio-alerts.alias" $ }}", {{ include "istio-alerts.namespaceSelectorIstioForMetrics" $ }}
{{- else -}}
destination_service_name!="", {{ include "istio-alerts.namespaceSelectorIstioForMetrics" $ }}
{{- end -}}
{{- end -}}

{{- define "istio-alerts.namespaceSelectorForKubeStateMetrics" -}}
namespace="{{ .Release.Namespace }}"
{{- end }}

{{- define "istio-alerts.destinationServiceSelectorForKubeStateMetrics" -}}
{{- if .Values.serviceRules.destinationServiceName -}}
service=~"{{ tpl .Values.serviceRules.destinationServiceName $ }}", {{ include "istio-alerts.namespaceSelectorForKubeStateMetrics" $ }}
{{- else -}}
service!="", {{ include "istio-alerts.namespaceSelectorForKubeStateMetrics" $ }}
{{- end -}}
{{- end -}}
