# observiq-otel-collector-k8s

Configuration for instrumenting Kubernetes with the observIQ OpenTelemetry collector.

> :warning: **This repository is under active development**: If using this repository, please fork or reference a tagged release. Please do not rely on main branch to be reliable.

## Usage

This repository assumes the use of [Kustomize](https://kustomize.io/) for generating Kubernetes manifests.
It is optional, all configs in `base/` are useable on their own.

It is also assumed that you have Minikube and access to a Google Cloud environment.

### Prerequisites

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.8.0/cert-manager.yaml 
sleep 20
kubectl apply -f https://github.com/open-telemetry/opentelemetry-operator/releases/latest/download/opentelemetry-operator.yaml
```

### Deploy Collectors

**Google Cloud**

Deploy cert manager, the operator, and the GCP credential secret. The credential file should be in the root of
this repo, named `credentials.json`.

The service account should have permission to write metrics, logs, and traces.

Deploy Google credentials:
```bash
kubectl create secret generic gcp-credentials \
    --from-file=credentials.json
```

Using Kustomize, deploy the Google Cloud configuration:
```bash
kustomize build environments/googlecloud | kubectl apply -f -
```

**New Relic**

Deploy New Relic API Key (insert your api key into the command):
```bash
kubectl create secret generic newrelic-credentials \
    --from-literal=api-key=<api key here>
```

### Application Monitoring

**Redis Example App**

Redis will be our example application for metrics. When deployed, the OpenTelemetry operator will
inject a collector container into each Redis pod, to collect metrics via localhost.

```bash
kubectl apply -f app/redis/redis.yaml
```

Sidecar injection is one method to collect application level metrics. Alternatively, the collector could be deployed
as a single pod Deployment or Statefulset targeting the application's service. This would require the receiver to be
"cluster aware". For example, Prometheus receiver with kubernetes detection (service discovery) or Elasticsearch (capable of collecting whole cluster metrics from a single endpoint).

