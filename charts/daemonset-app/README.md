# daemonset-app

Default DaemonSet Helm Chart

![Version: 0.9.1](https://img.shields.io/badge/Version-0.9.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

[statefulsets]: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/
[hpa]: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

This chart provides a standard deployment for operating a [stateful application
in Kubernetes][statefulsets]. The chart provides all of the common pieces like
ServiceAccounts, Services, etc.

## Upgrade Notes

### 0.8.x -> 0.9.x

**BREAKING: `NetworkPolicy` no longer allows all traffic by default**

It is not the rule that `DaemonSets` should always allow all traffic from all
Namespaces by default. In fact, it is likely not true in a large shared
cluster. A new setting `.Values.allowedNamespaces` is set up for you to
explicitly define which namespaces can access the service. If you need all
services to access it, use `.Values.network.allowedNamespaces: ['*']`.

### 0.7.x -> 0.8.x

**NEW: Always create a `Service` Resource**

In order to make sure that the Istio Service Mesh can always determine
"locality" for client and server workloads, we _always_ create a `Service`
object now that is used by Istio to track the endpoints and determine their
locality. This `Service` may not expose any real ports to the rest of the
network, but is still critical for Istio.

**Switched `PodMonitor` to `ServiceMonitor`**

Because we are always creating a `Service` resource now, we've followed the
Prometheus Operator recommendations and switched to using a `ServiceMonitor`
object. The metrics stay the same, but for some reason the `ServiceMonitor` is
preferred.

### 0.6.x -> 0.7.x

**BREAKING: Rolled back to Values.prometheusRules**

The use of nested charts within nested charts is problematic, and we have
rolled it back. Please use `Values.prometheusRules` to configure alarms. We
will deprecate the `prometheus-alerts` chart.

### 0.5.0 -> 0.6.0

**NEW: PrometheusRules are enabled by default!!**

Going forward, the
[`prometheus-alerts](https://github.com/Nextdoor/k8s-charts/tree/main/charts/prometheus-alerts)
chart will be installed _by default_ for you and configured to monitor your
basic resources. If you want to disable it or reconfigure the alerts, the
configuration lives in the `.Values.alerts` key.

### 0.4.0 -> 0.5.0

**BREAKING: `volumesString` parameter removed!**

The `.Values.volumesString` parameter was a hack intended to let you get your
`spec.volumes` run through the `tpl` function for dynamic resource names. We
have reconfigured the way the code works, and this is no longer necessary. You
can now just write this:

```yaml
# values.yaml
app:
  volumes:
    - name: myvol
      configMap:
        name: "