# daemonset-app

Default DaemonSet Helm Chart

![Version: 0.5.2](https://img.shields.io/badge/Version-0.5.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

[statefulsets]: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/
[hpa]: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

This chart provides a standard deployment for operating a [stateful application
in Kubernetes][statefulsets]. The chart provides all of the common pieces like
ServiceAccounts, Services, etc.

## Upgrade Notes

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