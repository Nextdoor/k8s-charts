## 5xx-Rate-Too-High

This alert fires when the rate of 5xx responses from a service exceeds a
threshold (by default, 0.05%). A 5xx indicates that some sort of server-side
error is occurring, and you should investigate which status codes are being
returned to investigate this alarm. A breakdown of responses by status code
can be found in grafana on the "Istio Service Dashboard". Be sure to navigate
to the grafana deployment for the correct EKS cluster and select the relevant
service. Many services have custom dashboards in DataDog as well which may help
investigate this alert further, and most service also produce logs of requests
which may provide more context into what errors are being returned and why.

## Alert-Rules-Selectors-Validity

This alert fires when there may be an error in setting the proper selectors used
by the other alerts in this chart. It attempts to read a basic metric using the
selector you provided. For instance, if you have a pod selector that looks for
`pod=~"foo-bar-.*"` but your pods are actually named `baz-.*`, this alert will
notify you of the misconfiguration. Read the alert description to see exactly
which selector is having an issue. Also note that you need to collect the
metrics that this alert uses. For instance, to test pod selectors, we use the
`kube_pod_info` metric. If you do not collect this metric, this alert will
continiously fire.
