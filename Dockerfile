FROM pytorch/pytorch:2.2.1-cuda12.1-cudnn8-runtime
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y git ffmpeg wget libgl1 libglib2.0-0 build-essential && rm -rf /var/lib/apt/lists/*
WORKDIR /workspace
RUN git clone https://github.com/comfyanonymous/ComfyUI.git
RUN pip install --no-cache-dir -r ComfyUI/requirements.txt
EXPOSE 8188
CMD ["python", "ComfyUI/main.py", "--listen", "0.0.0.0", "--port", "8188"]
