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
   -hf bartowski/orcarouter_Qwen3.8-27B-Uncensored-GGUF:Q8_0 \
   --ctx-size 100000

sudo docker run --name llama $D_OPTIONS --memory=85g --memory-swap=85g -p 8080:8080 $IMAGE $LLM \
    --threads 10 \
    --ctx-size 131072 \
    -hf unsloth/Qwen3.8-Flash-Next-GGUF:UD-Q4_K_XL 


sudo docker logs -f llama

sudo docker stop llama
