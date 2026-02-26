#!/bin/bash
echo "🧹 Limpando porta 8188..."
fuser -k -9 8188/tcp 2>/dev/null
echo "📂 Entrando na pasta do ComfyUI..."
cd /workspace/ComfyUI
echo "🚀 Iniciando ComfyUI com VENV Persistente..."
/workspace/venv_principal/bin/python main.py --listen 0.0.0.0 --port 8188 --cuda-malloc --force-fp16 --gpu-only --disable-smart-memory