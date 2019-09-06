# Slurm on CentOS 7 Docker Image

This is a fork from https://github.com/giovtorres/docker-centos7-slurm.
I have made some changes to optimize it for my own purposes. 

For now, I'll leave notes about how to use it with Docker Compose.

```
# Build an all-in-one SLURM container
docker-compose up -d

# Go into the container
docker-compose exec slurm bash

# Use slurm commands from outside the container (e.g. sbatch)
docker-compose exec slurm sbatch --wrap="sleep 3 && hostname"
docker-compose exec slurm cat slurm-*.out
```
