#!/bin/bash
set -e

STUDENT_USERNAMES="student1 student2"
FACULTY_USERNAMES="ilya alper"

DOCKER_IMAGE_NAME="smtb-env:latest"
HOST_DATA_DIR="/srv/data"
HOST_CACHE_DIR="/srv/hf_cache"
HOST_SCRATCH_DIR="/srv/scratch"

install_prerequisites() {
    echo "STEP 1: Installing system prerequisites..."
    apt-get update
    apt-get install -y docker.io git
    systemctl start docker
    systemctl enable docker
    echo "Docker installed and enabled."
}

setup_directories() {
    echo "STEP 2: Setting up shared host directories..."
    mkdir -p "$HOST_DATA_DIR" "$HOST_CACHE_DIR" "$HOST_SCRATCH_DIR"
    echo "Created directories: $HOST_DATA_DIR, $HOST_CACHE_DIR, $HOST_SCRATCH_DIR"

    chmod 777 "$HOST_CACHE_DIR" "$HOST_SCRATCH_DIR"
    echo "Set permissions for cache and scratch directories."
    echo "IMPORTANT: Place your read-only datasets in $HOST_DATA_DIR"
}

build_docker_image() {
    echo "STEP 3: Building the Docker image '$DOCKER_IMAGE_NAME'..."
    if [ -f "Dockerfile" ] && [ -f "requirements.txt" ]; then
        docker build -t "$DOCKER_IMAGE_NAME" .
        echo "Docker image built successfully."
    else
        echo "ERROR: Dockerfile or requirements.txt not found in the current directory."
        exit 1
    fi
}

setup_ssh_for_user() {
    local user="$1"
    local user_home="/home/$user"

    if [ -d "$user_home" ]; then
        echo "    -> Setting up .ssh directory for '$user'..."
        sudo mkdir -p "$user_home/.ssh"
        sudo touch "$user_home/.ssh/authorized_keys"
        sudo chmod 700 "$user_home/.ssh"
        sudo chmod 600 "$user_home/.ssh/authorized_keys"
        sudo chown -R "$user:$user" "$user_home/.ssh"
    else
        echo "    -> WARNING: Home directory for '$user' not found. Cannot set up SSH."
    fi
}


create_users() {
    echo "STEP 4: Creating user accounts..."

    # Create Faculty Users
    for user in $FACULTY_USERNAMES; do
        if id "$user" &>/dev/null; then
            echo "  - Faculty user '$user' already exists."
        else
            echo "  - Creating faculty user '$user' and adding to 'sudo' and 'docker' groups."
            useradd -m -s /bin/bash "$user"
            usermod -aG sudo,docker "$user"
            setup_ssh_for_user "$user"
            echo "    -> ACTION REQUIRED: Add the SSH public key for '$user'."
        fi
    done

    # Create Student Users
    for user in $STUDENT_USERNAMES; do
        if id "$user" &>/dev/null; then
            echo "  - Student user '$user' already exists."
        else
            echo "  - Creating student user '$user'."
            useradd -m -s /bin/bash "$user"
            setup_ssh_for_user "$user"
            echo "    -> ACTION REQUIRED: Add the SSH public key for '$user'."
        fi
    done
}

deploy_student_containers() {
    echo "STEP 5: Deploying student Docker containers..."
    for user in $STUDENT_USERNAMES; do
        local container_name="${user}_dev_env"
        if [ $(docker ps -a -f name=^/${container_name}$ | grep -w ${container_name} | wc -l) -gt 0 ]; then
            echo "  - Container '$container_name' already exists. Skipping."
        else
            echo "  - Launching container '$container_name' for user '$user'."
            docker run -d \
                --name "$container_name" \
                --restart unless-stopped \
                -v "$HOST_DATA_DIR:/data:ro" \
                -v "$HOST_CACHE_DIR:/cache" \
                -v "$HOST_SCRATCH_DIR:/scratch" \
                "$DOCKER_IMAGE_NAME"
        fi
    done
}


# --- Main Execution ---
echo "===== Kicking off Lab Setup ====="
install_prerequisites
setup_directories
build_docker_image
create_users
deploy_student_containers
echo ""
echo "===== Lab Setup Complete! ====="
echo "Final status of student containers:"
docker ps --filter "name=_dev_env"
echo "Next steps: Add SSH keys for all new users."
