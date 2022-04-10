# observiq-otel-collector-k8s

Configuration for instrumenting Kubernetes with the observIQ OpenTelemetry 

## Usage

**OpenTelemetry Operator**

The operator requires cert manager.

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.8.0/cert-manager.yaml                      
```

Wait for cert manager to deploy, and then install the operator.

```bash
kubectl apply -f https://github.com/open-telemetry/opentelemetry-operator/releases/latest/download/opentelemetry-operator.yaml
```

**RBAC**

RBAC rules are required for some collector components.

```bash
kubectl apply -f otel/rbac.yaml
```

**Deploy Google Cloud Gateway**

The Google Cloud Gateway is a collector deployment that listens for OTLP gRPC requests and
sends them to Google Cloud. It is an aggregation layer between the cluster's various collectors.

Create the credential secret

```bash
kubectl create secret generic gcp-credentials --from-file=credentials.json -n default
```

Deploy the gateway collector

```bash
kubectl apply -f otel/agent_gcp_gateway.yaml
```

**Deploy Collectors**

Deploy the cluster metrics, node metrics (node, pod, container), and log collectors.

```bash
kubectl apply -f otel/agent_cluster.yaml
kubectl apply -f otel/agent_node.yaml
kubectl apply -f otel/agent_redis.yaml
```

**Redis Example App**

Redis will be our example application for metrics.

```bash
kubectl apply -f app/redis/redis.yaml
```
