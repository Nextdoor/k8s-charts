NAMESPACE := rollout-app

LOCAL_DEPS_TARGET := install_rollouts

.PHONY: crds
crds:
	make -C ../.. crds

.PHONY: install_rollouts
install_rollouts: crds
	kubectl create namespace argo-rollouts || true
	kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml && \
	kubectl wait deployment -n argo-rollouts argo-rollouts --for condition=Available=True --timeout=90s

include ../../contrib/Helm.mk
include ../../contrib/Testing.mk
