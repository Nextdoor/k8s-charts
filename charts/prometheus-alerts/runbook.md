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
