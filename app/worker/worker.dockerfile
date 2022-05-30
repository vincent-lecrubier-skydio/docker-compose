FROM python:3.7-alpine
WORKDIR /app
RUN apk add --no-cache gcc musl-dev linux-headers g++ rust cargo protoc rustfmt git openssh
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1
RUN python -m pip install --upgrade pip
COPY worker/requirements.txt requirements.txt

# https://stackoverflow.com/a/29380765
RUN mkdir -p ~/.ssh
RUN ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

RUN python -m pip install -r requirements.txt

# https://github.com/pypa/pipx#install-pipx
# RUN python -m pip install --user pipx
# RUN python -m pipx ensurepath

# https://github.com/crubier/sdk-python#local-development-environment
# RUN pipx install poetry
# RUN pipx install poethepoet

RUN apk add --no-cache libffi-dev
RUN python -m pip install cffi
RUN python -m pip install poetry poethepoet

RUN git clone https://github.com/crubier/sdk-python.git
WORKDIR /app/sdk-python
RUN git checkout 1adbb675ecf4d4d39972904e53ed7d6ef8fd863d
RUN git submodule update --init --recursive
RUN apk add --no-cache openssl-dev
# https://github.com/crubier/sdk-python#local-development-environment
RUN python -m poetry install
RUN python -m poethepoet build-develop
# RUN source $(python -m poetry env info --path)/bin/activate
RUN source $(python -m poetry env info --path)/bin/activate ; python -m pip install typing_extensions google

EXPOSE 5000
COPY . .
CMD ["sh", "-c", "source $(python -m poetry env info --path)/bin/activate ; python -m worker.worker"]