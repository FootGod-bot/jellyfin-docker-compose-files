# Jellyfin Home Server

Docker Compose files for Jellyfin and the services around it. Each service has its own Compose file, so you can start, stop, and update containers independently.

> The DuckDNS container and scripts are maintained here. The other service definitions were adapted from examples found online.

## Contents

- [Getting started](#getting-started)
- [Shared network](#shared-network)
- [Jellyfin](#jellyfin)
- [jfa-go](#jfa-go)
- [Nginx Proxy Manager](#nginx-proxy-manager)
- [DuckDNS script runner](#duckdns-script-runner)
- [Samba file sharing](#samba-file-sharing)
- [Tailscale](#tailscale)
- [Updating and removing services](#updating-and-removing-services)
- [Other files](#other-files)

## Getting started

1. Install Docker with the Compose plugin on the host.
2. Review the service sections below and edit host paths, ports, domains, time zone, and credentials to match your setup.
3. Create the shared network as described in [Shared network](#shared-network).
4. Start each service with the command in its section.

Run commands from the directory containing these files. Docker must be able to access every host path used in a volume mount. These files currently include both Windows and Linux paths, so change any path that does not match your Docker host.

## Shared network

All six Compose services are configured to join the same external Docker network, named `jellyfin`. Create it once:

```sh
docker network create jellyfin
```

Compose uses this existing network and does not create or remove it with an individual service. Containers on the network can connect to one another using their container or service names. For example, Jellyfin is reachable from other containers at `jellyfin:8096`.

## Jellyfin

**Compose file:** [`jellyfin.yml`](jellyfin.yml)  
**Web interface:** `http://<docker-host>:8096`

Jellyfin serves your media library. The compose file publishes ports `8096` (HTTP) and `8920` (HTTPS), and mounts configuration, cache, and media folders.

Before starting it:

- Update the config and cache folders and each media source path in the `volumes` section.
- Replace the example `JELLYFIN_PublishedServerUrl` with your public URL, or remove that setting if you do not use one.
- Configure HTTPS through your chosen reverse proxy if you plan to serve Jellyfin publicly.

Start it:

```sh
docker compose -f jellyfin.yml up -d
```

## jfa-go

**Compose file:** [`jfa-go.yml`](jfa-go.yml)  
**Web interface:** `http://<docker-host>:8056`

jfa-go provides account management for Jellyfin. Its compose file mounts its own data directory and Jellyfin's configuration directory.

Before starting it, update both `/opt/stacks/...` host paths to locations that exist on your Docker host. The Jellyfin config mount must point to the same configuration data used by the Jellyfin container.

```sh
docker compose -f jfa-go.yml up -d
```

## Nginx Proxy Manager

**Compose file:** [`ngnix.yml`](ngnix.yml)  
**Admin interface:** `http://<docker-host>:81`

Nginx Proxy Manager manages reverse proxy hosts and certificates. The compose file publishes container ports `80`, `443`, and `81` on host ports `8040`, `44340`, and `81` respectively. It stores its data and certificates in `./data` and `./letsencrypt`, relative to the compose file.

Before starting it:

- Change the published host ports if any are already in use.
- Change `TZ` from `Australia/Brisbane` to your time zone.
- Keep the `data` and `letsencrypt` folders backed up; they contain its configuration and certificates.

```sh
docker compose -f ngnix.yml up -d
```

The filename is spelled `ngnix.yml` in this repository; use that spelling in commands.

## DuckDNS script runner

**Compose file:** [`duckdns.yml`](duckdns.yml)  
**Related script:** [`duckdns.sh`](duckdns.sh)

This runs the `script-runner` container, which executes a mounted script every 300 seconds. The compose file currently mounts `C:/Docker/script-r/script-r.sh` inside the container as `/root/script.sh`.

Before starting it:

- Make the host path in the volume mount point to the script you want to run. The local `duckdns.sh` file is not mounted by the current compose file unless you change that path.
- Edit the DuckDNS subdomain and token in the script. Do not commit a real token to a public repository.
- Confirm the script runner's expected script path and timing behavior for the image you use.

```sh
docker compose -f duckdns.yml up -d
```

## Samba file sharing

**Compose file:** [`samba.yml`](samba.yml)  
**Configuration:** [`samba.conf`](samba.conf)

Samba shares the movies, TV, and music folders over SMB on host port `445`.

Before starting it:

- Change `/docker/mount/...` mounts to the media folders on your host.
- Change `/docker/con/samba.conf` to the host path of `samba.conf`.
- Replace the example `USER` and `PASS` values with a strong Samba login. Avoid keeping real passwords in source control.
- Check that the share paths in `samba.conf` (`/movies`, `/tv-shows`, and `/music`) match the container mount targets.
- Make sure host port `445` is available and allowed through your firewall for the clients that need SMB access.

```sh
docker compose -f samba.yml up -d
```

## Tailscale

**Compose file:** [`tailscale.yml`](tailscale.yml)

Tailscale connects the container to your tailnet. This compose file uses `/dev/net/tun` and Linux network capabilities, so confirm your Docker host supports those settings.

Before starting it:

- Replace the masked `TS_AUTHKEY` value with a valid Tailscale auth key. Treat it as a secret and do not commit it.
- Update `/docker/con/tailscale/state` to a persistent host directory so the node state survives container recreation.
- Confirm `/dev/net/tun` is available to Docker.

The container joins the `jellyfin` bridge network. This differs from host networking and may affect how the Tailscale node reaches or advertises host and LAN services.

```sh
docker compose -f tailscale.yml up -d
```

## Updating and removing services

Pull the latest image and recreate one service with:

```sh
docker compose -f jellyfin.yml pull
docker compose -f jellyfin.yml up -d
```

Replace `jellyfin.yml` with the relevant compose filename. To stop and remove a service's container, run:

```sh
docker compose -f jellyfin.yml down
```

The shared external `jellyfin` network remains in place when an individual service is stopped. Remove it only after all attached containers have been taken down and you no longer need the shared network:

```sh
docker network rm jellyfin
```

## Other files

- [`dynu.sh`](dynu.sh) is a standalone Dynu update script; no Compose file currently runs it.
- [`duckdns.sh`](duckdns.sh) contains the DuckDNS update script.