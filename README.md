# 🧠 Ollama HPC Setup: Remote Inference over SSH

This guide walks you through running the [Ollama](https://ollama.com) large language model server on an HPC GPU node and accessing it from your local machine via SSH port forwarding.

---

## 📁 Files Included

| File               | Purpose                                       |
| ------------------ | --------------------------------------------- |
| `run_ollama.slurm` | SLURM script to start Ollama on a GPU node    |
| `test_ollama.py`   | Python script to test model inference via API |
| `ollama_client.py` | Reusable Python class to query Ollama API     |

---

## 🚀 1. SLURM Script: `run_ollama.slurm`

Submit this script via `sbatch run_ollama.slurm` to launch Ollama on a GPU node.

```bash
#!/bin/bash
#SBATCH -p gpu
#SBATCH -N 1 -c 32
#SBATCH --gpus-per-node=4
#SBATCH --ntasks-per-node=1
#SBATCH -t 02:00:00
#SBATCH -A lt200344
#SBATCH -J ollama_server
#SBATCH -o ollama_%j.log
#SBATCH -e ollama_%j.log

ml Mamba
mamba activate fastapi

export OLLAMA_HOST=http://0.0.0.0:11434
export OLLAMA_MODEL=qwen3:14b
export OLLAMA_MODELS=/project/lt200344-zhthmt/Y/OLLAMA_v0.5.7/models
export PATH=$PATH:/project/lt200344-zhthmt/Y/OLLAMA/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/project/lt200344-zhthmt/Y/OLLAMA/lib

echo "✅ Ollama is starting on $OLLAMA_HOST"
ollama serve
```

---

## 🔐 2. SSH Port Forwarding

Once your SLURM job is running and you know the node name (e.g. `x1000c3s1b0n1`), run this **from your local machine**:

```bash
ssh -L 11434:x1000c3s1b0n1:11434 ssaehoei@lanta.nstda.or.th -i id_rsa
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
