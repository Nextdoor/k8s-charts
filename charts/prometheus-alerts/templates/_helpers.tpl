{{- define "prometheus-alerts.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{ .Values.fullnameOverride }}
{{- else -}}
{{- .Chart.Name }}-{{ default .Release.Name .Values.fullname }}
{{- end -}}
{{- end -}}

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
job="kube-state-metrics", deployment=~"{{ tpl .Values.defaults.deploymentNameSelector $ }}", {{ include "prometheus-alerts.namespaceSelector" $ }}
{{- else -}}
job="kube-state-metrics", deployment!="", {{ include "prometheus-alerts.namespaceSelector" $ }}
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

{{- /*
Grafana Explore (Loki) deep-link to the logs of the Pods owned by a Job.
Call with the root context ($) from a `with .<JobAlert>` block so the
Prometheus $labels.* actions render at alert time. Loki indexes Job logs by
the k8s_job_name stream label, scoped to cluster + k8s_namespace_name.
*/}}
{{- define "prometheus-alerts.jobLogsUrl" -}}
{{ .Values.defaults.grafanaUrl }}/explore?schemaVersion=1&orgId=1&panes=%7B%22logs%22%3A%7B%22datasource%22%3A%22loki%22%2C%22queries%22%3A%5B%7B%22refId%22%3A%22A%22%2C%22expr%22%3A%22%7Bcluster%3D%5C%22{{`{{`}} $labels.cluster {{`}}`}}%5C%22%2C%20k8s_namespace_name%3D%5C%22{{`{{`}} $labels.namespace {{`}}`}}%5C%22%2C%20k8s_job_name%3D%5C%22{{`{{`}} $labels.job_name {{`}}`}}%5C%22%7D%22%2C%22queryType%22%3A%22range%22%2C%22datasource%22%3A%7B%22type%22%3A%22loki%22%2C%22uid%22%3A%22loki%22%7D%2C%22editorMode%22%3A%22code%22%2C%22direction%22%3A%22backward%22%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-6h%22%2C%22to%22%3A%22now%22%7D%7D%7D
{{- end -}}
