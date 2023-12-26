# Redact the documents
FROM registry.cluster.megaver.se/hub.docker.com/python:3.11-bookworm as redact

# For better caching
COPY build/publish-secret-docs/requirements.txt .
RUN pip install -r requirements.txt

COPY build/publish-secret-docs/ ./
COPY build/hetzner-k3s-main/ /original/
RUN ./redact.py /original /redacted


# Run Zola
FROM registry.cluster.megaver.se/library/zola as zola
WORKDIR /project
COPY zola/ ./
COPY --from=redact /redacted/ content/main/
RUN ["zola", "build"]


# Run web server
FROM registry.cluster.megaver.se/hub.docker.com/nginx 
COPY --from=zola /project/public/ /usr/share/nginx/html/
RUN mv /etc/nginx/mime.types /etc/nginx/mime.types.original
COPY mime.types /etc/nginx/mime.types
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
