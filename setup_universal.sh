#!/bin/bash
set -e

echo "🚀 Iniciando Instalação Universal (O Plano de 1 Milhão)..."

# Criar pastas
mkdir -p /workspace/ComfyUI/models/{checkpoints,vaes,clip_vision,upscale_models,ipadapter,controlnet,insightface}

# === 1. ComfyUI Base ===
if [ ! -d "/workspace/ComfyUI" ]; then
    echo "📥 ComfyUI não encontrado. Baixando..."
    git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI
    pip install -r /workspace/ComfyUI/requirements.txt
else
    echo "✅ ComfyUI já instalado."
fi

# === 2. CHECKPOINTS ===
echo "🖼️ Baixando Checkpoints..."
wget -nc -P /workspace/ComfyUI/models/checkpoints https://huggingface.co/RunDiffusion/Juggernaut-XL-v9/resolve/main/Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors
wget -nc -P /workspace/ComfyUI/models/checkpoints https://huggingface.co/lllyasviel/flux1_dev/resolve/main/flux1-dev-fp8.safetensors

# === 3. VAEs ===
echo "🎨 Baixando VAEs..."
wget -nc -O /workspace/ComfyUI/models/vaes/wan_2.1_vae.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors
wget -nc -O /workspace/ComfyUI/models/vaes/ae.safetensors https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors

# === 4. CLIP VISION ===
echo "👁️ Baixando CLIP Vision..."
wget -nc -O /workspace/ComfyUI/models/clip_vision/clip_vision_h.safetensors https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors
wget -nc -O /workspace/ComfyUI/models/clip_vision/siglip-so400m-patch14-384.safetensors https://huggingface.co/google/siglip-so400m-patch14-384/resolve/main/model.safetensors

# === 5. UPSCALERS ===
echo "🔍 Baixando Upscalers..."
wget -nc -P /workspace/ComfyUI/models/upscale_models https://huggingface.co/lllyasviel/Annotators/resolve/main/RealESRGAN_x4plus.pth
wget -nc -P /workspace/ComfyUI/models/upscale_models https://huggingface.co/lllyasviel/Annotators/resolve/main/RealESRGAN_x4plus_anime_6B.pth

# === 6. IP-ADAPTER (para IPAdapter_plus) ===
echo "🔗 Baixando IP-Adapter..."
wget -nc -P /workspace/ComfyUI/models/ipadapter https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter_sd15.safetensors
wget -nc -P /workspace/ComfyUI/models/ipadapter https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter_sdxl.safetensors
wget -nc -P /workspace/ComfyUI/models/ipadapter https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter-plus_sdxl_vit-h.safetensors

# === 7. CONTROLNET (para Impact Pack, Fooocus, etc.) ===
echo "🎛️ Baixando ControlNets..."
wget -nc -P /workspace/ComfyUI/models/controlnet https://huggingface.co/lllyasviel/Annotators/resolve/main/dpt_hybrid-midas-501f9c5e.pt
wget -nc -P /workspace/ComfyUI/models/controlnet https://huggingface.co/lllyasviel/Annotators/resolve/main/sketch.pth

# === 8. INSIGHTFACE (para LivePortrait, IPAdapter Flux) ===
echo "👤 Baixando InsightFace..."
wget -nc -P /workspace/ComfyUI/models/insightface https://huggingface.co/MonsterMMORPG/tools/resolve/main/antelopev2/genderage.onnx
wget -nc -P /workspace/ComfyUI/models/insightface https://huggingface.co/MonsterMMORPG/tools/resolve/main/antelopev2/2d106det.onnx
wget -nc -P /workspace/ComfyUI/models/insightface https://huggingface.co/MonsterMMORPG/tools/resolve/main/antelopev2/glintr100.onnx

# === 9. CUSTOM NODES (agora sim, com git clone) ===
echo "🧩 Instalando Custom Nodes..."
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
        echo "🔄 Clonando $folder..."
        git clone "$repo"
        if [ -f "$folder/requirements.txt" ]; then
            pip install -r "$folder/requirements.txt"
        fi
    else
        echo "⚠️ $folder já existe."
    fi
done

echo "✅ TUDO PRONTO! Agora é só rodar o ComfyUI."