FROM pytorch/pytorch:2.3.0-cuda12.1-cudnn8-runtime
ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    TRANSFORMERS_CACHE=/cache/transformers \
    HF_HOME=/cache/huggingface \
    PIP_CACHE_DIR=/cache/pip
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    openssh-client \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -ms /bin/bash user
WORKDIR /app
RUN mkdir -p /cache && chown -R user:user /app /cache
USER user
COPY --chown=user:user requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY --chown=user:user . .
CMD ["tail", "-f", "/dev/null"]
