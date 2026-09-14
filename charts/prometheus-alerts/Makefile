include ../../contrib/Helm.mk
include ../../contrib/Testing.mk

###############################################################################
# Unit-tests the alerting rules with promtool.
#
# The rules are rendered out of this chart rather than kept as a checked-in
# copy, so the tests always exercise the real templated expressions. The
# `grafanaUrl` default is blanked to drop the `logs_url` annotation, which is
# a very long URL that none of the assertions care about.
###############################################################################
PROMTOOL_VERSION ?= 2.53.0

ifeq ($(OSNAME),linux)
	GET_PROMTOOL_URL ?= https://github.com/prometheus/prometheus/releases/download/v$(PROMTOOL_VERSION)/prometheus-$(PROMTOOL_VERSION).linux-amd64.tar.gz
else
	GET_PROMTOOL_URL ?= https://github.com/prometheus/prometheus/releases/download/v$(PROMTOOL_VERSION)/prometheus-$(PROMTOOL_VERSION).darwin-amd64.tar.gz
endif

PROMTOOL := $(shell which promtool || echo $(BIN_DIR)/promtool)

$(BIN_DIR)/promtool:
	@echo "Downloading $(GET_PROMTOOL_URL) to $@..."
	@mkdir -p $(BIN_DIR)
	@curl -fsSL $(GET_PROMTOOL_URL) \
		| tar -xz -C $(BIN_DIR) --strip-components=1 \
			prometheus-$(PROMTOOL_VERSION).$(OSNAME)-amd64/promtool
	@chmod +x $@

.PHONY: promtool
promtool: $(PROMTOOL)

# Renders the chart's PrometheusRule and strips it down to the bare `groups`
# document that promtool expects. Always re-rendered so a template edit can't
# be tested against a stale file.
.PHONY: tests/.rendered.yaml
tests/.rendered.yaml:
	@helm template t . \
		--set containerRules.jobs.KubeJobFailed.suppressWhenNewerRunSucceeded=true \
		--set defaults.grafanaUrl= \
		| python3 -c 'import sys, yaml; rule = [d for d in yaml.safe_load_all(sys.stdin) if d and d.get("kind") == "PrometheusRule"][0]; yaml.safe_dump(rule["spec"], sys.stdout, width=10000)' \
		> $@

.PHONY: promtool_test
promtool_test: $(PROMTOOL) tests/.rendered.yaml
	$(PROMTOOL) check rules tests/.rendered.yaml
	$(PROMTOOL) test rules tests/kubejobfailed.yaml

