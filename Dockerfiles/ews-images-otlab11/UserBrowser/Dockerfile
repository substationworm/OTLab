FROM ubuntu:22.04
RUN apt-get update && apt-get install -y elinks curl && rm -rf /var/lib/apt/lists/*
CMD ["bash","-lc","w3m http://phishing.test"]