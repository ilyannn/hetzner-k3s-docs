#!/usr/bin/env sh
rm -rf build && mkdir -p build
cd build && git clone --depth 1 git@github.com:ilyannn/publish-secret-docs.git && cd -
cd build && git clone --depth 1 git@github.com:ilyannn/hetzner-k3s-main.git && cd -
podman build . -t registry.cluster.megaver.se/library/hetzner-k3s-docs-webserver:latest-arm64 --override-arch=arm64 --override-os=linux 
podman build . -t registry.cluster.megaver.se/library/hetzner-k3s-docs-webserver:latest-amd64 
