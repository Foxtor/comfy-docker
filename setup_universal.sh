echo "🚀 Iniciando Instalação Universal (O Plano de 1 Milhão)..."

# 1. Verifica/Baixa o ComfyUI
if [ ! -d "/workspace/ComfyUI" ]; then
    echo "📥 ComfyUI não encontrado. Baixando agora..."
    git clone https://github.com/comfyanonymous/ComfyUI.git
    pip install -r ComfyUI/requirements.txt
else
    echo "✅ ComfyUI já está no HD. Pulando..."
fi

# 2. Função de Download de Modelos
download_model() {
    echo "⬇️ Baixando: $2..."
    huggingface-cli download "$1" "$2" --local-dir "$3" --local-dir-use-symlinks False
}

# 3. Downloads Prioritários (Checkpoints)
echo "🖼️ Baixando Checkpoints..."
# Juggernaut XL
wget -nc -O /workspace/ComfyUI/models/checkpoints/Juggernaut-XL_v9.safetensors https://huggingface.co/RunDiffusion/Juggernaut-XL-v9/resolve/main/Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors

# 4. Fish Audio & Wan (Usando o motor do HF)
echo "🎙️ Baixando IA de Áudio e Vídeo..."
huggingface-cli download fishaudio/fish-speech-1.5 --local-dir /workspace/ComfyUI/models/checkpoints/fish_audio --local-dir-use-symlinks False

# Wan 2.1 (Remova o # abaixo se tiver +60GB de espaço livre)
# huggingface-cli download Wan-AI/Wan2.1-T2V-14B --local-dir /workspace/ComfyUI/models/wan --local-dir-use-symlinks False

echo "✅ TUDO PRONTO! Agora é só rodar o ComfyUI."
EOF

chmod +x setup_universal.sh