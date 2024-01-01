#!/usr/bin/env sh
rm -rf build && mkdir -p build
cd build && git clone --depth 1 git@github.com:ilyannn/publish-secret-docs.git && cd - || exit
cd build && git clone --depth 1 git@github.com:ilyannn/hetzner-k3s-main.git && cd - || exit
podman build . -t registry.cluster.megaver.se/library/hetzner-k3s-docs-webserver:latest-amd64
podman run -p 8000:80 registry.cluster.megaver.se/library/hetzner-k3s-docs-webserver:latest-amd64
