
# Tags https://hub.docker.com/r/pytorch/pytorch/tags
FROM pytorch/pytorch:2.3.0-cuda12.1-cudnn8-runtime

# Step 2: Set up the environment
ENV PYTHONUNBUFFERED=1 \
    # Prevents transformers from downloading models to the root user's home
    TRANSFORMERS_CACHE=/home/user/app/cache/transformers \
    HF_HOME=/home/user/app/cache/huggingface

# Step 3: Create a working directory and a non-root user
WORKDIR /home/user/app
RUN useradd -ms /bin/bash user
RUN chown -R user:user /home/user/app

# Switch to the non-root user
USER user

# Step 4: Copy requirements first to leverage Docker's layer cache
COPY --chown=user:user requirements.txt .

# Step 5: Install Python dependencies from requirements.txt
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Step 6: Copy the rest of the application's source code
COPY --chown=user:user . .

# Step 7: Expose a port for services like JupyterLab or other web UIs
EXPOSE 8888

# Step 8: Define the default command to keep the container running
# This allows you to attach to it later.
CMD ["tail", "-f", "/dev/null"]
