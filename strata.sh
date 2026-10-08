git clone https://github.com/Niko1221/Strata.git
cd Strata
sudo docker build -t strata --build-arg CUDA_ARCHITECTURES=120 .

sudo mkdir /var/lib/docker/strata

D_OPTIONS="-d --rm 
 --device=nvidia.com/gpu=0 \
 -e NVIDIA_DRIVER_CAPABILITIES=compute,utility \
 --ulimit memlock=-1"

sudo docker run $D_OPTIONS -p 8080:8080 --name strata  -e MODEL=IQ3_S -e FAMILY=qwen -e CONTEXT=131072 -e VISION=yes -v /var/lib/docker/strata:/data strata

sudo docker logs -f strata

sudo docker stop strata
