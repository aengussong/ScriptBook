# use headless-shell as first stage image to download headless chrome
# gowitness uses this image as a base image for it's docker image
# https://github.com/sensepost/gowitness/blob/master/Dockerfile
# we'll just copy headless chrome instead
FROM chromedp/headless-shell:latest AS headless

# Use the official Ubuntu base image
FROM ubuntu:22.04

EXPOSE 7171

# copy required headless files
COPY --from=headless /headless-shell/ /headless-shell/
ENV PATH /headless-shell:$PATH

# copied from https://github.com/chromedp/docker-headless-shell/blob/master/Dockerfile
# we'll need these libs to run headless chrome (didn't actually tested this, just an assumption)
# we need to do this, as we can't just move tools from othre image. And I don't want to use
# headless chrome image as a base image
RUN \
    apt-get update -y \
    && apt-get install -y libnspr4 libnss3 libexpat1 libfontconfig1 libuuid1 socat wget\
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set environment variables to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install Python and other dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3 as the default python and pip command
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
    && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1


# Set the Go version to install
ENV GO_VERSION=1.23.0
# Download and install Go
RUN wget https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz
# Set up environment variables for Go
ENV GOROOT=/usr/local/go
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH
# verify go installed
RUN go version
# install tools, written in go
RUN go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
RUN go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
RUN go install github.com/sensepost/gowitness@latest

# copy scripts to tools folder
COPY --chmod=777 /scripts /tools
ENV PATH="/tools:${PATH}"

WORKDIR /app

CMD ["bash"]