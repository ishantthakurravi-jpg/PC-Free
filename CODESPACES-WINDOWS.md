# Run Windows 10 from PC-Free

## Important compatibility checks

This project uses `dockurr/windows`, which requires a Linux host with working KVM access and at least 32 GB of free disk space. The Windows VM disk is stored in the Docker named volume mounted at `/storage`.

The Codespace diagnostics shared during setup showed:

- Docker root: `/var/lib/docker`
- Filesystem size: about 32 GiB
- Free space: about 19 GiB
- `/dev/kvm` and `/dev/net/tun` were visible

That is not enough free disk space for the documented Windows container requirement. The startup script deliberately stops before downloading Windows when free space is below 32 GiB. Do not keep retrying the download or deleting random files.

The Docker daemon is managed by Codespaces. Creating `/etc/docker/daemon.json` inside the workspace does not reconfigure the already-running host daemon; the Docker root remained `/var/lib/docker` in the diagnostics. The launcher therefore does not try to change Docker's data-root.

## Files

- `windows10.yml`: Docker Compose definition for Windows 10, 4 GiB RAM and 2 CPU cores.
- `.env.example`: safe template for local credentials.
- `.gitignore`: excludes the real `.env` and VM data.
- `start-windows.sh`: checks Docker, KVM, TUN, credentials and free storage before starting.

## One-time setup

Create a private `.env` file in the repository root. Use the same Windows username/password you want, or change the password if it has been exposed in a screenshot or chat. Never commit `.env`.

Example format:

```ini
WINDOWS_USERNAME=clouduser
WINDOWS_PASSWORD=choose-a-new-strong-password
```

Then run:

```bash
bash start-windows.sh
```

If startup succeeds, open the Codespaces **Ports** panel, forward port `8006`, and open its forwarded address. Windows installation may take several minutes.

## If the preflight stops

- **Not enough storage:** use a Linux/KVM machine with at least 32 GiB free in Docker's storage filesystem.
- **KVM missing or inaccessible:** use a Linux/KVM host where Docker containers can access `/dev/kvm`. A visible device node alone does not prove nested virtualization works.
- **Docker daemon unavailable:** restart the Codespace or use a supported Docker host; workspace files cannot restart the managed daemon.

## Stop Windows

```bash
docker compose -f windows10.yml down
```

This stops and removes the container but keeps the named volume. Do not add `-v` unless you intentionally want to delete the Windows VM disk and all its files.
