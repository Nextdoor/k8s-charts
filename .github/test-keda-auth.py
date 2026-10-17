#!/usr/bin/env python3
"""Render both application charts and check the KEDA Datadog auth contract."""

import subprocess
import unittest
from pathlib import Path

import yaml


ROOT = Path(__file__).resolve().parents[1]
CHARTS = ("simple-app", "rollout-app")


def render(chart, overrides=()):
    command = ["helm", "template", "example", str(ROOT / "charts" / chart),
               "--namespace", "example", "--set", "fullnameOverride=example-api",
               "--values", str(ROOT / "charts" / chart / "ci/keda-schedule-values.yaml")]
    for override in overrides:
        command += ["--set", override]
    result = subprocess.run(command, check=True, capture_output=True, text=True)
    return [doc for doc in yaml.safe_load_all(result.stdout) if doc]


class KedaAuthenticationTest(unittest.TestCase):
    def check_auth(self, documents, service_account="example-api", audiences=None):
        auths = [doc for doc in documents if doc["kind"] == "TriggerAuthentication"]
        self.assertEqual(len(auths), 1)
        auth = auths[0]
        token = {"parameter": "token", "serviceAccountName": service_account}
        if audiences:
            token["audiences"] = audiences
        self.assertEqual(auth["spec"]["boundServiceAccountToken"], [token])
        self.assertNotIn("secretTargetRef", auth["spec"])
        self.assertEqual(auth["metadata"]["name"], "example-api-datadog-auth")
        config = next(doc for doc in documents if doc["kind"] == "ConfigMap"
                      and doc["metadata"]["name"] == "example-api-datadog-keda")
        for reference in auth["spec"]["configMapTargetRef"]:
            self.assertEqual(reference["name"], config["metadata"]["name"])
            self.assertIn(reference["key"], config["data"])
        self.assertEqual(config["data"]["authMode"], "bearer")
        for scaled_object in (doc for doc in documents if doc["kind"] == "ScaledObject"):
            for trigger in scaled_object["spec"]["triggers"]:
                if trigger["type"] == "datadog":
                    self.assertEqual(trigger["authenticationRef"]["name"], auth["metadata"]["name"])

    def test_default_audience(self):
        for chart in CHARTS:
            with self.subTest(chart=chart):
                self.check_auth(render(chart))

    def test_custom_audiences(self):
        for chart in CHARTS:
            with self.subTest(chart=chart):
                self.check_auth(render(chart, [
                    "autoscaling.keda.tokenAudiences[0]=example-metrics",
                    "autoscaling.keda.tokenAudiences[1]=example-secondary",
                ]), audiences=["example-metrics", "example-secondary"])

    def test_existing_service_account(self):
        for chart in CHARTS:
            with self.subTest(chart=chart):
                self.check_auth(render(chart, ["serviceAccount.create=false", "serviceAccount.name=example-reader"]),
                                service_account="example-reader")

    def test_zone_transition_shares_authentication(self):
        for chart in CHARTS:
            with self.subTest(chart=chart):
                prefix = "deployment" if chart == "simple-app" else "rollout"
                docs = render(chart, [f"{prefix}Zones[0]=zone-a", f"{prefix}Zones[1]=zone-b",
                                      f"{prefix}ZonesTransition=true"])
                self.assertEqual(sum(doc["kind"] == "ScaledObject" for doc in docs), 3)
                self.check_auth(docs)

    def test_disabled_autoscaling_has_no_authentication(self):
        for chart in CHARTS:
            for flag in ("autoscaling.enabled=false", "autoscaling.keda.enabled=false"):
                with self.subTest(chart=chart, flag=flag):
                    self.assertFalse(any(doc["kind"] == "TriggerAuthentication" for doc in render(chart, [flag])))


if __name__ == "__main__":
    unittest.main()
