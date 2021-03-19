# -------------------------------------------------------------------- checkmake
FROM golang:1.15 AS checkmake
WORKDIR "${GOPATH}/src/github.com/mrtazz/"
RUN git clone https://github.com/mrtazz/checkmake.git
WORKDIR "${GOPATH}/src/github.com/mrtazz/checkmake/"
RUN git config --global user.name 'Marc Carré' && \
    git config --global user.email carre.marc@gmail.com && \
    GOOS=linux GOARCH=amd64 CGO_ENABLED=0 make binaries && \
    make test && \
    mv checkmake /bin/checkmake

# ------------------------------------------------------------- hadolint v1.19.0
FROM hadolint/hadolint@sha256:72ac81641af77f4fdf6c4fe0b336071148fc6babfa83d57c72569e71579b000f AS hadolint

# --------------------------------------------------------------------- misspell
FROM alpine:3.12 AS misspell
RUN apk add --no-cache curl==7.69.1-r1 && \
    curl -L -o ./install-misspell.sh https://git.io/misspell && \
    sh ./install-misspell.sh

# ------------------------------------------------------------ shellcheck v0.7.1
FROM koalaman/shellcheck@sha256:5b4041726a39d79fc49b3ea345c23d4e261d324afb35337ed990d78d0b3f7e75 AS shellcheck

# ----------------------------------------------------------------- shfmt v3.2.1
FROM mvdan/shfmt:v3.2.1-alpine AS shfmt

# ------------------------------------------------------------------ final image
FROM node:15.3-alpine3.12

LABEL maintainer="Marc Carré <carre.marc@gmail.com>" \
    org.opencontainers.image.title="linter" \
    org.opencontainers.image.description="Lint all-the-things" \
    org.opencontainers.image.url="https://github.com/marccarre/linter" \
    org.opencontainers.image.source="git@github.com:marccarre/linter.git" \
    org.opencontainers.image.vendor="Marc Carré <carre.marc@gmail.com>"

RUN apk add --no-cache \
    file=5.38-r0 \
    grep=3.4-r0

COPY --from=checkmake  /bin/checkmake  /bin/checkmake
COPY --from=hadolint   /bin/hadolint   /bin/hadolint
COPY --from=misspell   /bin/misspell   /bin/misspell
COPY --from=shellcheck /bin/shellcheck /bin/shellcheck
COPY --from=shfmt      /bin/shfmt      /bin/shfmt
RUN npm install -g markdownlint-cli@0.25.0
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
