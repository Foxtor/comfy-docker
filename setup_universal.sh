#!/bin/bash
set -e

echo "🚀 Iniciando Instalação Universal (O Plano de 1 Milhão)..."

# === Função de utilidade ===
ensure_hf_cli() {
    if ! command -v huggingface-cli &> /dev/null; then
        echo "📦 huggingface-cli não encontrado. Instalando..."
        pip install --no-cache-dir huggingface_hub
        # Opcional: aceleração de download (muito rápido!)
        pip install --no-cache-dir hf_transfer
        export HF_HUB_ENABLE_HF_TRANSFER=1
    else
        echo "✅ huggingface-cli já instalado."
    fi
}

# === 1. ComfyUI Base ===
if [ ! -d "/workspace/ComfyUI" ]; then
    echo "📥 ComfyUI não encontrado. Baixando..."
    git clone https://github.com/comfyanonymous/ComfyUI.git /workspace/ComfyUI
    pip install -r /workspace/ComfyUI/requirements.txt
else
    echo "✅ ComfyUI já instalado."
fi

# Garantir que o diretório existe
mkdir -p /workspace/ComfyUI/models/{checkpoints,vaes,clip_vision,upscale_models,ipadapter,controlnet,insightface}

# === 2. Garantir que huggingface-cli está pronto ===
ensure_hf_cli

# === 3. DOWNLOADS COM HUGGINGFACE-CLI (modelos que exigem autenticação ou são complexos) ===

echo "🖼️ Baixando Checkpoints via Hugging Face..."
huggingface-cli download RunDiffusion/Juggernaut-XL-v9 Juggernaut-XL_v9_RunDiffusionPhoto_v2.safetensors \
    --local-dir /workspace/ComfyUI/models/checkpoints --local-dir-use-symlinks False

huggingface-cli download lllyasviel/flux1_dev flux1-dev-fp8.safetensors \
    --local-dir /workspace/ComfyUI/models/checkpoints --local-dir-use-symlinks False

echo "🎨 Baixando VAEs..."
huggingface-cli download Comfy-Org/Wan_2.1_ComfyUI_repackaged wan_2.1_vae.safetensors \
    --local-dir /workspace/ComfyUI/models/vaes --local-dir-use-symlinks False

huggingface-cli download Comfy-Org/z_image_turbo ae.safetensors \
    --local-dir /workspace/ComfyUI/models/vaes --local-dir-use-symlinks False

echo "👁️ Baixando CLIP Vision..."
huggingface-cli download Comfy-Org/Wan_2.1_ComfyUI_repackaged clip_vision_h.safetensors \
    --local-dir /workspace/ComfyUI/models/clip_vision --local-dir-use-symlinks False

huggingface-cli download google/siglip-so400m-patch14-384 model.safetensors \
    --local-dir /workspace/ComfyUI/models/clip_vision --local-dir-use-symlinks False \
    --filename siglip-so400m-patch14-384.safetensors

echo "🔗 Baixando IP-Adapter..."
huggingface-cli download h94/IP-Adapter ip-adapter_sd15.safetensors \
    --local-dir /workspace/ComfyUI/models/ipadapter --local-dir-use-symlinks False

huggingface-cli download h94/IP-Adapter ip-adapter_sdxl.safetensors \
    --local-dir /workspace/ComfyUI/models/ipadapter --local-dir-use-symlinks False

huggingface-cli download h94/IP-Adapter ip-adapter-plus_sdxl_vit-h.safetensors \
    --local-dir /workspace/ComfyUI/models/ipadapter --local-dir-use-symlinks False

echo "🎛️ Baixando ControlNets..."
huggingface-cli download lllyasviel/Annotators dpt_hybrid-midas-501f9c5e.pt \
    --local-dir /workspace/ComfyUI/models/controlnet --local-dir-use-symlinks False

huggingface-cli download lllyasviel/Annotators sketch.pth \
    --local-dir /workspace/ComfyUI/models/controlnet --local-dir-use-symlinks False

echo "👤 Baixando InsightFace..."
huggingface-cli download MonsterMMORPG/tools genderage.onnx \
    --local-dir /workspace/ComfyUI/models/insightface --local-dir-use-symlinks False

huggingface-cli download MonsterMMORPG/tools 2d106det.onnx \
    --local-dir /workspace/ComfyUI/models/insightface --local-dir-use-symlinks False

huggingface-cli download MonsterMMORPG/tools glintr100.onnx \
    --local-dir /workspace/ComfyUI/models/insightface --local-dir-use-symlinks False

# === 4. DOWNLOADS COM WGET (links diretos públicos sem autenticação) ===
echo "🔍 Baixando Upscalers (via wget)..."
wget -nc -P /workspace/ComfyUI/models/upscale_models https://huggingface.co/lllyasviel/Annotators/resolve/main/RealESRGAN_x4plus.pth
wget -nc -P /workspace/ComfyUI/models/upscale_models https://huggingface.co/lllyasviel/Annotators/resolve/main/RealESRGAN_x4plus_anime_6B.pth

# === 5. CUSTOM NODES ===
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
