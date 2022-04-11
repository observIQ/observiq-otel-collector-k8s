#!/bin/bash
# Assumes pwd == git root

set -e

k8s_version="$1"
k8s_runtime="$2"

minikube_install() {
    sudo apt-get update -qq
    sudo apt-get install -qq -y curl apt-transport-https

    echo "Installing Minikube version ${k8s_version}"

    curl -s -L -o minikube.deb https://github.com/kubernetes/minikube/releases/download/v1.24.0/minikube_1.24.0-0_amd64.deb
    sudo apt-get install -f ./minikube.deb
}

minikube_start() {
    echo "Starting Minikube version ${k8s_version} with runtime ${k8s_runtime}" 

    minikube start \
        --driver=docker \
        --kubernetes-version="$k8s_version" \
        --container-runtime="$k8s_runtime"
}

minikube_wait() {
    node=$(kubectl get node | grep -v NAME | awk '{print $1}')
    bash ./.github/scripts/k8s_wait_for_node.sh "$node"
}

minikube_install
minikube_start
minikube_wait