NAMESPACE := flink-sample-app
OPERATOR_VER := 0.1.1
LOCAL_DEPS_TARGET := operator
TEST_PREREQS := operator

.PHONY: repo
repo:
	helm repo list | grep -q flink-operator || helm repo add flink-operator  https://googlecloudplatform.github.io/flink-on-k8s-operator

.PHONY: operator
operator: repo
	helm list | grep -q flink-operator || helm install flink-operator flink-operator/flink-operator \
		--set operatorImage.name="gcr.io/flink-operator/flink-operator:latest" \
		--create-namespace \
		--wait \
		--version $(OPERATOR_VER)
	helm upgrade flink-operator flink-operator/flink-operator --version $(OPERATOR_VER)

include ../../contrib/Helm.mk
include ../../contrib/Testing.mk
