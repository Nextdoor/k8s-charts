# flink-job

Flink job cluster on k8s

![Version: 0.1.6](https://img.shields.io/badge/Version-0.1.6-informational?style=flat-square) ![AppVersion: 1.0](https://img.shields.io/badge/AppVersion-1.0-informational?style=flat-square)

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
| alerts.enabled | bool | `true` | (Boolean) Specifies whether to create the PrometheusRule for this flink cluster |
| alerts.restartsLimit | int | `2` | (`int`) The number of job restarts before alerting |
| alerts.severity | string | `"info"` | (String) Severity of the alerts |
| batchSchedulerName | String | `nil` | specifies the batch scheduler name for JobManager, TaskManager. If empty, no batch scheduling is enabled |
| defaults.runbookUrl | string | `"https://github.com/Nextdoor/k8s-charts/blob/main/charts/flink-job/runbook.md"` | (String) Runbook URL for the Prometheus alerts |
| envVars | list | `[{"name":"HADOOP_CLASSPATH","value":"/opt/flink/opt/flink-metrics-prometheus-1.9.3.jar"}]` | Environment variables shared by all containers |
| flinkProperties | object | `{"execution.checkpointing.interval":"10min","execution.checkpointing.mode":"EXACTLY_ONCE","high-availability":"org.apache.flink.kubernetes.highavailability.KubernetesHaServicesFactory","high-availability.storageDir":"file:/savepoint/","kubernetes.cluster-id":"{{ .Values.fullnameOverride }}","kubernetes.namespace":"{{ .Release.Namespace }}","metrics.reporter.prom.class":"org.apache.flink.metrics.prometheus.PrometheusReporter","metrics.reporters":"prom","restart-strategy":"exponential-delay","restart-strategy.exponential-delay.backoff-multiplier":"2.0","state.checkpoints.dir":"file:/savepoint/","taskmanager.numberOfTaskSlots":"1"}` | (`Map`) Flink properties which are appened to flink-conf.yaml |
| flinkVersion | String | `nil` | The Flink version to operate |
| fullnameOverride | string | `"word-counting-cluster"` | (String) The name of the flink cluster |
| image.repository | string | `"flink"` | (String) The Flink image name and repository |
| image.tag | string | `"1.13.1"` | (String) The Flink image tag |
| job.allowNonRestoredState | bool | `false` | (String) Should allow to skip state that cannot be mapped to the new program when drop an operator |
| job.args | list | `["--input","./README.txt","--output","./OUTPUT.txt"]` | (List) Command-line args of the job |
| job.autoSavepointSeconds | int | `30` | (`int`) Automatically take a savepoint to the savepointsDir in this given interval |
| job.className | string | `"org.apache.flink.streaming.examples.wordcount.WordCount"` | (String) Java class name of the job |
| job.cleanupPolicy | object | `{"afterJobCancelled":"KeepCluster","afterJobFails":"KeepCluster","afterJobSucceeds":"KeepCluster"}` | The action to take after job finishes enum("KeepCluster", "DeleteCluster", "DeleteTaskManager") |
| job.fromSavepoint | String | `nil` | Savepoint where to restore the job from. Unspecify if to restore from the latest savepoint |
| job.initContainers | object | `{"enabled":false}` | Init containers of the Job pod. It can be used to download a remote job jar to your job pod. It is only needed if you have no other way to download your job files into the Flink job cluster. |
| job.jarFile | string | `"./examples/streaming/WordCount.jar"` | (String) JAR file of the job |
| job.parallelism | int | `1` | (`int`) Parallelism of the job |
| job.restartPolicy | string | `"FromSavepointOnFailure"` | (String) Restart policy when the job fails, enum("Never", "FromSavepointOnFailure") |
| job.savepointGeneration | `int` | `nil` | Update this field to jobStatus.savepointGeneration + 1 for a running job cluster to trigger a new savepoint to savepointsDir on demand. |
| job.savepointsDir | string | `"/savepoint"` | (String) Directory to store automatically taken savepoints |
| job.takeSavepointOnUpgrade | bool | `true` | (bool) Should take savepoint before upgrading the job |
| jobManager.accessScope | string | `"Cluster"` | (String) Access scope of the JobManager service. enum("Cluster", "VPC", "External", "NodePort", "Headless") |
| jobManager.metrics | object | `{"enabled":true,"extraPorts":[{"containerPort":9249,"name":"prom"}]}` | Prometheus metrics ports for jobManager |
| jobManager.ports | object | `{"ui":8081}` | (`int`) Ports that JobManager listening on |
| jobManager.resources | object | `{"limits":{"memory":"1400Mi"},"requests":{"cpu":"100m","memory":"1000Mi"}}` | Compute resources required by JobManager container |
| logConfig | object | `{"log4j-console.properties":"rootLogger.level = INFO\nrootLogger.appenderRef.file.ref = LogFile\nrootLogger.appenderRef.console.ref = LogConsole\nappender.file.name = LogFile\nappender.file.type = File\nappender.file.append = false\nappender.file.fileName = ${sys:log.file}\nappender.file.layout.type = PatternLayout\nappender.file.layout.pattern = %d{yyyy-MM-dd HH:mm:ss,SSS} %-5p %-60c %x - %m%n\nappender.console.name = LogConsole\nappender.console.type = CONSOLE\nappender.console.layout.type = PatternLayout\nappender.console.layout.pattern = %d{yyyy-MM-dd HH:mm:ss,SSS} %-5p %-60c %x - %m%n\nlogger.akka.name = akka\nlogger.akka.level = INFO\nlogger.kafka.name= org.apache.kafka\nlogger.kafka.level = INFO\nlogger.hadoop.name = org.apache.hadoop\nlogger.hadoop.level = INFO\nlogger.zookeeper.name = org.apache.zookeeper\nlogger.zookeeper.level = INFO\nlogger.netty.name = org.apache.flink.shaded.akka.org.jboss.netty.channel.DefaultChannelPipeline\nlogger.netty.level = OFF\n","logback-console.xml":"<configuration>\n  <appender name=\"console\" class=\"ch.qos.logback.core.ConsoleAppender\">\n    <encoder>\n      <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{60} %X{sourceThread} - %msg%n</pattern>\n    </encoder>\n  </appender>\n  <appender name=\"file\" class=\"ch.qos.logback.core.FileAppender\">\n    <file>${log.file}</file>\n    <append>false</append>\n    <encoder>\n      <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{60} %X{sourceThread} - %msg%n</pattern>\n    </encoder>\n  </appender>\n  <root level=\"INFO\">\n    <appender-ref ref=\"console\"/>\n    <appender-ref ref=\"file\"/>\n  </root>\n  <logger name=\"akka\" level=\"INFO\" />\n  <logger name=\"org.apache.kafka\" level=\"INFO\" />\n  <logger name=\"org.apache.hadoop\" level=\"INFO\" />\n  <logger name=\"org.apache.zookeeper\" level=\"INFO\" />\n  <logger name=\"org.apache.flink.shaded.akka.org.jboss.netty.channel.DefaultChannelPipeline\" level=\"ERROR\" />\n</configuration>\n"}` | The logging configuration, a string-to-string map that becomes the ConfigMap mounted at /opt/flink/conf |
| operatorGroups | list | `["system:masters"]` | (List) A list of groups to grant the operator-role to in the namespace the chart is installed in. |
| podLabels | object | `{"sidecar.istio.io/inject":"false"}` | Extra Labels to be added to pod |
| podMonitor | object | `{"enabled":true,"metricRelabelings":[{"action":"labeldrop","regex":"task_id"},{"action":"labeldrop","regex":"task_attempt_id"},{"action":"labeldrop","regex":"tm_id"}],"podMonitorSelectorLabels":{"prometheus":"cluster-metrics"},"podTargetLabels":["cluster","component"],"portName":"prom","relabelings":[],"sampleLimit":2000,"scrapeInterval":"15s","selector":{"matchLabels":{"app":"flink"}}}` | podMonitor for metrics - you need the Prometheus-Operator and its CRDs up and running in order to use PodMonitor. |
| podMonitor.metricRelabelings | list | `[{"action":"labeldrop","regex":"task_id"},{"action":"labeldrop","regex":"task_attempt_id"},{"action":"labeldrop","regex":"tm_id"}]` | (`map[]`) A list of Prometheus metricRelablings configs applied to the metrics before they are ingested by Prometheus. Use this to reduce cardinality of metrics based on labels that are not critical to monitor. This default list removes the task_id. task_attempt_id, and tm_id labels from the metrics to drastically reduce the cardinality of the very verbose metrics. |
| podMonitor.portName | string | `"prom"` | (`string`) The name of the port exposed by the Flink Operator on the pods that has metrics. |
| podMonitor.relabelings | list | `[]` | (`map[]`) A list of Prometheus relabelings configs applied to the metrics before they are ingested by Prometheus. Use this to reduce cardinality of metrics based on labels that are not critical to monitor. |
| podMonitor.sampleLimit | int | `2000` | (`int`) Per-scrape limit on number of scraped samples that will be accepted. |
| podMonitor.scrapeInterval | string | `"15s"` | (`string`) The frequency in which to scrape metrics. |
| pvc | object | `{"storage":"1Gi","storageClassName":"efs"}` | Configuration of the PersistentVolume for storing savepoints. |
| savepoints | object | `{"enabled":true,"savepointDir":"/savepoint"}` | Configuration of the automatic savepoints |
| savepoints.enabled | bool | `true` | (Boolean) Automatically creates a volume and mount the volume on task manager and job manager pods |
| savepoints.savepointDir | string | `"/savepoint"` | (String) The mount path of the savepoint volume |
| serviceAccount.create | bool | `true` | (Boolean) Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | (String) The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| taskManager.metrics | object | `{"enabled":true,"extraPorts":[{"containerPort":9249,"name":"prom","protocol":"TCP"}]}` | Prometheus metrics ports for taskManager |
| taskManager.replicas | int | `1` | (`int`) The number of TaskManager replicas |
| taskManager.resources | object | `{"limits":{"memory":"1500Mi"},"requests":{"cpu":"100m","memory":"1000Mi"}}` | Compute resources required by TaskManager containers |
| taskManager.securityContext | object | `{"fsGroup":9999,"runAsGroup":9999,"runAsNonRoot":true,"runAsUser":9999}` | Allow flink user to read volumes |
| taskManager.volumeClaimTemplates | list | `[]` | ('list') volumeClaimTemplates for the TaskManager pods |
| taskManager.volumeMounts | list | `[]` | ('list') volumeMounts for the TaskManager containers |
| taskManager.volumes | list | `[]` | ('list') volumes for the TaskManager pods |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)
