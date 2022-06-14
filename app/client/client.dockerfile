# This is a docker image based on Debian, containing Temporalio python and Streamlit
FROM python:3.10.4-bullseye
WORKDIR /app

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN python -m pip install \
  streamlit==1.10.0 \
  asyncio==3.4.3 \
  dacite==1.6.0 \
  temporalio==0.1a2

# Run everything
EXPOSE 8501
COPY . .
CMD ["sh", "-c", "python -m streamlit run client/client.py"]