{{- /*
These checks are in place to ensure that the values files are up-to-date with values schema changes in v1.5.0.
*/}}
{{- if .Values.containerRules.ContainerWaiting }}
{{- fail "Value `.Values.containerRules.ContainerWaiting` has been migrated to `.Values.containerRules.pods.ContainerWaiting`. Please update your values files." }}
{{- end }}
{{- if .Values.containerRules.CPUThrottlingHigh }}
{{- fail "Value `.Values.containerRules.CPUThrottlingHigh` has been migrated to `.Values.containerRules.pods.CPUThrottlingHigh`. Please update your values files." }}
{{- end }}
{{- if .Values.containerRules.KubeDaemonSetMisScheduled }}
{{- fail "Value `.Values.containerRules.KubeDaemonSetMisScheduled` has been migrated to `.Values.containerRules.daemonsets.KubeDaemonSetMisScheduled`. Please update your values files." }}
{{- end }}
{{- if .Values.containerRules.KubeDaemonSetNotScheduled }}
{{- fail "Value `.Values.containerRules.KubeDaemonSetNotScheduled` has been migrated to `.Values.containerRules.daemonsets.KubeDaemonSetNotScheduled`. Please update your values files." }}
{{- end }}
{{- if .Values.containerRules.KubeDaemonSetRolloutStuck }}
{{- fail "Value `.Values.containerRules.KubeDaemonSetRolloutStuck` has been migrated to `.Values.containerRules.daemonsets.KubeDaemonSetRolloutStuck`. Please update your values files." }}
{{- end }}
{{- if .Values.containerRules.KubeDeploymentGenerationMismatch }}
{{- fail "Value `.Values.containerRules.KubeDeploymentGenerationMismatch` has been migrated to `.Values.containerRules.deployments.KubeDeploymentGenerationMismatch`. Please update your values files." }}
{{- end }}
{{- if .Values.containerRules.KubeHpaMaxedOut }}
{{- fail "Value `.Values.containerRules.KubeHpaMaxedOut` has been migrated to `.Values.containerRules.hpas.KubeHpaMaxedOut`. Please update your values files." }}
{{- end }}
{{- if .Values.containerRules.KubeHpaReplicasMismatch }}
{{- fail "Value `.Values.containerRules.KubeHpaReplicasMismatch` has been migrated to `.Values.containerRules.hpas.KubeHpaReplicasMismatch`. Please update your values files." }}
{{- end }}
{{- if .Values.containerRules.KubeJobCompletion }}
{{- fail "Value `.Values.containerRules.KubeJobCompletion` has been migrated to `.Values.containerRules.jobs.KubeJobCompletion`. Please update your values files." }}
{{- end }}
{{- if .Values.containerRules.KubeJobFailed }}
{{- fail "Value `.Values.containerRules.KubeJobFailed` has been migrated to `.Values.containerRules.jobs.KubeJobFailed`. Please update your values files." }}
{{- end }}
{{- if .Values.containerRules.KubeStatefulSetGenerationMismatch }}
{{- fail "Value `.Values.containerRules.KubeStatefulSetGenerationMismatch` has been migrated to `.Values.containerRules.statefulsets.KubeStatefulSetGenerationMismatch`. Please update your values files." }}
{{- end }}
{{- if .Values.containerRules.KubeStatefulSetReplicasMismatch }}
{{- fail "Value `.Values.containerRules.KubeStatefulSetReplicasMismatch` has been migrated to `.Values.containerRules.statefulsets.KubeStatefulSetReplicasMismatch`. Please update your values files." }}
{{- end }}
{{- if .Values.containerRules.KubeStatefulSetUpdateNotRolledOut }}
{{- fail "Value `.Values.containerRules.KubeStatefulSetUpdateNotRolledOut` has been migrated to `.Values.containerRules.statefulsets.KubeStatefulSetUpdateNotRolledOut`. Please update your values files." }}
{{- end }}
{{- if .Values.containerRules.PodContainerOOMKilled }}
{{- fail "Value `.Values.containerRules.PodContainerOOMKilled` has been migrated to `.Values.containerRules.pods.PodContainerOOMKilled`. Please update your values files." }}
{{- end }}
{{- if .Values.containerRules.PodContainerTerminated }}
{{- fail "Value `.Values.containerRules.PodContainerTerminated` has been migrated to `.Values.containerRules.pods.PodContainerTerminated`. Please update your values files." }}
{{- end }}
{{- if .Values.containerRules.PodCrashLoopBackOff }}
{{- fail "Value `.Values.containerRules.PodCrashLoopBackOff` has been migrated to `.Values.containerRules.pods.PodCrashLoopBackOff`. Please update your values files." }}
{{- end }}
{{- if .Values.containerRules.PodNotReady }}
{{- fail "Value `.Values.containerRules.PodNotReady` has been migrated to `.Values.containerRules.pods.PodNotReady`. Please update your values files." }}
{{- end }}