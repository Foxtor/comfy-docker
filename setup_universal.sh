#!/bin/bash
set -e

echo "🚀 Iniciando Instalação Universal (O Plano de 1 Milhão)..."

# === 0. Dependências do sistema (apt) ===
if command -v apt-get &> /dev/null; then
    echo "📦 Instalando dependências do sistema..."
    apt-get update && apt-get install -y \
        git wget ffmpeg libgl1 libglib2.0-0 tar \
        && rm -rf /var/lib/apt/lists/*
else
    echo "⚠️  apt-get não disponível — assumindo que as dependências já estão instaladas."
fi

# === Criar pastas ===
mkdir -p /workspace/ComfyUI/models/{checkpoints,vaes,clip_vision,upscale_models,ipadapter,controlnet,insightface}

# === 1. ComfyUI Base ===
if [ ! -d "/workspace/ComfyUI" ]; then
    echo "📥 ComfyUI não encontrado. Baixando..."
    git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI
    pip install -r /workspace/ComfyUI/requirements.txt
else
    echo "✅ ComfyUI já instalado."
fi

# === 2. CHECKPOINTS (incluindo fish-speech) ===
echo "🖼️ Verificando Checkpoints..."
CHECKPOINT1="/workspace/ComfyUI/models/checkpoints/Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors"
CHECKPOINT2="/workspace/ComfyUI/models/checkpoints/flux1-dev-fp8.safetensors"
FISH_SPEECH="/workspace/ComfyUI/models/checkpoints/fish-speech.bin"

if [ ! -f "$CHECKPOINT1" ]; then
    wget -O "$CHECKPOINT1" https://huggingface.co/RunDiffusion/Juggernaut-XL-v9/resolve/main/Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors
else
    echo "✅ Juggernaut-XL já baixado."
fi

if [ ! -f "$CHECKPOINT2" ]; then
    wget -O "$CHECKPOINT2" https://huggingface.co/lllyasviel/flux1_dev/resolve/main/flux1-dev-fp8.safetensors
else
    echo "✅ flux1-dev já baixado."
fi

if [ ! -f "$FISH_SPEECH" ]; then
    echo "🧠 Baixando fish-speech checkpoint..."
    wget -O "$FISH_SPEECH" https://huggingface.co/fishaudio/fish-speech-1.4/resolve/main/fish-speech-1.4-checkpoint.pth
else
    echo "✅ fish-speech.bin já baixado."
fi

# === 3. VAEs ===
echo "🎨 Verificando VAEs..."
VAE1="/workspace/ComfyUI/models/vaes/wan_2.1_vae.safetensors"
VAE2="/workspace/ComfyUI/models/vaes/ae.safetensors"

if [ ! -f "$VAE1" ]; then
    wget -O "$VAE1" https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors
else
    echo "✅ wan_2.1_vae já baixado."
fi

if [ ! -f "$VAE2" ]; then
    wget -O "$VAE2" https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors
else
    echo "✅ ae.safetensors já baixado."
fi

# === 4. CLIP VISION ===
echo "👁️ Verificando CLIP Vision..."
CLIP1="/workspace/ComfyUI/models/clip_vision/clip_vision_h.safetensors"
CLIP2="/workspace/ComfyUI/models/clip_vision/siglip-so400m-patch14-384.safetensors"

if [ ! -f "$CLIP1" ]; then
    wget -O "$CLIP1" https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors
else
    echo "✅ clip_vision_h já baixado."
fi

if [ ! -f "$CLIP2" ]; then
    wget -O "$CLIP2" https://huggingface.co/google/siglip-so400m-patch14-384/resolve/main/model.safetensors
else
    echo "✅ siglip-so400m já baixado."
fi

# === 5. UPSCALERS ===
echo "🔍 Verificando Upscalers..."
UP1="/workspace/ComfyUI/models/upscale_models/RealESRGAN_x4plus.pth"
UP2="/workspace/ComfyUI/models/upscale_models/RealESRGAN_x4plus_anime_6B.pth"

if [ ! -f "$UP1" ]; then
    wget -O "$UP1" https://huggingface.co/lllyasviel/Annotators/resolve/main/RealESRGAN_x4plus.pth
else
    echo "✅ RealESRGAN_x4plus já baixado."
fi

if [ ! -f "$UP2" ]; then
    wget -O "$UP2" https://huggingface.co/lllyasviel/Annotators/resolve/main/RealESRGAN_x4plus_anime_6B.pth
else
    echo "✅ RealESRGAN_x4plus_anime_6B já baixado."
fi

# === 6. IP-ADAPTER ===
echo "🔗 Verificando IP-Adapter..."
IP1="/workspace/ComfyUI/models/ipadapter/ip-adapter_sd15.safetensors"
IP2="/workspace/ComfyUI/models/ipadapter/ip-adapter_sdxl.safetensors"
IP3="/workspace/ComfyUI/models/ipadapter/ip-adapter-plus_sdxl_vit-h.safetensors"

if [ ! -f "$IP1" ]; then
    wget -O "$IP1" https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter_sd15.safetensors
else
    echo "✅ ip-adapter_sd15 já baixado."
fi

if [ ! -f "$IP2" ]; then
    wget -O "$IP2" https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter_sdxl.safetensors
else
    echo "✅ ip-adapter_sdxl já baixado."
fi

if [ ! -f "$IP3" ]; then
    wget -O "$IP3" https://huggingface.co/h94/IP-Adapter/resolve/main/models/ip-adapter-plus_sdxl_vit-h.safetensors
else
    echo "✅ ip-adapter-plus_sdxl_vit-h já baixado."
fi

# === 7. CONTROLNET ===
echo "🎛️ Verificando ControlNets..."
CN1="/workspace/ComfyUI/models/controlnet/dpt_hybrid-midas-501f9c5e.pt"
CN2="/workspace/ComfyUI/models/controlnet/sketch.pth"

if [ ! -f "$CN1" ]; then
    wget -O "$CN1" https://huggingface.co/lllyasviel/Annotators/resolve/main/dpt_hybrid-midas-501f9c5e.pt
else
    echo "✅ dpt_hybrid-midas já baixado."
fi

if [ ! -f "$CN2" ]; then
    wget -O "$CN2" https://huggingface.co/lllyasviel/Annotators/resolve/main/sketch.pth
else
    echo "✅ sketch.pth já baixado."
fi

# === 8. INSIGHTFACE ===
echo "👤 Verificando InsightFace..."
IF1="/workspace/ComfyUI/models/insightface/genderage.onnx"
IF2="/workspace/ComfyUI/models/insightface/2d106det.onnx"
IF3="/workspace/ComfyUI/models/insightface/glintr100.onnx"

if [ ! -f "$IF1" ]; then
    wget -O "$IF1" https://huggingface.co/MonsterMMORPG/tools/resolve/main/antelopev2/genderage.onnx
else
    echo "✅ genderage.onnx já baixado."
fi

if [ ! -f "$IF2" ]; then
    wget -O "$IF2" https://huggingface.co/MonsterMMORPG/tools/resolve/main/antelopev2/2d106det.onnx
else
    echo "✅ 2d106det.onnx já baixado."
fi

if [ ! -f "$IF3" ]; then
    wget -O "$IF3" https://huggingface.co/MonsterMMORPG/tools/resolve/main/antelopev2/glintr100.onnx
else
    echo "✅ glintr100.onnx já baixado."
fi

# === 9. CUSTOM NODES ===
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
