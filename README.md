git clone https://github.com/Foxtor/comfy-docker.git
cd comfy-docker
docker build -t comfy-prod .
docker run --gpus all -p 8188:8188 comfy-prod