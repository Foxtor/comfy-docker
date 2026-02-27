#!/bin/bash
set -e

echo "🚀 Iniciando Instalação Optimizada (Paralelo + Waves)..."

# === 0. Dependências do sistema ===
if command -v apt-get &> /dev/null; then
    echo "📦 Instalando dependências do sistema..."
    apt-get update && apt-get install -y \
        git wget ffmpeg libgl1 libglib2.0-0 tar aria2 \
        && rm -rf /var/lib/apt/lists/*
else
    echo "⚠️ apt-get não disponível."
fi

# === Funções ===
log() { echo -e "\033[1;32m[$(date +%H:%M:%S)]\033[0m $1"; }
warn() { echo -e "\033[1;33m[$(date +%H:%M:%S)] ⚠️\033[0m $1"; }
check_space() {
    local needed=$1
    local available=$(df -BG /workspace | awk 'NR==2 {print $4}' | tr -d 'G')
    if [ "$available" -lt "$needed" ]; then
        warn "Espaço insuficiente! Precisa: ${needed}GB, Tem: ${available}GB"
        return 1
    fi
    return 0
}

# === Criar pastas ===
mkdir -p /workspace/ComfyUI/models/{checkpoints,vaes,clip_vision,upscale_models,ipadapter,controlnet,insightface}

# =====================================================
# WAVE 1: LEVE (git clone + pip install)
# =====================================================
log "🌊 WAVE 1: Leve (ComfyUI + Custom Nodes)..."

if [ ! -d "/workspace/ComfyUI" ]; then
    log "📥 Clonando ComfyUI..."
    git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI
    pip install -r /workspace/ComfyUI/requirements.txt -q
else
    log "✅ ComfyUI já instalado."
fi

# Custom Nodes (paralelo - todos juntos)
CUSTOM_NODES_DIR="/workspace/ComfyUI/custom_nodes"
mkdir -p "$CUSTOM_NODES_DIR"
cd "$CUSTOM_NODES_DIR"

NODES=(
    "https://github.com/chibiace/ComfyUI-Chibi-Nodes.git"
    "https://github.com/kijai/ComfyUI-HFRemoteVae.git"
    "https://github.com/kijai/ComfyUI-KJNodes.git"
    "https://github.com/fofr/ComfyUI-RunpodDirect.git"
    "https://github.com/cubiq/ComfyUI_IPAdapter_plus.git"
    "https://github.com/sipherxyz/comfyui-art-venture.git"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack.git"
    "https://github.com/cubiq/ComfyUI_essentials.git"
    "https://github.com/rgthree/rgthree-comfy.git"
    "https://github.com/lllyasviel/ComfyUI-Fooocus-Inpaint-Wrapper.git"
    "https://github.com/Shakker-Labs/ComfyUI-IPAdapter-Flux.git"
    "https://github.com/willmiao/ComfyUI-Lora-Manager.git"
    "https://github.com/TemryL/ComfyS3.git"
    "https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git"
    "https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git"
    "https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git"
    "https://github.com/city96/ComfyUI-GGUF.git"
    "https://github.com/ltdrdata/ComfyUI-Manager.git"
    "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git"
    "https://github.com/chrisgoringe/cg-use-everywhere.git"
    "https://github.com/yolain/ComfyUI-Easy-Use.git"
    "https://github.com/kijai/ComfyUI-LivePortraitKJ.git"
    "https://github.com/plugcrypt/CRT-Nodes.git"
    "https://github.com/lllyasviel/ComfyUI-GGUF-FantasyTalking.git"
    "https://github.com/kijai/ComfyUI-MelBandRoFormer.git"
    "https://github.com/kijai/ComfyUI-WanVideoWrapper.git"
    "https://github.com/giriss/comfy-image-saver.git"
    "https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git"
)

for repo in "${NODES[@]}"; do
    folder=$(basename "$repo" .git)
    if [ ! -d "$folder" ]; then
        git clone -q "$repo" &
    fi
done
wait

# Instalar requirements em paralelo
for repo in "${NODES[@]}"; do
    folder=$(basename "$repo" .git)
    if [ -f "$folder/requirements.txt" ]; then
        pip install -r "$folder/requirements.txt" -q &
    fi
done
wait

log "✅ Wave 1 completa!"

# =====================================================
# WAVE 2: PEQUENO (< 500MB cada)
# =====================================================
log "🌊 WAVE 2: Pequenos (< 500MB)"

check_space 5 || exit 1

DOWNLOADS_PEQUENO=(
    "/workspace/ComfyUI/models/upscale_models/RealESRGAN_x4plus.pth:https://huggingface.co/lllyasviel/Annotators/resolve/main/RealESRGAN_x4plus.pth"
    "/workspace/ComfyUI/models/upscale_models/RealESRGAN_x4plus_anime_6B.pth:https://huggingface.co/lllyasviel/Annotators/resolve/main/RealESRGAN_x4plus_anime_6B.pth"
    "/workspace/ComfyUI/models/controlnet/dpt_hybrid-midas-501f9c5e.pt:https://huggingface.co/lllyasviel/Annotators/resolve/main/dpt_hybrid-midas-501f9c5e.pt"
    "/workspace/ComfyUI/models/controlnet/sketch.pth:https://huggingface.co/lllyasviel/Annotators/resolve/main/sketch.pth"
    "/workspace/ComfyUI/models/insightface/genderage.onnx:https://huggingface.co/MonsterMMORPG/tools/resolve/main/antelopev2/genderage.onnx"
    "/workspace/ComfyUI/models/insightface/2d106det.onnx:https://huggingface.co/MonsterMMORPG/tools/resolve/main/antelopev2/2d106det.onnx"
    "/workspace/ComfyUI/models/insightface/glintr100.onnx:https://huggingface.co/MonsterMMORPG/tools/resolve/main/antelopev2/glintr100.onnx"
)

for item in "${DOWNLOADS_PEQUENO[@]}"; do
    path="${item%%:*}"
    url="${item##*:}"
    if [ ! -f "$path" ]; then
        aria2c -x 8 -s 8 -d "$(dirname "$path")" -o "$(basename "$path")" "$url" &
    fi
done
wait

log "✅ Wave 2 completa!"

# =====================================================
# WAVE 3: MÉDIO (500MB - 2GB)
# =====================================================
log "🌊 WAVE 3: Médio (500MB - 2GB)"

check_space 10 || exit 1

DOWNLOADS_MEDIO=(
    "/workspace/ComfyUI/models/vaes/wan_2.1_vae.safetensors:https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"
    "/workspace/ComfyUI/models/vaes/ae.safetensors:https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors"
    "/workspace/ComfyUI/models/clip_vision/clip_vision_h.safetensors:https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors"
    "/workspace/ComfyUI/models/clip_vision/siglip-so400m-patch14-384.safetensors:https://huggingface.co/google/siglip-so400m-patch14-384/resolve/main/model.safetensors"
    "/workspace/ComfyUI/models/ipadapter/ip-adapter_sd15.safetensors:https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter_sd15.safetensors"
    "/workspace/ComfyUI/models/ipadapter/ip-adapter_sdxl.safetensors:https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter_sdxl.safetensors"
    "/workspace/ComfyUI/models/ipadapter/ip-adapter-plus_sdxl_vit-h.safetensors:https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter-plus_sdxl_vit-h.safetensors"
    "/workspace/ComfyUI/models/checkpoints/fish-speech.bin:https://huggingface.co/fishaudio/fish-speech-1.4/resolve/main/fish-speech-1.4-checkpoint.pth"
)

for item in "${DOWNLOADS_MEDIO[@]}"; do
    path="${item%%:*}"
    url="${item##*:}"
    if [ ! -f "$path" ]; then
        aria2c -x 16 -s 16 -d "$(dirname "$path")" -o "$(basename "$path")" "$url" &
    fi
done
wait

log "✅ Wave 3 completa!"

# =====================================================
# WAVE 4: PESADO (> 2GB) - por último
# =====================================================
log "🌊 WAVE 4: Pesado (> 2GB) -最后一个"

check_space 25 || exit 1

DOWNLOADS_PESADO=(
    "/workspace/ComfyUI/models/checkpoints/Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors:https://huggingface.co/RunDiffusion/Juggernaut-XL-v9/resolve/main/Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors"
    "/workspace/ComfyUI/models/checkpoints/flux1-dev-fp8.safetensors:https://huggingface.co/lllyasviel/flux1_dev/resolve/main/flux1-dev-fp8.safetensors"
)

for item in "${DOWNLOADS_PESADO[@]}"; do
    path="${item%%:*}"
    url="${item##*:}"
    if [ ! -f "$path" ]; then
        # Mais conexões pro arquivo grande
        aria2c -x 16 -s 16 -d "$(dirname "$path")" -o "$(basename "$path")" "$url" &
    fi
done
wait

log "✅ Wave 4 completa!"

# =====================================================
# FINAL
# =====================================================
log "🎉 INSTALAÇÃO COMPLETA!"
log "Disco剩余: $(df -h /workspace | awk 'NR==2 {print $4}')"
cd /workspace/ComfyUI
echo ""
echo "Para rodar: python3 main.py --listen 0.0.0.0 --port 8188"
