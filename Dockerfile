# Redact the documents
FROM registry.cluster.megaver.se/hub.docker.com/python:3.11-bookworm as redact

# For better caching
COPY build/publish-secret-docs/requirements.txt .
RUN pip install -r requirements.txt

COPY build/publish-secret-docs/ ./
COPY build/hetzner-k3s-main/ /original/
RUN python -m unittest tests/*.py
RUN python redact.py /original /redacted
RUN python to_markdown.py /redacted /output


# Run Zola
FROM registry.cluster.megaver.se/library/zola as zola
WORKDIR /project
COPY zola/ ./
COPY --from=redact /output/ content/main/
RUN ["zola", "build"]


# Run web server
FROM registry.cluster.megaver.se/hub.docker.com/nginx 
COPY --from=zola /project/public/ /usr/share/nginx/html/
RUN mv /etc/nginx/mime.types /etc/nginx/mime.types.original
COPY mime.types /etc/nginx/mime.types
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
