# This is a docker image based on Alpine, containing Temporalio only
FROM python:3.10.4-alpine
WORKDIR /app

# Install required packages, including rust, required by temporalio
RUN apk add --no-cache gcc musl-dev linux-headers g++ rust cargo protoc rustfmt

# Install Python pakages, including temporalio
RUN python -m pip install \
  asyncio==3.4.3 \
  temporalio==0.1a2

# Run everything
COPY . .
CMD ["sh", "-c", "python -m worker.worker"]
