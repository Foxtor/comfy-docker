#!/bin/bash
echo "🧹 Limpando porta 8000..."
fuser -k -9 8000/tcp 2>/dev/null
echo "📂 Entrando na pasta do Fish Speech..."
cd /workspace/fish-audio/fish-speech
echo "🚀 Iniciando Fish Speech com VENV Persistente..."
/workspace/venv_principal/bin/python -m tools.api_server --listen 0.0.0.0:8000 --llama-checkpoint-path "checkpoints/fish-speech-1.5" --decoder-checkpoint-path "checkpoints/fish-speech-1.5/firefly-gan-vq-fsq-8x1024-21hz-generator.pth"
