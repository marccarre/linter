# -------------------------------------------------------------------- checkmake
FROM golang:1.16 AS checkmake
WORKDIR "${GOPATH}/src/github.com/mrtazz/"
RUN git clone https://github.com/mrtazz/checkmake.git
WORKDIR "${GOPATH}/src/github.com/mrtazz/checkmake/"
RUN git config --global user.name 'Marc Carré' && \
    git config --global user.email carre.marc@gmail.com && \
    GOOS=linux GOARCH=amd64 CGO_ENABLED=0 make binaries && \
    make test && \
    mv checkmake /bin/checkmake

# ------------------------------------------- hadolint v1.23.0-8-gb01c5a9-alpine
FROM hadolint/hadolint@sha256:f48a018d301140f92d949758f21b506ec3161b8d88c5aa289deb1816f23a15f2 AS hadolint

# --------------------------------------------------------------------- misspell
FROM alpine:3.13 AS misspell
RUN apk add --no-cache curl==7.74.0-r1 && \
    curl -L -s -S -o ./install-misspell.sh https://git.io/misspell && \
    sh ./install-misspell.sh

# ------------------------------------------------------------ shellcheck v0.7.1
FROM koalaman/shellcheck@sha256:5b4041726a39d79fc49b3ea345c23d4e261d324afb35337ed990d78d0b3f7e75 AS shellcheck

# ----------------------------------------------------------------- shfmt v3.2.4
FROM mvdan/shfmt:v3.2.4-alpine AS shfmt

# ------------------------------------------------------------------ final image
FROM node:15.12-alpine3.13

LABEL maintainer="Marc Carré <carre.marc@gmail.com>" \
    org.opencontainers.image.title="linter" \
    org.opencontainers.image.description="Lint all-the-things" \
    org.opencontainers.image.url="https://github.com/marccarre/linter" \
    org.opencontainers.image.source="git@github.com:marccarre/linter.git" \
    org.opencontainers.image.vendor="Marc Carré <carre.marc@gmail.com>"

RUN apk add --no-cache \
    bash=5.1.0-r0 \
    file=5.39-r0 \
    grep=3.6-r0

COPY --from=checkmake  /bin/checkmake  /bin/checkmake
COPY --from=hadolint   /bin/hadolint   /bin/hadolint
COPY --from=misspell   /bin/misspell   /bin/misspell
COPY --from=shellcheck /bin/shellcheck /bin/shellcheck
COPY --from=shfmt      /bin/shfmt      /bin/shfmt
RUN npm install -g markdownlint-cli@0.27.1
COPY bin/shexec /bin/shexec

ENV USER=linter
ENV UID=10000
ENV GROUP=linter
ENV GID=10001
RUN addgroup \
    --gid "${GID}" \
    "${GROUP}"
RUN adduser \
    --disabled-password \
    --home "/home/${USER}" \
    --ingroup "${GROUP}" \
    --shell /bin/sh \
    --uid "${UID}" \
    "${USER}"
USER linter

WORKDIR /mnt/lint
COPY bin/lint /bin/lint
CMD [ "/bin/lint" ]

# Changing for every build, hence added as the last step of the Dockerfile:
ARG BUILD_DATE
ARG VCS_REF
LABEL org.opencontainers.image.revision="$VCS_REF" \
      org.opencontainers.image.created="$BUILD_DATE"
