podman build --no-cache=true --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') --build-arg SLURM_VERSION=slurm-23-02-7-1 -t slurm:latest .
