# observiq-otel-collector-k8s

Configuration for instrumenting Kubernetes with the observIQ OpenTelemetry 

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

**Deploy**

Using Kustomize, deploy the minikube configuration.

```bash
kustomize build environments/minikube | kubectl apply -f -
```

If you do not wish to use Kustomize, you can deploy the configs in `otel/environments/minikube` directly, in the following order:
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
