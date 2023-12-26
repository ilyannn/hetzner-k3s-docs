# Redact the documents
FROM registry.cluster.megaver.se/hub.docker.com/python:3.11-bookworm as redact

# For better caching
COPY build/publish-secret-docs/requirements.txt .
RUN pip install -r requirements.txt

COPY build/publish-secret-docs/ ./
COPY build/hetzner-k3s-main/ /hetzner-k3s-main/
COPY README.md /hetzner-k3s-docs/

RUN python -m unittest tests/*.py
RUN python redact.py /hetzner-k3s-main /hetzner-k3s-main-redacted

COPY zola/ /output/
RUN python to_markdown.py /hetzner-k3s-main-redacted /output/content/main/
RUN cat /hetzner-k3s-docs/README.md >> /output/content/_index.md


# Run Zola
FROM registry.cluster.megaver.se/library/zola as zola
WORKDIR /project
COPY --from=redact /output/ ./
RUN ["zola", "build"]


# Run web server
FROM registry.cluster.megaver.se/hub.docker.com/nginx 
COPY --from=zola /project/public/ /usr/share/nginx/html/
RUN mv /etc/nginx/mime.types /etc/nginx/mime.types.original
COPY mime.types /etc/nginx/mime.types
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
