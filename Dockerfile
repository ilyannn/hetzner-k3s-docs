# Redact the documents
FROM registry.cluster.megaver.se/hub.docker.com/python:3.11-bookworm as redact

# For better caching
COPY build/publish-secret-docs/requirements.txt .
RUN pip install -r requirements.txt

# Include two repositories we need 
COPY README.md /original/
COPY build/hetzner-k3s-main/ /original/main/
COPY build/publish-secret-docs/ ./

# Redact out the secrets: /original to /redacted
RUN python -m unittest tests/*.py
RUN python redact.py /original /redacted

# Prepare zola input tree: /redacted to /output
COPY zola/ /output/
RUN python to_markdown.py /redacted /output/content
# Zola requires file name to be _index.md to use co-located assets
RUN find /output/content -type f -name 'README.md' -execdir mv {} _index.md \;


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
