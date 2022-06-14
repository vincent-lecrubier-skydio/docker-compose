# This is a docker image based on Alpine, containing Temporalio only
FROM python:3.10.4-alpine
WORKDIR /app

# Install required packages
RUN apk add --no-cache gcc musl-dev linux-headers g++ rust cargo protoc rustfmt git openssh openssl-dev libffi-dev
RUN python -m pip install --upgrade pip

# Setup git
# https://stackoverflow.com/a/29380765
RUN mkdir -p ~/.ssh
RUN ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

# Get temporal python sdk
# See https://github.com/temporalio/sdk-python
RUN git clone https://github.com/crubier/sdk-python.git
WORKDIR /app/sdk-python
RUN git checkout 1adbb675ecf4d4d39972904e53ed7d6ef8fd863d
RUN git submodule update --init --recursive

# Install temporal python sdk
# https://github.com/crubier/sdk-python#local-development-environment
RUN python -m pip install poetry poethepoet
RUN python -m poetry install
RUN python -m poethepoet build-develop

# Install additional missing python packages
RUN source $(python -m poetry env info --path)/bin/activate ; python -m pip install typing_extensions google cffi asyncio

# Run everything
COPY . .
CMD ["sh", "-c", "source $(python -m poetry env info --path)/bin/activate ; python -m worker.worker"]