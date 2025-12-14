FROM alpine:latest
RUN apk add --no-cache bash ffmpeg
WORKDIR /src
COPY src/ /src/
ENTRYPOINT ["/src/entrypoint.sh"]
