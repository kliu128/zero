FROM izone/amdgpu:19.30

WORKDIR /app

RUN apt-get update && apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_10.x  | bash -
RUN apt-get install -y git nodejs

RUN git clone https://github.com/HandyMiner/HandyMiner-CLI && cd HandyMiner-CLI && npm install

WORKDIR /app/HandyMiner-CLI

RUN rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["npm", "start"]
