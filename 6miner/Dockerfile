FROM izone/amdgpu:19.30

WORKDIR /app

RUN apt-get update && apt-get install -y curl

RUN curl -L https://github.com/6block/6miner/releases/download/v0.0.5/6miner-v0.0.5-amd64-linux.tar.gz > x.tar.gz && tar -xv --strip-components=1 -f x.tar.gz

RUN rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["./6miner"]