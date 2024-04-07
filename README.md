# postgresml-docker

Run [PostgresML](https://postgresml.org), [TimescaleDB](https://www.timescale.com) and [pgAdmin](https://www.pgadmin.org) in one command. This repository contains a `docker-compose` file to run a PostgresML database with TimescaleDB and a PgAdmin instance. The stack is configured to use the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) to enable GPU support for the PostgresML database. Additionally there are bulgarian dictionaries that provide full text search support for the Bulgarian language that can be spicy combined with the functionality that PostgresML provides to achieve wonderful stuff.

**`TimescaleDB currently is not included in the stack. It will be added in the future.`**

## Table of Contents

- [Requirements](#requirements)
- [Usage](#usage)
- [System Requirements](#system-requirements)
- [Cleanup](#cleanup)

## Requirements

- [Nvidia Cuda](https://developer.nvidia.com/cuda-downloads)

- [Nvidia Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

Install the NVIDIA Container Toolkit on Ubuntu 22.04

```shell
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
```

## Usage

```shell
git clone https://github.com/athennamind/postgresml-docker.git
cd postgresml-docker
```

Before running the containers, take a look at the `.env` file and adjust the values to your needs. By default the stack is configured to use all available GPUs as specified in `NVIDIA_VISIBLE_DEVICES`. If you have a single GPU, you can leave the default value. For multiple GPUs please refer to the [Docker Documentation](https://docs.docker.com/compose/gpu-support/) to pin specific GPUs.

```shell
vim .env
# ..........
docker compose up -d
# wait for the containers to start
docker compose logs -f
```

- Validate that we are all good

```shell
docker exec -it pgml psql -U postgres -d pgml -c "SELECT pgml.xgboost_version();"

 xgboost_version
-----------------
 1.62
(1 row)
```

- Open your browser and navigate to `http://localhost:8000` to access the PostgresML dashboard/ui/whatever. 
- Open your browser and navigate to `http://localhost:8001` to access the PgAdmin instance.

If you want to tweak the postgres config, do by editing the `configs/pgml/postgressql.conf` file. Do not forget to restart the compose after.

## System Requirements

This compose was used on the following system:

- Ubuntu 22.04
- Docker version 25.0.4, build 1a576c5 
- 16GB of RAM
- 8 CPU cores
- 2x NVIDIA RTX 3090
- 1TB Local SSD Storage

Please always consider benchmark and adjusting the resources to your needs, especially if you are going to run this compose in a production environment.

## Cleanup 

To stop and remove the containers and volumes, run the following command:

```shell
docker compose down
docker volume ls | grep "postgresml-docker" | awk '{print $2}' | grep -v "VOLUME" | xargs docker volume rm -f
```