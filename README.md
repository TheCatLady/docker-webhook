# `webhook` &#9875;

[![Image Size](https://img.shields.io/docker/image-size/thecatlady/webhook/latest?style=flat-square&logoColor=white&logo=docker)](https://hub.docker.com/r/thecatlady/webhook)
[![Last Commit](https://img.shields.io/github/last-commit/TheCatLady/docker-webhook?style=flat-square&logoColor=white&logo=github)](https://github.com/TheCatLady/docker-webhook)
[![Build Status](https://img.shields.io/github/workflow/status/TheCatLady/docker-webhook/Build%20Docker%20Images?style=flat-square&logoColor=white&logo=github%20actions)](https://github.com/TheCatLady/docker-webhook)
[![Become a GitHub Sponsor](https://img.shields.io/badge/github%20sponsors-help%20feed%20my%20cats!-ff69b4?style=flat-square&logo=github%20sponsors)](https://github.com/sponsors/TheCatLady)

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
  thecatlady/webhook \
  -verbose -hooks=hooks.yml -hotreload
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

| Parameter                                      | Function                                                                                                                                                                                                                                                                                                                                              |
| ---------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-e TZ=`                                       | [TZ database name](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) of system time zone; e.g., `America/New_York`                                                                                                                                                                                                                        |
| `-v /path/to/appdata/config:/config:ro`        | Container data directory (mounted as read-only); your JSON/YAML hook definition file should be placed in this folder<br/>(Replace `/path/to/appdata/config` with the desired path on your host)                                                                                                                                                       |
| `-p 9000:9000`                                 | Expose port `9000`<br/>(Necessary unless only accessing `webhook` via other containers in the same Docker network)                                                                                                                                                                                                                                    |
| `--restart`                                    | Container [restart policy](https://docs.docker.com/engine/reference/run/#restart-policies---restart)<br/>(`always` or `unless-stopped` recommended)                                                                                                                                                                                                   |
| `-verbose -hooks=/config/hooks.yml -hotreload` | [`webhook` parameters](https://github.com/adnanh/webhook/blob/master/docs/Webhook-Parameters.md); replace `hooks.yml` with the name of your JSON/YAML hook definition file, and add/modify/remove arguments to suit your needs<br/>(Can omit if using this exact configuration; otherwise, all parameters must be specified, not just those modified) |

## Configuring Hooks

See [`adnanh/webhook`](https://github.com/adnanh/webhook) for documentation on how to define hooks.

### Considerations for running inside the Docker container

- The webhook processes inside the container to run as `root` so things like permissions need to be accounted for
- The image includes `sh` (shell) to execute commands/scripts (it does not include `bash`)

You can set your `execute-command` to be a shell script that checks if any of the commands required exist, and if not installs them. Check and then install is useful because it will check and install when the first webhook request is received after creating the container, but not reinstall every time a webhook is received.

Here is an example of using webhook with git to retrieve the latest commit changes for a repository:

---

Example `docker-compose.yml`

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
      - /path/to/parent/git_folder:/opt/git
      - /path/to/.ssh:/root/.ssh:ro
    ports:
      - 9000:9000
    restart: always
```

In the above:

- `/path/to/parent/git_folder` is one folder level above where the git repos exist (ex: `/home/myuser/git/` which contains multiple repos), you can mount your git repos however works for you
- `/path/to/.ssh` in this example is `/home/myuser/.ssh` which contains a deploy key such as `id_ed25519` or `id_rsa`

---

Example `hooks.json` (placed at `/path/to/appdata/config/hooks.json`)

```json
[
  {
    "id": "my-hook-name",
    "execute-command": "/config/run/git-checkout-force.sh",
    "command-working-directory": "/opt/git/myrepo",
    "include-command-output-in-response": true,
    "include-command-output-in-response-on-error": true,
    "pass-arguments-to-command": [
      { "source": "payload", "name": "head_commit.id", "comment": "GIT_REF" },
      {
        "source": "string",
        "name": "/opt/git/myrepo",
        "comment": "GIT_DIR"
      },
      { "source": "string", "name": "1000", "comment": "PUID" },
      { "source": "string", "name": "1000", "comment": "PGID" }
    ],
    "trigger-rule": {
      "and": [
        {
          "match": {
            "type": "payload-hmac-sha1",
            "secret": "<YOUR_GITHUB_WEBHOOK_SECRET>",
            "parameter": { "source": "header", "name": "X-Hub-Signature" }
          }
        },
        {
          "match": {
            "type": "value",
            "value": "refs/heads/main",
            "parameter": { "source": "payload", "name": "ref" }
          }
        }
      ]
    }
  }
]
```

In the above:

- The branch is expected to be `main`, you might need it to be `master` or something else
- The `command-working-directory` is pointed at where the container will see the repo folder (mounted inside the container)
- The elements inside `pass-arguments-to-command` will be passed to the `execute-command` as parameters (see below)

---

Example `git-checkout-force.sh` (placed at `/path/to/appdata/config/run/git-checkout-force.sh`)

```shell
#!/usr/bin/env sh

# variables
GIT_REF=${1}
GIT_DIR=${2}
PUID=${3}
PGID=${4}

# log date
date

# install git
if ! command -v git > /dev/null 2>&1; then
    apk add --no-cache \
        git
fi

# install openssh
if ! command -v ssh > /dev/null 2>&1; then
    apk add --no-cache \
        openssh
fi

# allow git with different ownership
git config --global --add safe.directory ${GIT_DIR}

# fetch from git
git fetch --all

# checkout git reference
git checkout --force ${GIT_REF}

# set ownership
chown -R ${PUID}:${PGID} ${GIT_DIR}
```

In the above:

- `GIT_REF` is the first argument, passed in when `webhook` runs the script. It should be the commit id (see `hooks.json above`)
- `PUID` and `PGID` are the second/third arguments, passed in, later used to `chown`. Passing these from webhook allows multiple hooks with to be setup resulting in different file ownership in each working directory.
- Log the date, just for the sake of it
- Check if the `git` command exists. If not, install it using `apk` (the alpine package manager included in the base OS of the image)
- Check if the `ssh` command exists. If not, install it
- `git config --global --add safe.directory ${GIT_DIR}` newer versions of `git` care about who owns the files in the repository, so tell `git` this directory is safe to run the rest of the commands (since `root` is the user running `webhook` in the container). This can result in `root` being the owner of newly added or changed files, which we will handle below
- `git fetch --all` to retrieve the latest changes from your git repository
- `git checkout --force ${GIT_REF}` force checkout the referenced commit (passed in argument)
- `chown -R ${PUID}:${PGID} ${GIT_DIR}` set the ownership of all the files in the repo using the `PUID` and `PGID` that are passed to the script from `hooks.json`

---

Important takeaways:

- `webhook` runs in the container as root
- all commands `webhook` executes via your `hooks.json` execute as root
- you (may) need to `chown` at the end of your script so that `root` is not the owner of your files
- the image does not include much tooling (ex: `git` or `ssh`) but you can install the tools you need in your script
- when installing tooling, check if it exists before installing, so that you're not reinstalling every time you receive a webhook request

## How to Contribute

Show your support by starring this project! &#x1F31F; Pull requests, bug reports, and feature requests are also welcome!

You can also support me by [becoming a GitHub sponsor](https://github.com/sponsors/TheCatLady) or [making a one-time donation](https://github.com/sponsors/TheCatLady?frequency=one-time) &#x1F496;
