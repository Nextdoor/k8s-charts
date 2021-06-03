# istio-endpoints

Per-Namespace Istio Configuration Chart

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

[elasticache]: https://aws.amazon.com/elasticache/
[serviceentry]: https://istio.io/latest/docs/reference/config/networking/service-entry/
[envoyfilter]: https://istio.io/latest/docs/reference/config/networking/envoy-filter/
[sidecar]: https://istio.io/latest/docs/reference/config/networking/sidecar/
[envoy]: https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/other_protocols/redis

This small chart helps configure the [Istio Proxy Sidecar][sidecar] pods in a
given `Namespace` to route traffic to AWS managed [ElastiCache][elasticache]
clusters or services. This assumes that you are running the Istio Service Mesh
inside of your cluster already, and have a need to use [Envoy's
RedisProxy][envoy] configuration to handle traffic routing to the ElastiCache
services.

**Pre-Req: `PILOT_ENABLE_REDIS_FILTER=true` must be set in your Istio Pilot Config**

If you are using the [Istio
Operator](https://istio.io/latest/docs/reference/commands/operator/), your
`IstioOperator` resource must enable the `RedisProxy` filter. This filter
allows Envoy to understand the `REDIS` protocol, and automatically configures
the filter when necessary.

```yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: istio-control-plane
spec:
  components:
    pilot:
      k8s:
        env:
          - name: PILOT_ENABLE_REDIS_FILTER
            value: 'true'
```

## Usage

### Add to your `Chart.yaml` dependencies:

```diff
  apiVersion: v2
  name: simple-app
  description: Default Microservice Helm Chart
  type: application
  version: 0.7.0
  appVersion: latest
+ dependencies:
+   - name: istio-endpoints
+     repository: https://k8s-charts.nextdoor.com
+     version: 0.1.0
  maintainers:
    - name: diranged
      email: matt@nextdoor.com
```

### Set up your list of ElastiCache AWS Endpoints

```yaml
# values.yaml
istio-endpoints:
  test:
    address: staging-cluster.abcd8x.clustercfg.usw2.cache.amazonaws.com
    bindPort: 1234          # required
    bindAddress: 127.0.0.2  # required
    targetPort: 6379        # optional
    opTimeout: 0.5s         # optional
    readPolicy: REPLICA     # optional
```

## Per ServiceEndpoint Configurations

### ElastiCache Endpoint Options

 * `bindPort`: Required port that the `istio-proxy` sidecar will listen on to
   route traffic to the Redis cluster.
 * `bindAddress`: Required address that the `istio-proxy` idecar will listen on
   to route traffic to the Redis cluster. Suggestion here is to use somethign
   in the loopback-IP space (`172.0.0.0/8`).
 * `targetPort`: Optional override for the target port of the AWS ElastiCache
   Cluster. If you do not specify a value, the
   `Values.defaults.elasticacheTargetPort` value will be applied.
 * `opTimeout`: Optional override for the per-operation timeout that Envoy will
   use to cancel slow operations. If you do not specify a value, the
   `Values.defaults.elasticacheOpTimeout` value will be applied.
 * `readPolicy`: Optional override for the Envoy RedisProxy configuration that
   will route traffic to specific types of endpoints in the backing cluster. If
   you do not specify a value, the `Values.defaults.elasticacheReadPolicy`
   value will be applied.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| defaults.clusterDomain | string | `"svc.cluster.local"` | (`String`) The cluster-level domain name that is applied to TCP-routed ServiceEndpoints within the Istio configuration. This should match the internal cluster domain name, but cannot be automatically determined. |
| defaults.elasticacheOpTimeout | string | `"0.2s"` | (`String`) Default per-operation timeout applied to every endpoint in the Values.elasticacheEndpoints list (unless they override it) - [documentation here](https://www.envoyproxy.io/docs/envoy/latest/api-v3/extensions/filters/network/redis_proxy/v3/redis_proxy.proto.html#extensions-filters-network-redis-proxy-v3-redisproxy-connpoolsettings). This string should be time-format (1s,1ms,0.1s,1m, etc). |
| defaults.elasticacheReadPolicy | string | `"ANY"` | (`String`) ReadPolicy controls how Envoy routes read commands to Redis nodes. This is currently supported for Redis Cluster. All ReadPolicy settings except MASTER may return stale data because replication is asynchronous and requires some delay. You need to ensure that your application can tolerate stale data. [Documentation here](https://www.envoyproxy.io/docs/envoy/latest/api-v3/extensions/filters/network/redis_proxy/v3/redis_proxy.proto.html#envoy-v3-api-enum-extensions-filters-network-redis-proxy-v3-redisproxy-connpoolsettings-readpolicy) for options. |
| defaults.elasticacheTargetPort | int | `6379` | (`Integer`) The default target-port that the ElastiCache ServiceEntries will send traffic to in AWS. This should only change if you launch ElastiCache clusters with non-standard port configurations. |
| elasticacheEndpoints | object | `{}` | (`Map`) A key/value map with all of the elasticacheEndpoints that need to be configured for the Namespace. Each Key is a human-readable name for the endpoint, and then each value is a Map with a configuration. See the [README](#elasticache-endpoint-options) for more instructions. |
| fullnameOverride | string | `""` | (`String`) Overrides the full prefix of all of the resources. |
| nameOverride | string | `""` | (`String`) Overrides the main "release name" of the resources. |
| sidecar.catchAllCaptureMode | string | `"IPTABLES"` | (`String`) Default `captureMode` that the final "catch all" [IstioEgressListener](https://istio.io/latest/docs/reference/config/networking/sidecar/#IstioEgressListener) will run in. Default values are here for your reference. |
| sidecar.catchAllHosts | list | `["*/*"]` | (`Strings[]`) Default `hosts` that the final "catch all" [IstioEgressListener](https://istio.io/latest/docs/reference/config/networking/sidecar/#IstioEgressListener) will monitor for. The default value catches all resources across the cluster. |
| sidecar.enabled | bool | `true` | (`Bool`) Controls whether or not a `Sidecar` resource is created within the Namespace to help reconfigure the local listeners and routing configuration for your Pods. This defaults to `true` because it is required in order to properly set up Listeners that work for ElastiCache. You can disable this if you are going to manage your own `Sidecar` resource. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)
