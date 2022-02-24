{{/*

The "nd-common.nodeSelector" function provides a common set of nodeSelectors
automatically, with reasonable sane defaults for our environment. The function
can be used in a template like this:

  # deployment.yaml
  apiVersion: apps/v1
  kind: Deployment
  ...
  spec:
    template:
      spec:
        nodeSelector:
          {{- include "nd-common.nodeSelector" $ | nindent 8 }}

In your Values.yaml file, the following value keys are used and/or required:

** .Values.targetOperatingSystem **
Sets the "kubernetes.io/os" nodeSelector key. Must be a string. If not set,
defaults to "linux".

** .Values.targetArchitecture **
Sets the "kubernetes.io/arch" nodeSelector key. Must be a string. If not set,
then no architecture nodeSelector key is set.

** .Values.nodeSelector **
Populates the remainder of the nodeSelector key with the map of key/values
passed in. These values are each run through the 'tpl' function as well.

*/}}
{{- define "nd-common.nodeSelector" -}}

kubernetes.io/os: {{ default "linux" .Values.targetOperatingSystem -}}

{{- with .Values.targetArchitecture }}
kubernetes.io/arch: {{ . }}
{{- end }}

{{- with .Values.nodeSelector }}
{{ tpl (toYaml .) $ }}
{{- end }}

{{- end }}
