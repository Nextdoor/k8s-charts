include contrib/Docker.mk
include contrib/Helm.mk
include contrib/ChartTesting.mk

.PHONY: crds
crds:
	kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml \
		-f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml \
		-f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml \
		-f https://raw.githubusercontent.com/istio/istio/1.17.3/manifests/charts/base/crds/crd-all.gen.yaml \
		-f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.crds.yaml \
		-f ./charts/flink-operator-crd/crds/flink-operator-crd.yaml \
		-f https://raw.githubusercontent.com/apache/flink-kubernetes-operator/release-1.6/helm/flink-kubernetes-operator/crds/flinkdeployments.flink.apache.org-v1.yml \
		-f https://raw.githubusercontent.com/apache/flink-kubernetes-operator/release-1.6/helm/flink-kubernetes-operator/crds/flinksessionjobs.flink.apache.org-v1.yml
