#CÓDIGO PARA BAIXAR E INSTALAR TUDO

FROM pytorch/pytorch:2.4.1-cuda12.4-cudnn9-runtime

# Instala dependências do sistema
RUN apt-get update && apt-get install -y \
    git wget ffmpeg libgl1 libglib2.0-0 tar \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 1. Copia requirements e instala
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 2. Clona ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git

# 3. Copia e instala custom nodes
COPY comfy-nodes/custom_nodes.tar.gz /app/ComfyUI/custom_nodes.tar.gz
RUN cd /app/ComfyUI && \
    mkdir -p custom_nodes && \
    tar -xzf custom_nodes.tar.gz -C custom_nodes --strip-components=1

# 4. Baixa modelos (exemplo: fish-speech checkpoint)
# Adicione aqui os comandos do seu setup_universal.sh
RUN mkdir -p /app/ComfyUI/models/checkpoints && \
    wget -O /app/ComfyUI/models/checkpoints/fish-speech.bin \
    https://huggingface.co/fishaudio/fish-speech-1.4/resolve/main/fish-speech-1.4-checkpoint.pth

# Expõe porta
EXPOSE 8188

# Roda
CMD ["python", "/app/ComfyUI/main.py", "--listen", "0.0.0.0", "--port", "8188", "--cuda-malloc"]