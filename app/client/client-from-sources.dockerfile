# This is a docker image based on Debian, containing Temporalio python and Streamlit
FROM python:3.10.4-bullseye
WORKDIR /app

# Install rust
# See https://stackoverflow.com/a/49676568
# Update default packages
RUN apt-get -qq update
RUN apt-get install -y -q \
  build-essential \
  curl
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

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
# See https://github.com/temporalio/sdk-python#local-development-environment
RUN python -m pip install poetry poethepoet
RUN python -m poetry install
RUN python -m poethepoet build-develop

# Install streamlit
# See https://docs.streamlit.io/library/get-started/installation#install-streamlit-on-macoslinux
RUN source $(python -m poetry env info --path)/bin/activate ; python -m pip install streamlit

# Install additional missing python packages
RUN source $(python -m poetry env info --path)/bin/activate ; python -m pip install asyncio grpcio dacite

# Run everything
EXPOSE 8501
COPY . .
CMD ["sh", "-c", "source $(python -m poetry env info --path)/bin/activate ; python -m streamlit run client/client.py"]