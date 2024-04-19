{{/*
These checks are in place to ensure that the values files are up-to-date with
values schema changes in v1.5.0.
*/}}
{{ $rules := dict "ContainerWaiting" "pods" "CPUThrottlingHigh" "pods" "KubeDaemonSetMisScheduled" "daemonsets" "KubeDaemonSetNotScheduled" "daemonsets" "KubeDaemonSetRolloutStuck" "daemonsets" "KubeDeploymentGenerationMismatch" "deployments" "KubeHpaMaxedOut" "hpas" "KubeHpaReplicasMismatch" "hpas" "KubeJobCompletion" "jobs" "KubeJobFailed" "jobs" "KubeStatefulSetGenerationMismatch" "statefulsets" "KubeStatefulSetReplicasMismatch" "statefulsets" "KubeStatefulSetUpdateNotRolledOut" "statefulsets" "PodContainerOOMKilled" "pods" "PodContainerTerminated" "pods" "PodCrashLoopBackOff" "pods" "PodNotReady" "pods" }}
{{ $rule, $type := range $rules }}
{{ if index .Values.containerRules $rule }}
{{ printf "Value `.Values.containerRules.%s` has been migrated to `.Values.containerRules.%s.%s`. Please update your values files." $rule $type $rule | fail }}
{{ end }}
{{ end }}
