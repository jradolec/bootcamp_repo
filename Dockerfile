# syntax=docker/dockerfile:1

# Public starter image by default. If your organization uses private Chainguard
# images, build with:
#   docker build --build-arg BASE_IMAGE=cgr.dev/${CHAINGUARD_ORG}/squid-proxy:latest .
# Authenticate first with chainctl/docker login (see README.md).
ARG BASE_IMAGE=cgr.dev/chainguard/squid-proxy:latest
FROM ${BASE_IMAGE}

# Chainguard's squid-proxy image already runs as the non-root "squid" user by
# default. Do not install packages or override USER; keep the hardened runtime.
COPY squid.conf /etc/squid.conf

EXPOSE 3128
CMD ["/usr/sbin/squid", "-N", "-f", "/etc/squid.conf"]
