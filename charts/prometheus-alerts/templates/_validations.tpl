{{- /*
Render-time sanity checks on the values a user supplied. These fail the render
with an actionable message rather than shipping a PrometheusRule that silently
does the wrong thing.
*/}}

{{- /*
Converts a Prometheus duration string into an integer number of milliseconds so
that two durations can be compared. Handles single terms (`30s`, `5m`, `1h`) as
well as compound ones (`1h30m`). Returns 0 when nothing parseable is found.
*/}}
{{- define "prometheus-alerts.durationMillis" -}}
{{- $units := dict "ms" 1 "s" 1000 "m" 60000 "h" 3600000 "d" 86400000 "w" 604800000 "y" 31536000000 -}}
{{- $total := 0 -}}
{{- range $term := regexFindAll "[0-9]+(ms|[smhdwy])" (toString .) -1 -}}
    {{- $unit := regexFind "(ms|[smhdwy])$" $term -}}
    {{- $total = add $total (mul (atoi (trimSuffix $unit $term)) (index $units $unit)) -}}
{{- end -}}
{{- $total -}}
{{- end -}}

{{- /*
`PodCrashLoopBackOff` stays active across container restarts by evaluating its
metric through a `max_over_time` lookback (`window`). That lookback must be
strictly shorter than `for`.

If `window` >= `for`, a single CrashLoopBackOff observation keeps the
expression true for the whole `for` period on its own, so a pod that backs off
once and then runs fine pages anyway. With `window` < `for` the pod has to be
seen in CrashLoopBackOff repeatedly, with gaps shorter than `window`, across
the entire `for` period - which is what "crash looping" is supposed to mean.
*/}}
{{- define "prometheus-alerts.check_crashloop_window" -}}
{{- with .Values.containerRules }}
    {{- if .enabled }}
        {{- with .pods }}
            {{- if .enabled }}
                {{- with .PodCrashLoopBackOff }}
                    {{- $window := include "prometheus-alerts.durationMillis" (default "" .window) | int64 }}
                    {{- $for := include "prometheus-alerts.durationMillis" (default "" .for) | int64 }}
                    {{- if le $window 0 }}
                        {{- printf "`containerRules.pods.PodCrashLoopBackOff.window` must be a Prometheus duration such as `5m` (got `%s`)." (toString (default "" .window)) | fail }}
                    {{- end }}
                    {{- if le $for 0 }}
                        {{- printf "`containerRules.pods.PodCrashLoopBackOff.for` must be a Prometheus duration such as `10m` (got `%s`)." (toString (default "" .for)) | fail }}
                    {{- end }}
                    {{- if ge $window $for }}
                        {{- printf "`containerRules.pods.PodCrashLoopBackOff.window` (%s) must be strictly shorter than `for` (%s). Otherwise a single CrashLoopBackOff observation holds the alert expression true for the whole `for` period and a one-off backoff pages." (toString .window) (toString .for) | fail }}
                    {{- end }}
                {{- end }}
            {{- end }}
        {{- end }}
    {{- end }}
{{- end }}
{{- end -}}
