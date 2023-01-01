FROM alpine:latest as downloader

ARG DMP_VERSION
RUN wget  "https://d-mp.org/builds/release/${DMP_VERSION}/DMPServer.zip"
RUN unzip DMPServer.zip -d / -o

FROM mono:latest
COPY --from=downloader /DMPServer /DMPServer

WORKDIR /DMPServer
EXPOSE 6702
ENTRYPOINT ["mono", "./DMPServer.exe"]
