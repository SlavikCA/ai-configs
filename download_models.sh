#### DOWNLOAD models

sudo mkdir -p /var/lib/docker/.cache/huggingface/hub
sudo du -h -d 1  /var/lib/docker/.cache/huggingface/hub
sudo df -hT      /var/lib/docker/.cache/huggingface/hub
curl -LsSf https://hf.co/cli/install.sh | bash

# Copy model:
sudo rsync -av --no-o --no-g /var/lib/docker/.cache/huggingface/hub/models--unsloth--medgemma-27b-it-GGUF /mnt/models/.cache/huggingface/hub/

# https://huggingface.co/docs/huggingface_hub/main/en/guides/cli#hf-cache
sudo /home/slavik/.local/bin/hf cache ls --cache-dir /var/lib/docker/.cache/huggingface/hub --revisions

sudo su
export HF_HUB_DISABLE_SHARED_BLOBS=1

# https://huggingface.co/unsloth/medgemma-27b-it-GGUF
/home/slavik/.local/bin/hf download --cache-dir /var/lib/docker/.cache/huggingface/hub \
 unsloth/medgemma-27b-it-GGUF --include *UD-Q8_K_XL.gguf --include *-F16.gguf 

# https://huggingface.co/unsloth/Qwen3.8-Flash-Next-GGUF
/home/slavik/.local/bin/hf download --cache-dir /var/lib/docker/.cache/huggingface/hub \
 unsloth/Qwen3.8-Flash-Next-GGUF \
 --include *mtp-Qwen3.8-Flash-Next-Q4_K_M.gguf \
 --include *Qwen3.8-Flash-Next-UD-Q4_K_XL-00001*.gguf \
 --include *-BF16.gguf

# https://huggingface.co/BoldingBuilds/orcarouter_GLM-5.3-Flash-Uncensored-GGUF
/home/slavik/.local/bin/hf download --cache-dir /var/lib/docker/.cache/huggingface/hub \
 BoldingBuilds/orcarouter_GLM-5.3-Flash-Uncensored-GGUF \
 --include *IQ3_XXS* \
 --include *mmproj-GLM-5.3-Flash-Uncensored-F16.gguf
