FROM clowder/clowder:1.7.1

RUN apk add --no-cache python

COPY docker/clowder.sh /home/clowder/

# health check
HEALTHCHECK CMD curl localhost:9000
