# Secure Squid Proxy on Chainguard

This repository builds a secure, production-ready Squid proxy container from Chainguard's minimal Squid image. The default build uses `cgr.dev/chainguard/squid-proxy:latest`; private Chainguard org images and the FIPS/STIG-hardened variant are supported with build arguments.

## What is included

```text
.
├── Dockerfile
├── Dockerfile.fips
├── squid.conf
├── docker-compose.yml
├── Makefile
├── README.md
├── .dockerignore
├── .github/workflows/build-squid-image.yml
└── test/
    └── smoke-test.sh
```

## Security defaults

- Uses Chainguard's `squid-proxy` image without adding runtime packages.
- Preserves Chainguard's non-root default `squid` user by not overriding `USER`.
- Runs Squid in the foreground with `/usr/sbin/squid -N -f /etc/squid.conf`.
- Listens on the default Squid port, `3128`.
- Allows proxy access only from RFC1918 private source ranges by default:
  - `10.0.0.0/8`
  - `172.16.0.0/12`
  - `192.168.0.0/16`
- Denies unsafe destination ports.
- Denies `CONNECT` tunnels except SSL/TLS ports.
- Denies all remaining traffic to avoid open proxy behavior.
- Logs to stdout/stderr for container observability.

> Review `squid.conf` before production deployment and narrow `private_rfc1918` to the exact networks that should use the proxy.

## Prerequisites

- Docker or another compatible container runtime.
- `make`.
- `curl` for smoke tests.
- Optional: `trivy` for local vulnerability scanning.
- Optional: `chainctl` for private Chainguard Registry authentication.

## Build

Build with the public Chainguard starter image:

```sh
make build
```

Equivalent Docker command:

```sh
docker build \
  --build-arg BASE_IMAGE=cgr.dev/chainguard/squid-proxy:latest \
  -t secure-squid-chainguard:latest \
  .
```

## Private Chainguard org image

If your environment requires a private Chainguard Registry image, authenticate first and override `BASE_IMAGE`:

```sh
chainctl auth login
chainctl auth configure-docker
export CHAINGUARD_ORG="your-org-name"
make build BASE_IMAGE="cgr.dev/${CHAINGUARD_ORG}/squid-proxy:latest"
```

You can also use Docker login if your organization issues registry credentials:

```sh
docker login cgr.dev
make build BASE_IMAGE="cgr.dev/${CHAINGUARD_ORG}/squid-proxy:latest"
```

## Optional FIPS build

The FIPS/STIG-hardened image is private-org based and does not include a shell or package manager, so this repository only copies static configuration into it.

```sh
chainctl auth login
chainctl auth configure-docker
make build-fips CHAINGUARD_ORG="your-org-name"
```

This builds:

```text
secure-squid-chainguard-fips:latest
```

## Run locally

Run with Docker:

```sh
make run
```

Or use Docker Compose:

```sh
docker compose up --build
```

The proxy is published on local port `3128`.

## Test

Run the smoke test:

```sh
make test
```

The smoke test starts the image, proxies a `curl` request through `127.0.0.1:3128`, prints container logs on failure, and removes the test container.

You can also test manually:

```sh
curl -x http://127.0.0.1:3128 http://example.com/ -I
```

## Scan

Scan the built image with Trivy:

```sh
make scan
```

## Save a downloadable image tarball

Export the finished image as a gzipped tarball:

```sh
make save
```

This writes:

```text
dist/secure-squid-chainguard.tar.gz
```

Load the image elsewhere with:

```sh
docker load -i dist/secure-squid-chainguard.tar.gz
```

`docker load` accepts gzip-compressed archives directly with Docker. If your runtime does not, decompress first:

```sh
gunzip -c dist/secure-squid-chainguard.tar.gz > dist/secure-squid-chainguard.tar
docker load -i dist/secure-squid-chainguard.tar
```

## Pinned digest support

The repository defaults to `:latest` for the initial build as requested. For production reproducibility, pin the base image by digest after selecting a tested release:

```sh
make build BASE_IMAGE="cgr.dev/chainguard/squid-proxy@sha256:<digest>"
```

For private org images:

```sh
make build BASE_IMAGE="cgr.dev/${CHAINGUARD_ORG}/squid-proxy@sha256:<digest>"
```

For FIPS, update `Dockerfile.fips` or build with a digest-qualified private base image pattern in your own controlled fork.

## GitHub Actions artifact

The workflow at `.github/workflows/build-squid-image.yml` builds the image, runs the smoke test, scans with Trivy, generates an SBOM with Syft when the `syft` binary is available, saves the image, and uploads `dist/secure-squid-chainguard.tar.gz` as a downloadable artifact.

For private Chainguard org images in CI, configure registry authentication with your organization's preferred Chainguard identity secret and update the build arguments/environment as needed.
