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
kubectl -n cert-manager rollout status deploy/cert-manager --timeout=60s
kubectl -n cert-manager rollout status deploy/cert-manager-cainjector --timeout=60s
kubectl -n cert-manager rollout status deploy/cert-manager-webhook --timeout=60s

kubectl apply -f https://github.com/open-telemetry/opentelemetry-operator/releases/latest/download/opentelemetry-operator.yaml
kubectl -n opentelemetry-operator-system rollout status deploy/opentelemetry-operator-controller-manager --timeout=60s
```

### Deploy Collectors

**Google Cloud**

Deploy cert manager, the operator, and the GCP credential secret. The credential file should be in the root of
this repo, named `credentials.json`.

The service account should have permission to write metrics, logs, and traces.

1. Authentication: 
- If running **outside of GCP**, deploy Google credentials:
```bash
kubectl create secret generic gcp-credentials \
    --from-file=credentials.json
```
- If running within GCP with the correct instance scoeps enabled, comment the authentication
  section in `environments/googlecloud/agent_gateway.yaml`.

2. Update the override file in `environments/googlecloud/agent.yaml`
- Set `K8S_CLUSTER` environment variable to the name of your cluster.
- If running within GCP, the resource detection processor will detect the real GKE cluster name.

3. Using Kustomize, deploy the Google Cloud configuration:
```bash
kustomize build environments/googlecloud | kubectl apply -f -
```

**New Relic**

1. Deploy New Relic API Key (insert your api key into the command):
```bash
kubectl create secret generic newrelic-credentials \
    --from-literal=api-key=<api key here>
```

2. Update the override file in `environments/newrelic/agent.yaml`
- Set `K8S_CLUSTER` environment variable to the name of your cluster.

3. Using Kustomize, deploy the New Relic configuration:
```bash
kustomize build environments/newrelic | kubectl apply -f -
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

