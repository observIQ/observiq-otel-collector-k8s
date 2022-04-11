#!/bin/bash
# Assumes pwd == git root

set -e

install() {
    kubectl apply -f \
        https://github.com/open-telemetry/opentelemetry-operator/releases/latest/download/opentelemetry-operator.yaml
}

wait_for_deploy() {
    kubectl rollout status deployment.apps/opentelemetry-operator-controller-manager \
        --timeout=60s -n opentelemetry-operator-system
}

install
wait_for_deploy
