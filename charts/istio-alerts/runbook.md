## 5xx-Rate-Too-High

This alert fires when the rate of 5xx responses from a service exceeds a
threshold (by default, 0.05%). A 5xx indicates that some sort of server-side
error is occurring, and you should investigate which status codes are being
returned to investigate this alarm. A breakdown of responses by status code
can be found in grafana on the "Istio Service Dashboard" (e.g. [this one](https://grafana.us1-eks.nextdoor.com/d/LJ_uJAvmk/istio-service-dashboard)).
Be sure to navigate to the grafana deployment for the correct EKS cluster and
select the relevant service. Many services have custom dashboards in DataDog
as well which may help investigate this alert further, and most service also
produce logs of requests which may provide more context into what errors are
being returned and why.
