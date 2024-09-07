# Use the official Ubuntu base image
FROM ubuntu:22.04

# setup go
COPY --from=golang:1.13-alpine /usr/local/go/ /usr/local/go/
ENV PATH="/usr/local/go/bin:${PATH}"

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

# install latest subfinder for subdomains enumeration
RUN go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

WORKDIR /app

# copy scripts to tools folder
COPY . /tools
ENV PATH="/tools:${PATH}"

CMD ["bash"]