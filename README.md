# 🧠 Ollama HPC Setup: Remote Inference over SSH

This guide walks you through running the [Ollama](https://ollama.com) large language model server on an HPC GPU node and accessing it from your local machine via SSH port forwarding.

---

## 📁 Files Included

| File               | Purpose                                       |
| ------------------ | --------------------------------------------- |
| `run_ollama_template.slurm` | SLURM script to start Ollama on a GPU node    |
| `test_ollama.py`   | Python script to test model inference via API |
| `ollama_client.py` | Reusable Python class to query Ollama API     |

---

## 🚀 1. SLURM Script: `run_ollama.slurm`

Submit this script via `sbatch run_ollama_template.slurm` to launch Ollama on a GPU node.

```bash
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


```

---

## 🔐 2. SSH Port Forwarding

Once your SLURM job is running and you know the node name (e.g. `x1000c3s1b0n1`), run this **from your local machine**:

```bash
ssh -L 11434:x1000c3s1b0n1:11434 {USER_NAME}@lanta.nstda.or.th -i id_rsa
```

> This maps `http://127.0.0.1:11434` on your laptop to the running Ollama server.

---

## 🐍 3. Python Client: `test_ollama.py`

Run this on your **local machine** to test if Ollama is responding:

```python
import requests

url = "http://127.0.0.1:11434/api/generate"

payload = {
    "model": "qwen3:14b",
    "prompt": "Hello, what can you do?",
    "stream": False
}

response = requests.post(url, json=payload)
print("✅ Response:", response.json().get("response"))
```

---

## 🔁 4. Python Wrapper: `ollama_client.py`

This reusable wrapper lets you query Ollama programmatically.

```python
import requests

class OllamaClient:
    def __init__(self, host="http://127.0.0.1:11434", model="qwen3:14b"):
        self.base_url = host
        self.model = model

    def generate(self, prompt, stream=False):
        url = f"{self.base_url}/api/generate"
        payload = {
            "model": self.model,
            "prompt": prompt,
            "stream": stream
        }
        try:
            res = requests.post(url, json=payload)
            res.raise_for_status()
            return res.json().get("response")
        except Exception as e:
            print("❌ Error:", e)
            return None

# Example usage
if __name__ == "__main__":
    client = OllamaClient()
    print(client.generate("Tell me a joke."))
```

---

## ✅ Summary

* Use `run_ollama.slurm` to launch Ollama on HPC
* SSH forward the port to your laptop
* Query using `test_ollama.py` or `ollama_client.py`

You're now running large language models remotely and interacting from your own machine!

Happy prompting! 🎉
