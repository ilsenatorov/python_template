# Step 1: Use an official PyTorch base image
FROM pytorch/pytorch:2.3.0-cuda12.1-cudnn8-runtime

# Step 2: Set up the environment
ENV PYTHONUNBUFFERED=1 \
    TRANSFORMERS_CACHE=/home/user/app/cache/transformers \
    HF_HOME=/home/user/app/cache/huggingface

# Step 3: Create a working directory and a non-root user
WORKDIR /home/user/app
RUN useradd -ms /bin/bash user
# Change ownership of the entire home directory for the new user
RUN chown -R user:user /home/user

# Switch to the non-root user
USER user

# Step 4: Copy requirements first to leverage Docker's layer cache
COPY --chown=user:user requirements.txt .

# Step 5: Install Python dependencies from requirements.txt
# This will now succeed by installing packages into /home/user/.local/
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Step 6: Copy the rest of the application's source code
COPY --chown=user:user . .

# Step 7: Expose a port for services like JupyterLab or other web UIs
EXPOSE 8888

# Step 8: Define the default command to keep the container running
CMD ["tail", "-f", "/dev/null"]
