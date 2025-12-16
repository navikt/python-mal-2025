# Vi bruker et Docker image fra uv hvor uv allerede er installert
FROM ghcr.io/astral-sh/uv:0.9.17-bookworm-slim AS builder

# Be uv kompilere kilder for raskere oppstart
ENV UV_COMPILE_BYTECODE=1
# Kopier fra cache siden vi bruker --mount
ENV UV_LINK_MODE=copy
# Installer Python i en egen mappe (VIKTIG med egen mappe!), vi gjør dette for å
# forsikre oss om at vi kjører samme Python versjon som prosjektet er satt opp
# til i `.python-version`
ENV UV_PYTHON_INSTALL_DIR=/python

# Opprett arbeidsmappe for prosjektet i Docker
WORKDIR /app
# Installer avhengigheter for prosjektet uten koden
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=.python-version,target=.python-version \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project --no-default-groups

# Kopier kode inn i Docker bildet
COPY . /app
# Installer prosjektet
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked --no-default-groups

# Bildet vi ender opp med blir distroless
FROM gcr.io/distroless/cc-debian13

# Kopier uv sin Python installasjon
COPY --from=builder --chown=python:python /python /python
# Kopier kode fra byggebildet
COPY --from=builder --chown=app:app /app /app

# Eksponer pakker fra virtueltmiljø
ENV PATH="/app/.venv/bin:$PATH"

# Siden vi må bruke et Python3 bilde fra distroless så er det viktig at vi
# tømmer startpunkt for å ikke kjøre Python fra distroless miljøet
ENTRYPOINT [ ]

CMD ["<det du vil kjøre>"]
