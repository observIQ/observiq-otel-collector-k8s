# observiq-otel-collector-k8s

Configuration for instrumenting Kubernetes with the observIQ OpenTelemetry collector.

> :warning: **This repository is under active development**: If using this repository, please fork or copy the configuration files directly. All examples are subject to change.

## Usage

This repository assumes the use of [Kustomize](https://kustomize.io/) for generating Kubernetes manifests.
It is optional, all configs in `base/` are useable on their own.

It is also assumed that you have Minikube and access to a Google Cloud environment.

**Prerequisites**

Deploy cert manager, the operator, and the GCP credential secret. The credential file should be in the root of
this repo, named `credentials.json`.

The service account should have permission to write metrics, logs, and traces.

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.8.0/cert-manager.yaml 
sleep 20
kubectl apply -f https://github.com/open-telemetry/opentelemetry-operator/releases/latest/download/opentelemetry-operator.yaml
kubectl create secret generic gcp-credentials --from-file=credentials.json -n default
```

Verify that `googlecloud/logs:` in `base/agent_gcp_gateway.yaml` has the correct `project` value that points to your GCP project.

```
googlecloud/logs:
project: <PROJECT_ID>
metric:
    prefix: custom.googleapis.com
retry_on_failure:
    enabled: false
```

**Deploy**

Using Kustomize, deploy the generic configuration.

```bash
kustomize build environments/generic | kubectl apply -f -
```

If you do not wish to use Kustomize, you can deploy the configs in `otel/environments/generic` directly, in the following order:
- rbac
- gateway agent
- cluster agent
- node agent
- redis agent

**Redis Example App**

Redis will be our example application for metrics. When deployed, the OpenTelemetry operator will
inject a collector container into each Redis pod, to collect metrics via localhost.

```bash
kubectl apply -f app/redis/redis.yaml
```

Sidecar injection is one method to collect application level metrics. Alternatively, the collector could be deployed
as a single pod Deployment or Statefulset targeting the application's service. This would require the receiver to be
"cluster aware". For example, Prometheus receiver with kubernetes detection (service discovery) or Elasticsearch (capable of collecting whole cluster metrics from a single endpoint).

