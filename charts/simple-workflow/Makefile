NAMESPACE := simple-workflow

include ../../contrib/Helm.mk
include ../../contrib/Testing.mk

.PHONY: install_argo_workflow
install_argo_workflow:
	kubectl create namespace argo
	kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v3.3.5/install.yaml
