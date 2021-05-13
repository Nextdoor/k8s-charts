# simple-app

Default Microservice Helm Chart

![Version: 0.3.1](https://img.shields.io/badge/Version-0.3.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

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
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` | (String) Always, Never or IfNotPresent |
| image.repository | string | `"nginx"` | (String) The Docker image name and repository for your application |
| image.tag | String | `nil` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Supply a reference to a Secret that can be used by Kubernetes to pull down the Docker image. This is only used in local development, in combination with our `kube_create_ecr_creds` function from dotfiles. |
| ingress.annotations."alb.ingress.kubernetes.io/actions.ssl-redirect" | string | `"{\n  \"Type\": \"redirect\",\n  \"RedirectConfig\": {\n    \"Protocol\": \"HTTPS\",\n    \"Port\": \"443\",\n    \"StatusCode\": \"HTTP_301\"\n  }\n}"` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.hosts[0].path | string | `""` |  |
| ingress.hosts[0].sslRedirect | bool | `true` |  |
| ingress.tls | list | `[]` |  |
| ingressGateway.annotations | object | `{}` |  |
| ingressGateway.enabled | bool | `false` | (Boolean) Maps the Service to an Istio IngressGateway, exposing the service outside of the Kubernetes cluster. |
| ingressGateway.gateway | string | `"default-gateway"` |  |
| ingressGateway.hosts | string | `"- {{ include \"simple-app.fullname\" . }}.{{ .Release.Namespace }}"` |  |
| ingressGateway.http | string | `"- match:\n    - uri:\n        prefix: /\n  route:\n    - destination:\n        host: {{ include \"simple-app.fullname\" . }}\n        port:\n          number: {{ .Values.ingressGateway.port }}"` | (String) VirtualService "http" blob in text-form. This is run through the tpl function so you may use template variables here. |
| ingressGateway.namespace | string | `"istio-system"` |  |
| ingressGateway.port | int | `80` |  |
| ingressGateway.tls | string | `""` |  |
| livenessProbe | object | `{"httpGet":{"path":"/","port":"http"}}` | A PodSpec container "livenessProbe" configuration object. Note that this livenessProbe will be applied to the proxySidecar container instead if that is enabled. |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podDisruptionBudget | object | `{}` | Set up a PodDisruptionBudget for the Deployment |
| podSecurityContext | object | `{}` |  |
| ports | list | `[{"containerPort":80,"name":"http","protocol":"TCP"},{"containerPort":443,"name":"https","protocol":"TCP"}]` | A list of Port objects that are exposed by the service. These ports are applied to the main container, or the proxySidecar container (if enabled). The port list is also used to generate Network Policies that allow ingress into the pods. |
| proxySidecar.enabled | bool | `false` | (Boolean) Enables injecting a pre-defined reverse proxy sidecar container into the Pod containers list. |
| proxySidecar.env | list | `[]` | Environment Variables for the primary container. These are all run through the tpl function (the key name and value), so you can dynamically name resources as you need. |
| proxySidecar.image.pullPolicy | string | `"Always"` | (String) Always, Never or IfNotPresent |
| proxySidecar.image.repository | string | `"nginx"` | (String) The Docker image name and repository for the sidecar |
| proxySidecar.image.tag | string | `"latest"` | (String) The Docker tag for the sidecar |
| proxySidecar.name | string | `"proxy"` | (String) The name of the proxy sidecar container |
| proxySidecar.resources | object | `{}` | A PodSpec "Resources" object for the proxy container |
| readinessProbe | object | `{"httpGet":{"path":"/","port":"http"}}` | A PodSpec container "readinessProbe" configuration object. Note that this readinessProbe will be applied to the proxySidecar container instead if that is enabled. |
| replicaCount | int | `1` | The number of Pods to start up by default |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tests.connection.args | list | `["{{ include \"simple-app.fullname\" . }}:{{ .Values.service.port }}"]` | A list of arguments passed into the command. These are run through the tpl function. |
| tests.connection.command | list | `["curl"]` | The command used to trigger the test. |
| tests.connection.image.repository | string | `nil` | Sets the image-name that will be used in the "connection" integration test. If this is left empty, then the .image.repository value will be used instead (and the .image.tag will also be used). |
| tests.connection.image.tag | string | `nil` | Sets the tag that will be used in the "connection" integration test. If this is left empty, the default is "latest" |
| tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.4.0](https://github.com/norwoodj/helm-docs/releases/v1.4.0)
