#!/bin/bash
# Assumes pwd == git root

set -e

install() {
    kubectl apply -f \
        https://github.com/cert-manager/cert-manager/releases/download/v1.8.0/cert-manager.yaml
}

wait_for_deploy() {
    kubectl rollout status deployment.apps/cert-manager --timeout=60s -n cert-manager
    kubectl rollout status deployment.apps/cert-manager-cainjector --timeout=60s -n cert-manager
    kubectl rollout status deployment.apps/cert-manager-webhook --timeout=60s -n cert-manager
}

install
wait_for_deploy
