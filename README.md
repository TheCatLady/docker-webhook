# `webhook` &#9875;

[![Image Size](https://img.shields.io/docker/image-size/thecatlady/webhook/latest?style=flat-square&logoColor=white&logo=docker)](https://hub.docker.com/r/thecatlady/webhook)
[![Last Commit](https://img.shields.io/github/last-commit/TheCatLady/docker-webhook?style=flat-square&logoColor=white&logo=github)](https://github.com/TheCatLady/docker-webhook)
[![Build Status](https://img.shields.io/github/workflow/status/TheCatLady/docker-webhook/Build%20Docker%20Images?style=flat-square&logoColor=white&logo=github%20actions)](https://github.com/TheCatLady/docker-webhook)<br/>
[![Become a GitHub Sponsor](https://img.shields.io/badge/github%20sponsors-become%20a%20sponsor-ff69b4?style=flat-square&logo=github%20sponsors)](https://github.com/sponsors/TheCatLady)
[![Donate via PayPal](https://img.shields.io/badge/paypal-make%20a%20donation-blue?style=flat-square&logo=paypal)](http://paypal.me/DHoung)

A lightweight, minimal [`webhook`](https://github.com/adnanh/webhook) container

## Usage

Docker images are available from both [GitHub Container Registry (GHCR)](https://github.com/users/TheCatLady/packages/container/package/webhook) and [Docker Hub](https://hub.docker.com/r/thecatlady/webhook).

If you would prefer to pull from GHCR, simply replace `thecatlady/webhook` with `ghcr.io/thecatlady/webhook` in the examples below.

### Docker Compose (recommended)

Add the following volume and service definitions to a `docker-compose.yml` file:

```yaml
services:
  webhook:
    image: thecatlady/webhook
    container_name: webhook
    command: -verbose -hooks=hooks.yml -hotreload
    environment:
      - TZ=America/New_York #optional
    volumes:
      - /path/to/appdata/config:/config:ro
    ports:
      - 9000:9000
    restart: always
```

Then, run the following command from the directory containing your `docker-compose.yml` file:

```bash
docker-compose up -d
```

### Docker CLI

Run the following command to create the container:

```bash
docker run -d \
  --name=webhook \
  -e TZ=America/New_York `#optional` \
  -v /path/to/appdata/config:/config:ro \
  -p 9000:9000 \
  --restart always \
  thecatlady/webhook:latest \
  -verbose -debug -hotreload -hooks=hook-1.json -hooks=hook-2.json
```

## Updating

The process to update the container when a new image is available is dependent on how you set it up initially.

### Docker Compose

Run the following commands from the directory containing your `docker-compose.yml` file:

```bash
docker-compose pull webhook
docker-compose up -d
docker image prune
```

### Docker CLI

Run the commands below, followed by your original `docker run` command:

```bash
docker stop webhook
docker rm webhook
docker pull thecatlady/webhook
docker image prune
```

## Parameters

The container image is configured using the following parameters passed at runtime:

|Parameter|Function|
|---|---|
|`-e TZ=`|[TZ database name](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) of system time zone; e.g., `America/New_York`|
|`-v /path/to/appdata/config:/config:ro`|Container data directory (mounted as read-only); your JSON/YAML hook definition file should be placed in this folder<br/>(Replace `/path/to/appdata/config` with the desired path on your host)|
|`-p 9000:9000`|Expose port `9000`<br/>(Necessary unless only accessing `webhook` via other containers in the same Docker network)|
|`--restart`|Container [restart policy](https://docs.docker.com/engine/reference/run/#restart-policies---restart)<br/>(`always` or `unless-stopped` recommended)|
|`-verbose -hooks=/config/hooks.yml -hotreload`|[`webhook` parameters](https://github.com/adnanh/webhook/blob/master/docs/Webhook-Parameters.md); replace `hooks.yml` with the name of your JSON/YAML hook definition file, and add/modify/remove arguments to suit your needs<br/>(Can omit if using this exact configuration; otherwise, all parameters must be specified, not just those modified)|

## Configuring Hooks

See [`adnanh/webhook`](https://github.com/adnanh/webhook) for documentation on how to define hooks.

## How to Contribute

Show your support by starring this project! &#x1F31F;  Pull requests, bug reports, and feature requests are also welcome!

You can also support me by [becoming a GitHub sponsor](https://github.com/sponsors/TheCatLady) or [making a one-time PayPal donation](http://paypal.me/DHoung) &#x1F496;