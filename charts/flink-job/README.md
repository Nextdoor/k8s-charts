# flink-job

Flink job cluster on k8s

![Version: 0.1.24](https://img.shields.io/badge/Version-0.1.24-informational?style=flat-square) ![AppVersion: 1.0](https://img.shields.io/badge/AppVersion-1.0-informational?style=flat-square)

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
| alerts.enabled | Boolean | `true` | Specifies whether to create the PrometheusRule for this flink cluster |
| alerts.restartsLimit | `int` | `2` | The number of job restarts before alerting |
| alerts.severity | String | `"info"` | Severity of the alerts |
| batchSchedulerName | String | `nil` | specifies the batch scheduler name for JobManager, TaskManager. If empty, no batch scheduling is enabled |
| defaults.runbookUrl | String | `"https://github.com/Nextdoor/k8s-charts/blob/main/charts/flink-job/runbook.md"` | Runbook URL for the Prometheus alerts |
| envVars | list | `[{"name":"HADOOP_CLASSPATH","value":"/opt/flink/opt/flink-metrics-prometheus-1.9.3.jar"}]` | Environment variables shared by all containers |
| flinkProperties | `Map` | `{"execution.checkpointing.interval":"10min","execution.checkpointing.mode":"EXACTLY_ONCE","high-availability":"org.apache.flink.kubernetes.highavailability.KubernetesHaServicesFactory","high-availability.storageDir":"file:/savepoint/","kubernetes.cluster-id":"{{ .Values.fullnameOverride }}","kubernetes.namespace":"{{ .Release.Namespace }}","metrics.reporter.prom.class":"org.apache.flink.metrics.prometheus.PrometheusReporter","metrics.reporters":"prom","restart-strategy":"exponential-delay","restart-strategy.exponential-delay.backoff-multiplier":"2.0","state.checkpoints.dir":"file:/savepoint/","taskmanager.numberOfTaskSlots":"1"}` | Flink properties which are appened to flink-conf.yaml |
| flinkVersion | String | `nil` | The Flink version to operate |
| fullnameOverride | String | `"word-counting-cluster"` | The name of the flink cluster |
| image.pullPolicy | String | `"IfNotPresent"` | Always, Never or IfNotPresent |
| image.repository | String | `"flink"` | The Flink image name and repository |
| image.tag | String | `"1.13.1"` | The Flink image tag |
| job.allowNonRestoredState | String | `false` | Should allow to skip state that cannot be mapped to the new program when drop an operator |
| job.args | List | `["--input","./README.txt","--output","./OUTPUT.txt"]` | Command-line args of the job |
| job.autoSavepointSeconds | `int` | `30` | Automatically take a savepoint to the savepointsDir in this given interval |
| job.className | String | `"org.apache.flink.streaming.examples.wordcount.WordCount"` | Java class name of the job |
| job.cleanupPolicy | object | `{"afterJobCancelled":"KeepCluster","afterJobFails":"KeepCluster","afterJobSucceeds":"KeepCluster"}` | The action to take after job finishes enum("KeepCluster", "DeleteCluster", "DeleteTaskManager") |
| job.fromSavepoint | String | `nil` | Savepoint where to restore the job from. Unspecify if to restore from the latest savepoint |
| job.initContainers | object | `{"enabled":false}` | Init containers of the Job pod. It can be used to download a remote job jar to your job pod. It is only needed if you have no other way to download your job files into the Flink job cluster. |
| job.jarFile | String | `"./examples/streaming/WordCount.jar"` | JAR file of the job |
| job.mode | String | `"Detached"` | JobMode of the job submitter, either Detached or Blocking |
| job.nodeSelector | string | `nil` | The node selector for the job |
| job.parallelism | `int` | `1` | Parallelism of the job |
| job.resources | string | `nil` | The resources for the job |
| job.restartPolicy | String | `"FromSavepointOnFailure"` | Restart policy when the job fails, enum("Never", "FromSavepointOnFailure") |
| job.savepointGeneration | `int` | `nil` | Update this field to jobStatus.savepointGeneration + 1 for a running job cluster to trigger a new savepoint to savepointsDir on demand. |
| job.savepointsDir | String | `"/savepoint"` | Directory to store automatically taken savepoints |
| job.takeSavepointOnUpdate | bool | `true` | Should take savepoint before upgrading the job |
| jobManager.accessScope | String | `"Cluster"` | Access scope of the JobManager service. enum("Cluster", "VPC", "External", "NodePort", "Headless") |
| jobManager.affinity | `map` | `{}` | Affinity for the JobManager. |
| jobManager.memoryProcessRatio | 'int' | `80` | Percentage of memory process, as a safety margin to avoid OOM kill |
| jobManager.metrics | object | `{"enabled":true,"extraPorts":[{"containerPort":9249,"name":"prom"}]}` | Prometheus metrics ports for jobManager |
| jobManager.ports.blob | `int` | `6124` | Blob port that JobManager listening on |
| jobManager.ports.query | `int` | `6125` | Query ports that JobManager listening on |
| jobManager.ports.rpc | `int` | `6123` | RPC port that JobManager listening on |
| jobManager.ports.ui | `int` | `8081` | UI port that JobManager listening on |
| jobManager.replicas | `int` | `1` | The number of JobManager replicas |
| jobManager.resources | object | `{"limits":{"memory":"1400Mi"},"requests":{"cpu":"100m","memory":"1000Mi"}}` | Compute resources required by JobManager container |
| logConfig | object | `{"log4j-console.properties":"rootLogger.level = INFO\nrootLogger.appenderRef.file.ref = LogFile\nrootLogger.appenderRef.console.ref = LogConsole\nrootLogger.formatMsgNoLookups = true\nappender.file.name = LogFile\nappender.file.type = File\nappender.file.append = false\nappender.file.fileName = ${sys:log.file}\nappender.file.layout.type = PatternLayout\nappender.file.layout.pattern = %d{yyyy-MM-dd HH:mm:ss,SSS} %-5p %-60c %x - %m%n\nappender.console.name = LogConsole\nappender.console.type = CONSOLE\nappender.console.layout.type = PatternLayout\nappender.console.layout.pattern = %d{yyyy-MM-dd HH:mm:ss,SSS} %-5p %-60c %x - %m%n\nlogger.akka.name = akka\nlogger.akka.level = INFO\nlogger.kafka.name= org.apache.kafka\nlogger.kafka.level = INFO\nlogger.hadoop.name = org.apache.hadoop\nlogger.hadoop.level = INFO\nlogger.zookeeper.name = org.apache.zookeeper\nlogger.zookeeper.level = INFO\nlogger.netty.name = org.apache.flink.shaded.akka.org.jboss.netty.channel.DefaultChannelPipeline\nlogger.netty.level = OFF\n","logback-console.xml":"<configuration>\n  <appender name=\"console\" class=\"ch.qos.logback.core.ConsoleAppender\">\n    <encoder>\n      <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{60} %X{sourceThread} - %msg%n</pattern>\n    </encoder>\n  </appender>\n  <appender name=\"file\" class=\"ch.qos.logback.core.FileAppender\">\n    <file>${log.file}</file>\n    <append>false</append>\n    <encoder>\n      <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{60} %X{sourceThread} - %msg%n</pattern>\n    </encoder>\n  </appender>\n  <root level=\"INFO\">\n    <appender-ref ref=\"console\"/>\n    <appender-ref ref=\"file\"/>\n  </root>\n  <logger name=\"akka\" level=\"INFO\" />\n  <logger name=\"org.apache.kafka\" level=\"INFO\" />\n  <logger name=\"org.apache.hadoop\" level=\"INFO\" />\n  <logger name=\"org.apache.zookeeper\" level=\"INFO\" />\n  <logger name=\"org.apache.flink.shaded.akka.org.jboss.netty.channel.DefaultChannelPipeline\" level=\"ERROR\" />\n</configuration>\n"}` | The logging configuration, a string-to-string map that becomes the ConfigMap mounted at /opt/flink/conf |
| nodeSelector | `map` | `nil` | [Node selector] for Job Manager and Task Manager |
| operatorGroups | List | `["system:masters"]` | A list of groups to grant the operator-role to in the namespace the chart is installed in. |
| podLabels | object | `{"sidecar.istio.io/inject":"false"}` | Extra Labels to be added to pod |
| podMonitor | object | `{"enabled":true,"metricRelabelings":[{"action":"labeldrop","regex":"task_id"},{"action":"labeldrop","regex":"task_attempt_id"},{"action":"labeldrop","regex":"tm_id"}],"podMonitorSelectorLabels":{"prometheus":"cluster-metrics"},"podTargetLabels":["cluster","component"],"portName":"prom","relabelings":[],"sampleLimit":2000,"scrapeInterval":"60s","selector":{"matchLabels":{"app":"flink"}}}` | podMonitor for metrics - you need the Prometheus-Operator and its CRDs up and running in order to use PodMonitor. |
| podMonitor.metricRelabelings | `map[]` | `[{"action":"labeldrop","regex":"task_id"},{"action":"labeldrop","regex":"task_attempt_id"},{"action":"labeldrop","regex":"tm_id"}]` | A list of Prometheus metricRelablings configs applied to the metrics before they are ingested by Prometheus. Use this to reduce cardinality of metrics based on labels that are not critical to monitor.  This default list removes the task_id. task_attempt_id, and tm_id labels from the metrics to drastically reduce the cardinality of the very verbose metrics. |
| podMonitor.portName | `string` | `"prom"` | The name of the port exposed by the Flink Operator on the pods that has metrics. |
| podMonitor.relabelings | `map[]` | `[]` | A list of Prometheus relabelings configs applied to the metrics before they are ingested by Prometheus. Use this to reduce cardinality of metrics based on labels that are not critical to monitor. |
| podMonitor.sampleLimit | `int` | `2000` | Per-scrape limit on number of scraped samples that will be accepted. |
| podMonitor.scrapeInterval | `string` | `"60s"` | The frequency in which to scrape metrics. |
| pvc | object | `{"accessModes":["ReadWriteMany"],"storage":"1Gi","storageClassName":"efs"}` | Configuration of the PersistentVolume for storing savepoints. |
| pvc.accessModes | `strings[]` | `["ReadWriteMany"]` | List of Access Modes. |
| recreateOnUpdate | bool | `true` | Recreate components when updating flinkcluster |
| savepoints | object | `{"enabled":true,"savepointDir":"/savepoint"}` | Configuration of the automatic savepoints |
| savepoints.enabled | Boolean | `true` | Automatically creates a volume and mount the volume on task manager and job manager pods |
| savepoints.savepointDir | String | `"/savepoint"` | The mount path of the savepoint volume |
| serviceAccount.create | Boolean | `true` | Specifies whether a service account should be created |
| serviceAccount.name | String | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| taskManager.affinity | `map` | `{}` | Affinity for the TaskManager. |
| taskManager.memoryProcessRatio | 'int' | `80` | Percentage of memory process, as a safety margin to avoid OOM kill |
| taskManager.metrics | object | `{"enabled":true,"extraPorts":[{"containerPort":9249,"name":"prom","protocol":"TCP"}]}` | Prometheus metrics ports for taskManager |
| taskManager.ports.data | `int` | `6121` | Data port that TaskManager listening on |
| taskManager.ports.query | `int` | `6125` | Query port that TaskManager listening on |
| taskManager.ports.rpc | `int` | `6122` | RPC port that TaskManager listening on |
| taskManager.replicas | `int` | `1` | The number of TaskManager replicas |
| taskManager.resources | object | `{"limits":{"memory":"1500Mi"},"requests":{"cpu":"100m","memory":"1000Mi"}}` | Compute resources required by TaskManager containers |
| taskManager.securityContext | object | `{"fsGroup":9999,"runAsGroup":9999,"runAsNonRoot":true,"runAsUser":9999}` | Allow flink user to read volumes |
| taskManager.volumeClaimTemplates | 'list' | `[]` | volumeClaimTemplates for the TaskManager pods |
| taskManager.volumeMounts | 'list' | `[]` | volumeMounts for the TaskManager containers |
| taskManager.volumes | 'list' | `[]` | volumes for the TaskManager pods |
| tolerations | `map` | `nil` | [Tolerations] for Job Manager and Task Manager |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
