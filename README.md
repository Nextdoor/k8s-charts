# Shared Private Helm Chart Components

This repo holds a series of common helm-charts that we've developed just to
help speed up our internal development and reduce repetition. These charts are
private - we do not publish them at a public endpoint, instead we use Git
Submodules to bring them into your project.

## Installation of this repo

...

## Charts

All charts are fully documented in their individual values files. Use `helm
show values charts/<chart name>` to see the documentated values for each chart.

## Using Charts in your Helm Chart

The intention of this repository is to make re-usable components - not projects
that are launched on their own. Given your existing `Chart.yaml` that looks like this:


    apiVersion: v2
    appVersion: "1.0"
    description: Launches the Nextdoor Widget Service
    name: neighbors-widget
    version: 0.1.0

You can add a simple `dependencies` section to bring in a component chart, and
then configure it with your `values.yaml` files. Here's the new `Chart.yaml` for example:

    apiVersion: v2
    appVersion: "1.0"
    description: Launches the Nextdoor Widget Service
    name: neighbors-widget
    version: 0.1.0
    dependencies:
      - name: prometheus-alerts
        version: 0.0.2
        repository: https://oss.nextdoor.com/k8s-public-harts

And you might then configure your `values.yaml` like this:

    # My own app configs..
    image: ...
    tag: ...

    # Customize the alerting for this project
    prometheus-alerts:
      alertManager:
        enabled: true
        pagerduty:
          routing_key: ...
