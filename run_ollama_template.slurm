#!/bin/bash
#SBATCH -p gpu                         # GPU partition
#SBATCH -N 1                           # Number of nodes
#SBATCH -c 32                          # Number of CPU cores
#SBATCH --gpus-per-node=4             # Number of GPUs
#SBATCH --ntasks-per-node=1           # One task per node
#SBATCH -t 02:00:00                    # Job time limit (HH:MM:SS)
#SBATCH -A your_project_code_here     # Replace with your project/account code
#SBATCH -J ollama_server              # Job name
#SBATCH -o ollama_output_%j.log       # Stdout log file (%j = job ID)
#SBATCH -e ollama_output_%j.log       # Stderr log file (merged with stdout)

export USER=$(whoami)
export node=$(hostname -s)
echo "Assigned port: $port"
echo "User: $USER"
echo "Node: $node"


# === Environment Variables ===
export OLLAMA_HOST=http://0.0.0.0:11434
export OLLAMA_MODEL=qwen3:14b         # Change to any model you want to use
export OLLAMA_MODELS=/path/to/ollama/models
export PATH=$PATH:/path/to/ollama/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/path/to/ollama/lib

echo "OLLAMA_HOST: $OLLAMA_HOST"
echo "OLLAMA_MODELS: $OLLAMA_MODELS"
echo "OLLAMA_MODEL: $OLLAMA_MODEL"
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo "PATH: $PATH"

# ==== for SSH port forwarding ====
echo -e "Ollama-server is running on: $(hostname)
Job starts at: $(date)
Copy/Paste the following command into your local terminal
--------------------------------------------------------------------
"ssh -L 11434:${node}:11434 ${USER}@lanta.nstda.or.th -i id_rsa"
--------------------------------------------------------------------
"
echo "✅ Ollama API available at $OLLAMA_HOST"


# === Start Ollama Server ===

ollama serve
