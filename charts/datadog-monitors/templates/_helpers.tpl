{{- define "datadog-monitors.tags" -}}
{{- $root := index . 0 -}}
{{- $tags := index . 1 -}}
{{- $sharedtags := dict "service" (default $root.Release.Name $root.Values.serviceName) "namespace" $root.Release.Namespace -}}
{{- with $root.Values.team -}}
{{- $_ := set $sharedtags "team" . -}}
{{- end -}}
{{- $finaltags := mergeOverwrite $sharedtags $tags -}}
{{- range $k, $v := $finaltags -}}
- "{{ $k }}:{{ $v }}"
{{ end -}}
{{- end -}}