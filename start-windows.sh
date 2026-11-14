#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$0")"

echo "== PC-Free Windows 10 preflight =="

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker CLI is not installed."
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker daemon is not reachable from this Codespace."
  exit 1
fi

if [[ ! -e /dev/kvm ]]; then
  echo "ERROR: /dev/kvm is missing. dockur/windows needs KVM acceleration."
  exit 1
fi

if [[ ! -e /dev/net/tun ]]; then
  echo "ERROR: /dev/net/tun is missing."
  exit 1
fi

if [[ ! -f .env ]]; then
  echo "ERROR: .env is missing. Create it from .env.example and set a private password."
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

if [[ -z "${WINDOWS_USERNAME:-}" || -z "${WINDOWS_PASSWORD:-}" ]]; then
  echo "ERROR: WINDOWS_USERNAME and WINDOWS_PASSWORD must be set in .env."
  exit 1
fi

docker_root="$(docker info --format '{{.DockerRootDir}}')"
available_kb="$(df -Pk "$docker_root" | awk 'NR==2 {print $4}')"
required_kb=$((32 * 1024 * 1024))

echo "Docker data directory: $docker_root"
echo "Free space: $((available_kb / 1024 / 1024)) GiB"
echo "Required free space: at least 32 GiB"

if (( available_kb < required_kb )); then
  echo "ERROR: Not enough Docker storage. Free space or use a larger Linux/KVM host."
  echo "No Windows image has been downloaded and no container was started."
  exit 1
fi

echo "Checking Compose configuration..."
docker compose --env-file .env -f windows10.yml config --quiet

echo "Starting Windows 10..."
docker compose --env-file .env -f windows10.yml up -d

echo "Windows container requested. Check status with:"
echo "docker compose -f windows10.yml ps"
echo "Open Codespaces PORTS and forward port 8006 to access the web viewer."
