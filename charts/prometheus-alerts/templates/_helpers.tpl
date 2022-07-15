{{- define "prometheus-alerts.namespaceSelector" -}}
namespace="{{ .Release.Namespace }}"
{{- end }}

{{- define "prometheus-alerts.podSelector" -}}
{{- if .Values.defaults.podNameSelector -}}
pod=~"{{ tpl .Values.defaults.podNameSelector $ }}"
{{- else -}}
pod!=""
{{- end -}}
{{- end -}}

{{- define "prometheus-alerts.hpaSelector" -}}
{{- if .Values.defaults.hpaNameSelector -}}
job="kube-state-metrics", horizontalpodautoscaler=~"{{ tpl .Values.defaults.hpaNameSelector $ }}", {{ include "prometheus-alerts.namespaceSelector" $ }}
{{- else -}}
job="kube-state-metrics", horizontalpodautoscaler!="", {{ include "prometheus-alerts.namespaceSelector" $ }}
{{- end -}}
{{- end -}}

{{- define "prometheus-alerts.jobSelector" -}}
{{- if .Values.defaults.jobNameSelector -}}
job="kube-state-metrics", job_name=~"{{ tpl .Values.defaults.jobNameSelector $ }}", {{ include "prometheus-alerts.namespaceSelector" $ }}
{{- else -}}
job="kube-state-metrics", job_name!="", {{ include "prometheus-alerts.namespaceSelector" $ }}
{{- end -}}
{{- end -}}

{{- define "prometheus-alerts.deploymentSelector" -}}
{{- if .Values.defaults.deploymentNameSelector -}}
job="kube-state-metrics", kube_deployment=~"{{ tpl .Values.defaults.deploymentNameSelector $ }}", {{ include "prometheus-alerts.namespaceSelector" $ }}
{{- else -}}
job="kube-state-metrics", kube_deployment!="", {{ include "prometheus-alerts.namespaceSelector" $ }}
{{- end -}}
{{- end -}}

{{- define "prometheus-alerts.statefulsetSelector" -}}
{{- if .Values.defaults.statefulsetNameSelector -}}
job="kube-state-metrics", statefulset=~"{{ tpl .Values.defaults.statefulsetNameSelector $ }}", {{ include "prometheus-alerts.namespaceSelector" $ }}
{{- else -}}
job="kube-state-metrics", statefulset!="", {{ include "prometheus-alerts.namespaceSelector" $ }}
{{- end -}}
{{- end -}}

{{- define "prometheus-alerts.daemonsetSelector" -}}
{{- if .Values.defaults.daemonsetNameSelector -}}
job="kube-state-metrics", daemonset=~"{{ tpl .Values.defaults.daemonsetNameSelector $ }}", {{ include "prometheus-alerts.namespaceSelector" $ }}
{{- else -}}
job="kube-state-metrics", daemonset!="", {{ include "prometheus-alerts.namespaceSelector" $ }}
{{- end -}}
{{- end -}}
