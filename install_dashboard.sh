#!/bin/bash

# Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh

# Add the current user to the docker group
echo "Adding current user to docker group..."
sudo usermod -aG docker $USER

# Check for Docker permission issues
docker info &> /dev/null
if [ $? -ne 0 ]; then
    echo "Fixing Docker permission issue..."
    sudo chmod 666 /var/run/docker.sock
fi

# Install Miniconda
echo "Installing Miniconda..."
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -rf ~/miniconda3/miniconda.sh

# Initialize conda for the user's shell
echo "Initializing conda for the current shell..."
current_shell=$(basename $SHELL)
if [[ "$current_shell" == "bash" ]]; then
    ~/miniconda3/bin/conda init bash
elif [[ "$current_shell" == "zsh" ]]; then
    ~/miniconda3/bin/conda init zsh
else
    echo "Warning: Unsupported shell. Please run 'conda init' manually for your shell."
fi

# Install Hummingbot dashboard
echo "Installing Hummingbot dashboard..."
git clone https://github.com/hummingbot/dashboard.git
cd dashboard
make env_create
conda activate dashboard
streamlit run main.py
