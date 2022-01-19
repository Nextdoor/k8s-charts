## CPUThrottlingHigh

This alert fires if any particular container is experiencing throttling by the
Linux CFS system. This typically means that your container is operating close
to its Kubernetes `resource.limits` configuration. You can quickly look at the
utilization of the individual containers within a given pod or namespace like
this:

    $ k top pods --containers
    POD                                      NAME               CPU(cores)   MEMORY(bytes)
    datadog-agent-2qk9w                      agent              22m          65Mi
    datadog-agent-2qk9w                      process-agent      10m          35Mi
    datadog-agent-2qk9w                      system-probe       6m           34Mi
    datadog-agent-2qk9w                      trace-agent        2m           27Mi

You can compare the actual used CPU and Memory values with the pod through the
`kubectl describe pod <pod>` command:

    $ k describe pod datadog-agent-2qk9w
    Name:                 datadog-agent-2qk9w
    Namespace:            datadog-operator
    ...
    Containers:
      agent:
      ...
        Limits:
          cpu:     25m
          memory:  256Mi
        Requests:
          cpu:      10m
          memory:   96Mi

In the example above, you can see that the `agent` has a CPU Limit of `25m`,
but its running at `22m`... so its pretty close to its actual limits. It's
resource limits should likely be adjusted.

## KubeQuotaAlmostFull

This alert telling you that the resources requested by all of the `Pods` in
your `Namespace` are close to the `Quota` limits that have been assigned. You
can inspect any quotas or limits placed on your `Namespace` like this:

    $ kubectl describe namespace my-namespace
    Name:         my-namespace
    Status:       Active

    Resource Quotas
     Name:             default-quotas
     Resource          Used     Hard
     --------          ---      ---
     limits.cpu        10500m   64
     limits.memory     18816Mi  128Gi
     requests.cpu      8500m    64
     requests.memory   16256Mi  128Gi
     requests.storage  105Gi    512Gi

    Resource Limits
     Type       Resource  Min  Max   Default Request  Default Limit  Max Limit/Request Ratio
     ----       --------  ---  ---   ---------------  -------------  -----------------------
     Container  cpu       -    8     0                0              -
     Container  memory    -    16Gi  128Mi            128Mi          -

## KubeQuotaFullyUsed

Similar to the `KubeQuotaAlmostFull` alert - but you are now out of resources.
At this point you cannot launch or scale any new resources until you reduce
your usage, or work with an administrator to expand your `Quota` capacity.

## Alert Name: `KubeStatefulSetGenerationMismatch`

This alert indicates that a change to a `StatefulSet` resource has been applied, but
is not rolling out properly. Check the status of the `StatefulSet` using `kubectl describe`:

```bash
$ kubectl describe sts observability-loki-ingester
Name:               observability-loki-ingester
Namespace:          observability
CreationTimestamp:  Mon, 02 Aug 2021 08:08:37 -0700
...
Events:
  Type     Reason        Age                   From                    Message
  ----     ------        ----                  ----                    -------
  Warning  FailedCreate  2m10s (x21 over 57m)  statefulset-controller  create Pod observability-loki-ingester-0 in StatefulSet observability-loki-ingester failed error: Pod "observability-loki-ingester-0" is invalid: [spec.containers[0].resources.limits[limit]: Invalid value: "limit": must be a standard resource type or fully qualified, spec.containers[0].resources.limits[limit]: Invalid value: "limit": must be a standard resource for containers, spec.containers[0].resources.requests[limit]: Invalid value: "limit": must be a standard resource type or fully qualified, spec.containers[0].resources.requests[limit]: Invalid value: "limit": must be a standard resource for containers]
```

The events will most likely tell you what is wrong, and how to fix it.

## Alert Name: `KubePodNotReady`

This alert indicates that a pod has not managed to reach the "running" state 
within 15 minutes. Investigating the pod state and the events for the pod should
help you determine the root cause of the issue. Follow the instructions in the
(k8s repo wiki)[https://github.com/Nextdoor/k8s/wiki#remote-cluster-access] to log
into the relevant cluster and namespace, and use the `kubectl describe pod <podname>`
to see the status of the pod and any events related to it. The pod logs may also 
provide hints as to what may be going wrong.
