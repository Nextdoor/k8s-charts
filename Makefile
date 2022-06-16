.PHONY: crds
crds: 
	kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml \
		-f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml \
		-f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml \
		-f https://raw.githubusercontent.com/istio/istio/1.13.2/manifests/charts/base/crds/crd-all.gen.yaml \
		-f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.crds.yaml \
		-f ./charts/flink-operator-crd/crds/flink-operator-crd.yaml
