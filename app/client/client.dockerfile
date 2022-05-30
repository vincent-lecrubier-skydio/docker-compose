FROM python:3.8-alpine
WORKDIR /app
RUN apk add --no-cache gcc musl-dev linux-headers g++ rust cargo protoc rustfmt git openssh
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1
RUN python -m pip install --upgrade pip
COPY client/requirements.txt requirements.txt

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

RUN apk add --no-cache zlib-dev
RUN apk add --no-cache cmake make
RUN source $(python -m poetry env info --path)/bin/activate ; python -m pip install pandas numpy
# RUN apk add --no-cache apache-arrow apache-arrow-dev py3-apache-arrow py3-apache-arrow-dev py3-arrow
RUN apk add --no-cache jpeg-dev
RUN source $(python -m poetry env info --path)/bin/activate ; python -m pip install pillow



RUN apk update \
  && apk upgrade \
  && apk add --no-cache build-base \
  autoconf \
  bash \
  bison \
  boost-dev \
  cmake \
  flex \
  libressl-dev \
  zlib-dev

RUN pip install --no-cache-dir six pytest numpy cython

ARG ARROW_VERSION=3.0.0
ARG ARROW_SHA1=c1fed962cddfab1966a0e03461376ebb28cf17d3
ARG ARROW_BUILD_TYPE=release

ENV ARROW_HOME=/usr/local \
  PARQUET_HOME=/usr/local

#Download and build apache-arrow
RUN mkdir /arrow \
  && wget -q https://github.com/apache/arrow/archive/apache-arrow-${ARROW_VERSION}.tar.gz -O /tmp/apache-arrow.tar.gz \
  && echo "${ARROW_SHA1} *apache-arrow.tar.gz" | sha1sum /tmp/apache-arrow.tar.gz \
  && tar -xvf /tmp/apache-arrow.tar.gz -C /arrow --strip-components 1 \
  && mkdir -p /arrow/cpp/build \
  && cd /arrow/cpp/build \
  && cmake -DCMAKE_BUILD_TYPE=$ARROW_BUILD_TYPE \
  -DOPENSSL_ROOT_DIR=/usr/local/ssl \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_INSTALL_PREFIX=$ARROW_HOME \
  -DARROW_WITH_BZ2=ON \
  -DARROW_WITH_ZLIB=ON \
  -DARROW_WITH_ZSTD=ON \
  -DARROW_WITH_LZ4=ON \
  -DARROW_WITH_SNAPPY=ON \
  -DARROW_PARQUET=ON \
  -DARROW_PYTHON=ON \
  -DARROW_PLASMA=ON \
  -DARROW_BUILD_TESTS=OFF \
  .. \
  && make -j$(nproc) \
  && make install \
  && cd /arrow/python \
  && source $(python -m poetry env info --path)/bin/activate) \
  && python setup.py build_ext --build-type=$ARROW_BUILD_TYPE --with-parquet \
  && python setup.py install \
  && rm -rf /arrow /tmp/apache-arrow.tar.gz


RUN source $(python -m poetry env info --path)/bin/activate ; python -m pip install streamlit==1.9.2

EXPOSE 5000
COPY . .
CMD ["sh", "-c", "source $(python -m poetry env info --path)/bin/activate ; python -m client.client"]