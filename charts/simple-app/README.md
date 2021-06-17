# simple-app

Default Microservice Helm Chart

![Version: 0.9.5](https://img.shields.io/badge/Version-0.9.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

[deployments]: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
[hpa]: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

This chart provides a default deployment for a simple application that operates
in a [Deployment][deployments]. The chart automatically configures various
defaults for you like the Kubernetes [Horizontal Pod Autoscaler][hpa].

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| autoscaling.enabled | bool | `false` | Controls whether or not an HorizontalPodAutoscaler resource is created. |
| autoscaling.maxReplicas | int | `100` | Sets the maximum number of Pods to run |
| autoscaling.minReplicas | int | `1` | Sets the minimum number of Pods to run |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Configures the HPA to target a particular CPU utilization percentage |
| env | list | `[]` | Environment Variables for the primary container. These are all run through the tpl function (the key name and value), so you can dynamically name resources as you need. |
| envFrom | list | `[]` | Pull all of the environment variables listed in a ConfigMap into the Pod. See https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#configure-all-key-value-pairs-in-a-configmap-as-container-environment-variables for more details. |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` | (String) Always, Never or IfNotPresent |
| image.repository | string | `"nginx"` | (String) The Docker image name and repository for your application |
| image.tag | String | `nil` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Supply a reference to a Secret that can be used by Kubernetes to pull down the Docker image. This is only used in local development, in combination with our `kube_create_ecr_creds` function from dotfiles. |
| ingress.annotations | object | `{}` | Any annotations you wish to add to the ALB. See https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/annotations/ for more details. |
| ingress.enabled | bool | `false` |  |
| ingress.host | string | `"{{ include \"simple-app.fullname\" . }}.{{ .Release.Namespace }}"` | This setting configures the ALB to listen specifically to requests for this hostname. It _also_ ties into the external-dns controller and automatically provisions DNS hostnames matching this value (presuming that they are allowed by the cluster settings). |
| ingress.path | string | `"/"` | See the `ingress.pathType` setting documentation. |
| ingress.pathType | string | `"Prefix"` | https://kubernetes.io/docs/concepts/services-networking/ingress/#path-types |
| ingress.port | string | `nil` | If set, this will override the `service.portName` parameter, and the `Service` object will point specifically to this port number on the backing Pods. |
| ingress.portName | string | `"http"` | This is the port "name" that the `Service` will point to on the backing Pods. This value must match one of the values of `.name` in the `Values.ports` configuration. |
| ingress.sslRedirect | bool | `true` | If `true`, then this will annotate the Ingress with a special AWS ALB Ingress Controller annotation that configures an SSL-redirect at the ALB level. |
| livenessProbe | object | `{"httpGet":{"path":"/","port":"http"}}` | A PodSpec container "livenessProbe" configuration object. Note that this livenessProbe will be applied to the proxySidecar container instead if that is enabled. |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` | (`Map`) List of Annotations to be added to the PodSpec |
| podDisruptionBudget | object | `{}` | Set up a PodDisruptionBudget for the Deployment. See https://kubernetes.io/docs/tasks/run-application/configure-pdb/ for more details. |
| podLabels | object | `{}` | (`Map`) List of Labels to be added to the PodSpec |
| podSecurityContext | object | `{}` |  |
| ports | list | `[{"containerPort":80,"name":"http","protocol":"TCP"},{"containerPort":443,"name":"https","protocol":"TCP"}]` | A list of Port objects that are exposed by the service. These ports are applied to the main container, or the proxySidecar container (if enabled). The port list is also used to generate Network Policies that allow ingress into the pods. |
| proxySidecar.enabled | bool | `false` | (Boolean) Enables injecting a pre-defined reverse proxy sidecar container into the Pod containers list. |
| proxySidecar.env | list | `[]` | Environment Variables for the primary container. These are all run through the tpl function (the key name and value), so you can dynamically name resources as you need. |
| proxySidecar.envFrom | list | `[]` | Pull all of the environment variables listed in a ConfigMap into the Pod. See https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#configure-all-key-value-pairs-in-a-configmap-as-container-environment-variables for more details. |
| proxySidecar.image.pullPolicy | string | `"IfNotPresent"` | (String) Always, Never or IfNotPresent |
| proxySidecar.image.repository | string | `"nginx"` | (String) The Docker image name and repository for the sidecar |
| proxySidecar.image.tag | string | `"latest"` | (String) The Docker tag for the sidecar |
| proxySidecar.name | string | `"proxy"` | (String) The name of the proxy sidecar container |
| proxySidecar.resources | object | `{}` | A PodSpec "Resources" object for the proxy container |
| proxySidecar.volumeMounts | list | `[]` | List of VolumeMounts that are applied to the proxySidecar container - these must refer to volumes set in the `Values.volumes` parameter. |
| readinessProbe | object | `{"httpGet":{"path":"/","port":"http"}}` | A PodSpec container "readinessProbe" configuration object. Note that this readinessProbe will be applied to the proxySidecar container instead if that is enabled. |
| replicaCount | int | `1` | The number of Pods to start up by default. If the `autoscaling.enabled` parameter is set, then this serves as the "start scale" for an application. |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tests.connection.args | list | `["{{ include \"simple-app.fullname\" . }}"]` | A list of arguments passed into the command. These are run through the tpl function. |
| tests.connection.command | list | `["curl","--retry-connrefused","--retry","5"]` | The command used to trigger the test. |
| tests.connection.image.repository | string | `nil` | Sets the image-name that will be used in the "connection" integration test. If this is left empty, then the .image.repository value will be used instead (and the .image.tag will also be used). |
| tests.connection.image.tag | string | `nil` | Sets the tag that will be used in the "connection" integration test. If this is left empty, the default is "latest" |
| tolerations | list | `[]` |  |
| virtualService.annotations | object | `{}` | Any annotations you wish to add to the `VirtualService` resource. See https://istio.io/latest/docs/reference/config/annotations/ for more details. |
| virtualService.enabled | bool | `false` | (Boolean) Maps the Service to an Istio IngressGateway, exposing the service outside of the Kubernetes cluster. |
| virtualService.gateway | string | `"default-gateway"` | The name of the Istio `IngressGateway` object that this `VirtualService` will register with. The default here is a private internal gateway that is not internet-facing. |
| virtualService.hosts | list | `["{{ include \"simple-app.fullname\" . }}.{{ .Release.Namespace }}"]` | A list of destination hostnames that this VirtualService will accept traffic for. Multiple names can be listed here. See https://istio.io/latest/docs/reference/config/networking/virtual-service/#VirtualService for more details. |
| virtualService.namespace | string | `"istio-system"` | The namespace where the Istio services are operating. Do not change this. |
| virtualService.path | string | `"/"` | The default path prefix that the `VirtualService` will match requests against to pass to the default `Service` object in this deployment. |
| virtualService.port | int | `80` | This is the backing Pod port _number_ to route traffic to. This must match a `containerPort` in the `Values.ports` list. |
| virtualService.tls | string | `""` |  |
| volumeMounts | list | `[]` | List of VolumeMounts that are applied to the application container - these must refer to volumes set in the `Values.volumes` parameter. |
| volumes | list | `[]` | A list of 'volumes' that can be mounted into the Pod. See https://kubernetes.io/docs/concepts/storage/volumes/. |
| volumesString | string | `""` | A stringified list of 'volumes' similar to the `Values.volumes` parameter, but this one gets run through the `tpl` function so that you can use templatized values if you need to. See https://kubernetes.io/docs/concepts/storage/volumes/. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)
