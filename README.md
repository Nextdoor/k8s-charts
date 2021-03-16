# Nextdoor Helm Chart Components

This repo holds a series of common helm-charts that we've developed just to
help speed up our internal development and reduce repetition. There's no
unique business logic or anything private here.

# Security - Read Me First!

**This is critical - absolutely no private information may be checked into this
repository. Read this!**

This repository is public - internet-facing. We use this repository purely to
keep reusable "components" available to developers to make their Helm lives
easier. The components in this repository are intended to be completely general
purpose and reusable, and should be testable entirely without any privilged
access.

## Repository Setup

The repository metadata and artifacts are hosted by Github. All the data here
is publically accessible to make development easy. Also, it makes testing these
charts easier (see comments below around testing).

    $ helm repo add nextdoor https://k8s-charts.nextdoor.com/
    $ helm repo update
    $ helm search repo nextdoor
    NAME                      	CHART VERSION	APP VERSION	DESCRIPTION
    nextdoor/simple-app	        0.1.0        	0.0.1      	Helm Chart that provisions a series of common P...

## Using a Chart

All charts are fully documented in their individual values files. Use `helm
search repo nextdoor` to list the charts and `helm show values nextdoor/<chart
name>` to see the options for the charts.

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
        repository: https://k8s-charts.nextdoor.com

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

# Developing Component Charts

If you want to improve on a component chart here - or create your own - you
need to know a few things about the requirements in this repository. Please
read through this section thoroughly before creating a Pull Request.

## Chart Paths

All charts live in the [`/charts`](charts/) directory. The name of the chart
must match the name of the directory - for example,
[`charts/simple-app`](charts/simple-app) matches the `Name` key in the
[`charts/simple-app/Chart.yaml`](charts/simple-app/Chart.yaml) file.

## Revving Chart Versions

[helm_best_practices]: https://helm.sh/docs/chart_best_practices/conventions/#version-numbers
[semver2]: https://semver.org/

On every single chart change, you must rev the `version` key in the
`Chart.yaml` file. We follow the [Helm Best Practices][helm_best_practices]
guide and use the [Semantic Versioning 2.0.0][semver2] pattern for all
versioning:

  * MAJOR version when you make incompatible API changes,
  * MINOR version when you add functionality in a backwards compatible manner, and
  * PATCH version when you make backwards compatible bug fixes.

## Generating Updated Chart Documentation

[helm_docs]: https://github.com/norwoodj/helm-docs

As part of our [CI tests](.github/workflows/ci.yaml), we verify that the
`README.md` in the chart directory matches the `values.yaml` file properly
using the [helm_docs][helm_docs] command. This process ensures that each and
every change to a repository includes the latest and current documentation.

If your [dotfiles](https://github.com/Nextdoor/dotfiles.git) is updated, then
you can just run `helm_docs` from inside the chart directory to update the
documentation before committing your code:

    $ helm_docs
    time="2021-03-16T15:44:46Z" level=info msg="Found Chart directories [charts/simple-app]"
    time="2021-03-16T15:44:46Z" level=info msg="Generating README Documentation for chart /helm-docs/charts/simple-app"

## Maintainers

All charts must have a `maintainers` section that indicates who has primarily
been responsible for owning the health of that chart. The `name` maps to your
Github username, but please use your corporate email address for the `email`
key.

```yaml
maintainers:
  - name: diranged
    email: matt@nextdoor.com
```

## Chart Testing

[ct_tool]: https://github.com/helm/chart-testing

All Charts will automatically be run through the [Helm Chart Testing][ct_tool]
tool as part of the CI process. You must be able to mock out the
Nextdoor-specific settings (like ECR images for example) with publically
available components because the CI process takes place in Github Actions. 

*This is an intentional decision - it makes it impossible to ship a chart to
the repository that contains references to private internal ECR images.*
