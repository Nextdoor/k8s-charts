# flink-job

Flink job cluster on k8s

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square) ![AppVersion: 1.0](https://img.shields.io/badge/AppVersion-1.0-informational?style=flat-square)

This chart deploys a flink job cluster and runs a simple word counting flink app as an example.
This chart includes some production ready set-ups such as
checkpoints, savepoints, HA service, and Prometheus metrics and alerts.

Please see the Flink operator [user guide](https://github.com/GoogleCloudPlatform/flink-on-k8s-operator/blob/master/docs/user_guide.md) for more details.

## Monitoring

This chart makes an assumption that you _do_ have a Prometheus monitoring endpoint configured.
See metrics reporter in the flink properties for more details.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| alerts.enabled | bool | `true` |  |
| defaults.runbookUrl | string | `"https://github.com/Nextdoor/k8s-charts/blob/main/charts/flink-job/runbook.md"` |  |
| envVars[0].name | string | `"HADOOP_CLASSPATH"` |  |
| envVars[0].value | string | `"/opt/flink/opt/flink-metrics-prometheus-1.9.3.jar"` |  |
| flinkProperties."execution.checkpointing.interval" | string | `"10min"` |  |
| flinkProperties."execution.checkpointing.mode" | string | `"EXACTLY_ONCE"` |  |
| flinkProperties."high-availability.storageDir" | string | `"file:/savepoint/"` |  |
| flinkProperties."kubernetes.cluster-id" | string | `"{{ .Values.fullnameOverride }}"` |  |
| flinkProperties."kubernetes.namespace" | string | `"flink-sample-app"` |  |
| flinkProperties."metrics.reporter.prom.class" | string | `"org.apache.flink.metrics.prometheus.PrometheusReporter"` |  |
| flinkProperties."metrics.reporters" | string | `"prom"` |  |
| flinkProperties."restart-strategy.exponential-delay.backoff-multiplier" | string | `"2.0"` |  |
| flinkProperties."state.checkpoints.dir" | string | `"file:/savepoint/"` |  |
| flinkProperties."taskmanager.numberOfTaskSlots" | string | `"1"` |  |
| flinkProperties.high-availability | string | `"org.apache.flink.kubernetes.highavailability.KubernetesHaServicesFactory"` |  |
| flinkProperties.restart-strategy | string | `"exponential-delay"` |  |
| fullnameOverride | string | `"word-counting-cluster"` |  |
| image.repository | string | `"flink"` |  |
| image.tag | string | `"1.13.1"` |  |
| job.args[0] | string | `"--input"` |  |
| job.args[1] | string | `"./README.txt"` |  |
| job.args[2] | string | `"--output"` |  |
| job.args[3] | string | `"./OUTPUT.txt"` |  |
| job.autoSavepointSeconds | int | `30` |  |
| job.className | string | `"org.apache.flink.streaming.examples.wordcount.WordCount"` |  |
| job.cleanupPolicy.afterJobCancelled | string | `"KeepCluster"` |  |
| job.cleanupPolicy.afterJobFails | string | `"KeepCluster"` |  |
| job.cleanupPolicy.afterJobSucceeds | string | `"KeepCluster"` |  |
| job.initContainers.enabled | bool | `false` |  |
| job.jarFile | string | `"./examples/streaming/WordCount.jar"` |  |
| job.parallelism | int | `1` |  |
| job.restartPolicy | string | `"FromSavepointOnFailure"` |  |
| job.savepointsDir | string | `"/savepoint"` |  |
| job.volumeMounts[0].mountPath | string | `"/savepoint"` |  |
| job.volumeMounts[0].name | string | `"savepoint-storage"` |  |
| job.volumes[0].name | string | `"savepoint-storage"` |  |
| job.volumes[0].persistentVolumeClaim.claimName | string | `"word-counting-cluster-savepoint"` |  |
| jobManager.accessScope | string | `"Cluster"` |  |
| jobManager.metrics.enabled | bool | `true` |  |
| jobManager.metrics.extraPorts[0].containerPort | int | `9249` |  |
| jobManager.metrics.extraPorts[0].name | string | `"prom"` |  |
| jobManager.ports.ui | int | `8081` |  |
| jobManager.resources.limits.cpu | string | `"2"` |  |
| jobManager.resources.limits.memory | string | `"1400Mi"` |  |
| jobManager.resources.requests.cpu | string | `"100m"` |  |
| jobManager.resources.requests.memory | string | `"1000Mi"` |  |
| jobManager.volumeMounts[0].mountPath | string | `"/savepoint"` |  |
| jobManager.volumeMounts[0].name | string | `"savepoint-storage"` |  |
| jobManager.volumes[0].name | string | `"savepoint-storage"` |  |
| jobManager.volumes[0].persistentVolumeClaim.claimName | string | `"word-counting-cluster-savepoint"` |  |
| logConfig."log4j-console.properties" | string | `"rootLogger.level = INFO\nrootLogger.appenderRef.file.ref = LogFile\nrootLogger.appenderRef.console.ref = LogConsole\nappender.file.name = LogFile\nappender.file.type = File\nappender.file.append = false\nappender.file.fileName = ${sys:log.file}\nappender.file.layout.type = PatternLayout\nappender.file.layout.pattern = %d{yyyy-MM-dd HH:mm:ss,SSS} %-5p %-60c %x - %m%n\nappender.console.name = LogConsole\nappender.console.type = CONSOLE\nappender.console.layout.type = PatternLayout\nappender.console.layout.pattern = %d{yyyy-MM-dd HH:mm:ss,SSS} %-5p %-60c %x - %m%n\nlogger.akka.name = akka\nlogger.akka.level = INFO\nlogger.kafka.name= org.apache.kafka\nlogger.kafka.level = INFO\nlogger.hadoop.name = org.apache.hadoop\nlogger.hadoop.level = INFO\nlogger.zookeeper.name = org.apache.zookeeper\nlogger.zookeeper.level = INFO\nlogger.netty.name = org.apache.flink.shaded.akka.org.jboss.netty.channel.DefaultChannelPipeline\nlogger.netty.level = OFF\n"` |  |
| logConfig."logback-console.xml" | string | `"<configuration>\n  <appender name=\"console\" class=\"ch.qos.logback.core.ConsoleAppender\">\n    <encoder>\n      <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{60} %X{sourceThread} - %msg%n</pattern>\n    </encoder>\n  </appender>\n  <appender name=\"file\" class=\"ch.qos.logback.core.FileAppender\">\n    <file>${log.file}</file>\n    <append>false</append>\n    <encoder>\n      <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{60} %X{sourceThread} - %msg%n</pattern>\n    </encoder>\n  </appender>\n  <root level=\"INFO\">\n    <appender-ref ref=\"console\"/>\n    <appender-ref ref=\"file\"/>\n  </root>\n  <logger name=\"akka\" level=\"INFO\" />\n  <logger name=\"org.apache.kafka\" level=\"INFO\" />\n  <logger name=\"org.apache.hadoop\" level=\"INFO\" />\n  <logger name=\"org.apache.zookeeper\" level=\"INFO\" />\n  <logger name=\"org.apache.flink.shaded.akka.org.jboss.netty.channel.DefaultChannelPipeline\" level=\"ERROR\" />\n</configuration>\n"` |  |
| podLabels."sidecar.istio.io/inject" | string | `"false"` |  |
| podMonitor.enabled | bool | `true` |  |
| podMonitor.podMetricsEndpoints[0].port | string | `"prom"` |  |
| podMonitor.podMonitorSelectorLabels.prometheus | string | `"cluster-metrics"` |  |
| podMonitor.podTargetLabels[0] | string | `"cluster"` |  |
| podMonitor.podTargetLabels[1] | string | `"component"` |  |
| podMonitor.selector.matchLabels.app | string | `"flink"` |  |
| pvc.storage | string | `"1Gi"` |  |
| pvc.storageClassName | string | `"efs"` |  |
| serviceAccount.create | bool | `true` | (Boolean) whether to create the ServiceAccount we associate with the IAM Role. |
| taskManager.metrics.enabled | bool | `true` |  |
| taskManager.metrics.extraPorts[0].containerPort | int | `9249` |  |
| taskManager.metrics.extraPorts[0].name | string | `"prom"` |  |
| taskManager.metrics.extraPorts[0].protocol | string | `"TCP"` |  |
| taskManager.replicas | int | `1` |  |
| taskManager.resources.limits.cpu | string | `"2"` |  |
| taskManager.resources.limits.memory | string | `"1500Mi"` |  |
| taskManager.resources.requests.cpu | string | `"100m"` |  |
| taskManager.resources.requests.memory | string | `"1000Mi"` |  |
| taskManager.securityContext.fsGroup | int | `9999` |  |
| taskManager.securityContext.runAsGroup | int | `9999` |  |
| taskManager.securityContext.runAsNonRoot | bool | `true` |  |
| taskManager.securityContext.runAsUser | int | `9999` |  |
| taskManager.volumeMounts[0].mountPath | string | `"/savepoint"` |  |
| taskManager.volumeMounts[0].name | string | `"savepoint-storage"` |  |
| taskManager.volumes[0].name | string | `"savepoint-storage"` |  |
| taskManager.volumes[0].persistentVolumeClaim.claimName | string | `"word-counting-cluster-savepoint"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)
