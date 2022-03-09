{{/*

Gathers the application image tag. This allows overriding the tag with a master
`forceTag` setting, as well as the more common mechanism of setting the `tag`
setting.

*/}}
{{- define "nd-common.imageTag" -}}
{{- default .Chart.AppVersion (default .Values.image.tag .Values.image.forceTag) }}
{{- end }}
