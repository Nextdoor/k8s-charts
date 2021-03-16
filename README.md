# Shared Private Helm Chart Components

[argo_submodules]: https://argo-cd.readthedocs.io/en/stable/user-guide/private-repositories/#git-submodules

This repo holds a series of common helm-charts that we've developed just to
help speed up our internal development and reduce repetition. These charts are
private - we do not publish them at a public endpoint, instead we use Git
Submodules to bring them into your project.

## Installation of this repo

From your own application repo, create a Git Submodule. This submodule has many
charts in it, so you'll then be able to pick and choose the charts that matter
to you for your application.

_ArgoCD [natively supports Git Submodules][argo_submodules] - so you don't have
to do anything in Argo for it to resolve these modules!_

    $ git submodule github.com:Nextdoor/k8s-charts k8s-charts

## Charts

All charts are fully documented in their individual values files. Use `helm
show values charts/<chart name>` to see the documentated values for each chart.

### Using Charts in your Helm Chart

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
      - name: simple-app
        version: 0.0.2
        repository: file://../k8s-charts/simple-app
        alias: neighbors-widget

And you might then configure your `values.yaml` like this:

    # All parameters for the simple-app chart go into a key matching the alias
    # we used above.
    neighbors-widget:
      ...

## Development

All of the charts in this repository have a specific development pattern that
must be followed. Documentation must be well written, and tests are strongly
encouraged. Each chart must be fully functional by default (even if you use a
hello-world type image as a default for testing purposes).
