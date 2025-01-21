# local-kafka

Local Development spinup of Strimzi-managed Kafka

![Version: 0.43.0](https://img.shields.io/badge/Version-0.43.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

[strimzi_op]: https://github.com/strimzi/strimzi-kafka-operator

This chart provides a fast and local way of spinning up the
[Strimzi-managed][strimzi_op] Kafka environment. This is an opinionated chart
for how simple local Kafka development should be while still using
production-level tooling.

This chart (_by default_) installs the [Strimzi Kafka Operator][strimzi_op],
and then launches a `Kafka` and `KafkaUser` resource. The `KafkaUser` resource
is granted full privileges to create and manage `Topics` and `Groups` within
the Kafka broker. The Kafka Broker is set up as a single, ephemeral pod meant
for quick and dirty local use only.

## Multiple Local Kafka Projects?

If you're developing multiple projects (ie, `featurestore.git` and
`lightstream.git`) - you should treat them as separate projects and launch
separate Kafka environments for each one. Each project's `Chart.yaml` file may
refer to this dependency chart, but ONLY ONE chart may install the Operator.
The rest of the charts should set `Values.strimzi-kafka-operator.enabled:
false`.

That will allow each project to install a local `Kafka` cluster and `KafkaUser`
resource in the development namespace, completely isolated from the _other_
project's development namespace.

## Upgrade Notes

### 0.42.x -> 0.43.x

**NEW: Using KRaft mode instead of Zookeeper mode**

By switching Strimzi to use [KRaft
mode](https://strimzi.io/blog/2024/03/22/strimzi-kraft-migration/) we reduce
the number of pods that have to start up locally and speed up the test process
because we do not have to wait for Zookeeper to start up.

**NEW: Custom Pod Annotations**

When installing the `local-kafka` chart as a dependency purely for testing, it
may be advantageous to add [Helm Chart
Hooks](https://helm.sh/docs/topics/charts_hooks/) that set the order in which
the pods start up. For example, if you want to make sure all of the Kafka pods
are up and ready before your own application pods start up:

```yaml
# values.yaml
local-kafka:
  annotations:
    helm.sh/hook: pre-install
```

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://strimzi.io/charts | strimzi-kafka-operator | 0.45.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| annotations | object | `{}` | Optionall annotations added to all of the resources managed by this template. |
| clusterName | string | `"default"` | Set the name of the Kafka Cluster that is created for local development |
| kafka.brokerVersion | `str` | `nil` | Optional version of Kafka to install (eg, `2.8.0`) |
| kafka.interBrokerProtocolVersion | `str` | `nil` | Optional value for the inter.broker.protocol.version property (eg. `2.8`) |
| kafka.logMessageFormatVersion | `str` | `nil` | Optional value for the log.message.format.version property (eg, `2.7`) |
| kafka.priorityClassName | `str` | `nil` | Optional value for the kafka cluster pod priority class name |
| listeners | list | `[{"configuration":{"brokers":[{"advertisedHost":"127.0.0.1","broker":0,"nodePort":32000}]},"name":"external","port":9094,"tls":false,"type":"nodeport"}]` | Additional configurable listeners for connecting to brokers. |
| namespaceOverride | string | `nil` | Optionally force the namespace that the resources in this stack are launched in. Without this, the default namespace that the Helm chart is being put into is used. It is recommended to keep this empty. |
| podAnnotations | object | `{}` | Optional annotations added to all of the Strimzi-managed Pods. |
| strimzi-kafka-operator.enabled | bool | `true` | Set to `false` to intentionally disable installation of the Operator. This is useful if you are running this stack in a local dev environment where you might have multiple Kafka environments, and are already running the Strimzi operator. |
| strimzi-kafka-operator.image.name | `str` | `"operator"` | Cluster Operator image name |
| strimzi-kafka-operator.image.registry | `str` | `""` | Override default Cluster Operator image registry |
| strimzi-kafka-operator.image.repository | `str` | `""` | Override default Cluster Operator image repository |
| strimzi-kafka-operator.image.tag | `str` | `""` | Override default Cluster Operator image tag |
| strimzi-kafka-operator.logLevel | string | `"INFO"` | Optionally run the Operator in a pretty verbose mode - allowing developers to more easily understand if there are any problems with the operator installation or its behavior. |
| strimzi-kafka-operator.resources | object | `{"limits":{"memory":"1Gi"},"requests":{"cpu":"250m","memory":"512Mi"}}` | Reconfigure the default resource requirements here so that the "requests" are as low as possible for memory (so we're not allocating any more memory than we absolutely must). |
| strimzi-kafka-operator.watchAnyNamespace | bool | `true` | Because you can only install one Strimzi Operator helm chart in a cluster, we might as well set this to True. This allows the chart to be re-used (with `strimzi-kafka-operator.enabled: false`) by other local development projects. |
| userName | string | `"user"` | Set the name of the KafkaUser that is created for local development |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
