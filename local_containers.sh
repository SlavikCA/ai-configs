### run docker locally:

# First, run "dead" load on Vast.

D_OPTIONS="-d --rm 
 --device=nvidia.com/gpu=0 \
 -e NVIDIA_DRIVER_CAPABILITIES=compute,utility \
 -v /var/lib/docker/.cache/huggingface/hub:/root/.cache/huggingface/hub"

# NVIDIA_DRIVER_CAPABILITIES
# video    | NVENC/NVDEC hardware transcode (ffmpeg, Jellyfin)
# graphics | OpenGL/Vulkan/EGL rendering, 3D, remote desktops

# nvidia-ctk cdi list

sudo docker run $D_OPTIONS --name ubuntu24 \
  nvidia/cuda:13.3.0-devel-ubuntu24.04 \
  sleep infinity
  nvidia-smi -L

sudo docker run $D_OPTIONS \
 -p 3000:3000 -p 9000:9000 \
 --name flux2-dev camenduru/tostui-flux-2-dev

#### DOWNLOAD models

sudo mkdir -p /var/lib/docker/.cache/huggingface/hub
sudo du -h -d 1  /var/lib/docker/.cache/huggingface/hub
sudo df -hT      /var/lib/docker/.cache/huggingface/hub
curl -LsSf https://hf.co/cli/install.sh | bash

# https://huggingface.co/docs/huggingface_hub/main/en/guides/cli#hf-cache
sudo /home/slavik/.local/bin/hf cache ls --cache-dir /var/lib/docker/.cache/huggingface/hub --revisions

sudo su
export HF_HUB_DISABLE_SHARED_BLOBS=1

# https://huggingface.co/unsloth/medgemma-27b-it-GGUF
/home/slavik/.local/bin/hf download --cache-dir /var/lib/docker/.cache/huggingface/hub \
 unsloth/medgemma-27b-it-GGUF --include *UD-Q8_K_XL.gguf --include *-F16.gguf 

# Copy model:
sudo rsync -av --no-o --no-g /var/lib/docker/.cache/huggingface/hub/models--unsloth--medgemma-27b-it-GGUF /mnt/models/.cache/huggingface/hub/

# run LLAMA:

IMAGE="ghcr.io/ggml-org/llama.cpp:server-cuda13-b11459"

LLM="--host 0.0.0.0  --port 8080  --api-key fursov \
   --gpu-layers-draft all \
   --top-p 0.95 --top-k 20 --temp 1.0 --min-p 0.00 --repeat-penalty 1.0"

# https://huggingface.co/unsloth/Qwen3.8-27B-GGUF
sudo docker run --name llama $D_OPTIONS -p 8080:8080 $IMAGE $LLM \
   -hf unsloth/Qwen3.8-27B-GGUF:UD-Q8_K_XL \
   --ctx-size 260000

# https://huggingface.co/bartowski/orcarouter_Qwen3.8-27B-Uncensored-GGUF
sudo docker run --name llama $D_OPTIONS -p 8080:8080 $IMAGE $LLM \
   --spec-type draft-mtp \
   -hf bartowski/orcarouter_Qwen3.8-27B-Uncensored-GGUF:Q5_K_M \
   --ctx-size 100000

# https://huggingface.co/unsloth/Qwen3.8-Flash-Next-GGUF
/home/slavik/.local/bin/hf download --cache-dir /var/lib/docker/.cache/huggingface/hub \
 unsloth/Qwen3.8-Flash-Next-GGUF \
 --include *mtp-Qwen3.8-Flash-Next-Q4_K_M.gguf \
 --include *Qwen3.8-Flash-Next-UD-Q4_K_XL-00001*.gguf \
 --include *-BF16.gguf

sudo docker run --name llama $D_OPTIONS --memory=85g --memory-swap=85g -p 8080:8080 $IMAGE $LLM \
    --threads 10 \
    --ctx-size 131072 \
    -hf unsloth/Qwen3.8-Flash-Next-GGUF:UD-Q4_K_XL 


# https://huggingface.co/BoldingBuilds/orcarouter_GLM-5.3-Flash-Uncensored-GGUF
# 128 GB
/home/slavik/.local/bin/hf download --cache-dir /var/lib/docker/.cache/huggingface/hub \
 BoldingBuilds/orcarouter_GLM-5.3-Flash-Uncensored-GGUF \
 --include *IQ3_XXS* \
 --include *mmproj-GLM-5.3-Flash-Uncensored-F16.gguf

sudo docker logs -f llama

sudo docker stop llama
