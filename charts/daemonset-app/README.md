# daemonset-app

Default DaemonSet Helm Chart

![Version: 0.6.1](https://img.shields.io/badge/Version-0.6.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

[statefulsets]: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/
[hpa]: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

This chart provides a standard deployment for operating a [stateful application
in Kubernetes][statefulsets]. The chart provides all of the common pieces like
ServiceAccounts, Services, etc.

## Upgrade Notes

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