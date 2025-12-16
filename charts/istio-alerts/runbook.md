## 5xx-Rate-Too-High

This alert fires when the rate of 5xx responses from a service exceeds a
threshold (default, 0.05% for 5m). A 5xx indicates that some sort of server-side
error is occurring, and you should investigate which status codes are being
returned to investigate this alarm. A breakdown of responses by status code
can be found in grafana on the "Istio Service Dashboard". Be sure to navigate
to the grafana deployment for the correct EKS cluster and select the relevant
service. Many services have custom dashboards in DataDog as well which may help
investigate this alert further, and most service also produce logs of requests
which may provide more context into what errors are being returned and why.

Can check trends/graph by:

1. Going to your Grafana instance and navigating to the `Explore` tab
2. Entering the following Prometheus query (replace `cluster` and `destination_service_namespace`):

```
sum by (destination_service_name, reporter) (
  rate(istio_requests_total{cluster="<x>", response_code=~"5.*", destination_service_namespace="<y>"}[5m])
)

/

sum by (destination_service_name, reporter) (
  rate(istio_requests_total{cluster="<x>", destination_service_namespace="<y>"}[5m])
)
```

Action Items:

1. If trends are expected, tweak your thresholds (away from the [default 0.05% for 5 minutes](https://github.com/Nextdoor/k8s-charts/blob/f2d3973a1a9292e7c59e3feb4eb49df93dea926d/charts/istio-alerts/values.yaml#L28-L41)).
2. If the response codes are unexpected, debug your app to see why the increase in error responses.

## HighRequestLatency

This alert fires when the request latency for a service exceeds a threshold
(default: 0.5s at the 95th percentile for 15m). High request latency indicates
that your service is responding slower than expected, which can impact user
experience and downstream services. You should investigate what's causing the
increased response times.

Can check trends/graph by:

1. Going to your Grafana instance and navigating to the `Explore` tab
2. Entering the following Prometheus query (replace `cluster` and `destination_service_namespace`):

```
histogram_quantile(
  0.95,
  sum(irate(
    istio_request_duration_milliseconds_bucket{
      cluster="<x>",
      destination_service_namespace="<y>"
    }[5m]
  )) by (
    destination_service_name,
    reporter,
    source_canonical_service,
    le
  )
) / 1000
```

3. You can also check the "Istio Service Dashboard" in Grafana for latency breakdowns by percentile and source

Common causes and action items:

1. **Check service health**: Use `kubectl` to verify pod health, restarts, and resource usage
   ```bash
   kubectl --context <context> get pods -n <namespace>
   kubectl --context <context> top pods -n <namespace>
   kubectl --context <context> describe pod <pod-name> -n <namespace>
   ```

2. **Review application logs**: Check for slow queries, timeouts, or errors in your application logs that correlate with the latency spike

3. **Database performance**: If your service uses a database, check for:
   - Slow queries
   - Connection pool exhaustion
   - Database load/CPU usage
   - Missing indexes

4. **Downstream dependencies**: Check if any downstream services or APIs your service calls are experiencing latency issues

5. **Resource constraints**: Verify the service has adequate:
   - CPU and memory limits
   - Database connection pool size
   - Thread pool size

6. **Traffic patterns**: Check if there's a traffic spike that might be overwhelming the service
   ```
   sum(rate(istio_requests_total{
     cluster="<x>",
     destination_service_namespace="<y>"
   }[5m])) by (destination_service_name)
   ```

7. **If trends are expected**: Adjust thresholds (away from the [default 0.5s for 15 minutes](https://github.com/Nextdoor/k8s-charts/blob/main/charts/istio-alerts/values.yaml#L48-L66)) or change the percentile being monitored

8. **If latency is unexpected**: Investigate your application performance, enable detailed tracing/profiling, and review recent deployments or configuration changes

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
