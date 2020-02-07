FROM izone/amdgpu:19.30

WORKDIR /app

RUN apt-get update && \
  apt install -y wget

RUN wget https://github.com/6block/6miner/releases/download/v0.0.1/6miner-v0.0.1-amd64-linux.tar.gz && \
  tar --strip-components=1 -xvf 6miner-v0.0.1-amd64-linux.tar.gz

RUN rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/app/6miner"]