# Vi bruker et Docker bilde hvor uv allerede er installert
FROM ghcr.io/astral-sh/uv:0.9.18-trixie-slim AS builder

# Be uv kompilere kilder for raskere oppstart
ENV UV_COMPILE_BYTECODE=1
# Kopier fra cache siden vi bruker --mount
ENV UV_LINK_MODE=copy
# Installer Python i en egen mappe (VIKTIG med egen mappe!), vi gjør dette for å
# forsikre oss om at vi kjører samme Python versjon som prosjektet er satt opp
# til i `.python-version`
ENV UV_PYTHON_INSTALL_DIR=/python
# Ikke synkroniser disse gruppene, bedre å definere i miljøvariabel for å kunne
# bruke `uv run` som CMD senere
ENV UV_NO_GROUP="dev"

# Opprett arbeidsmappe for prosjektet i Docker
WORKDIR /app

# Installer Python separat for cache
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=.python-version,target=.python-version \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv python install

# Installer avhengigheter for prosjektet uten å installere selve prosjektet,
# dette er gjort for å kunne mellomlagre steg i Docker og bygge hurtigere siden
# vi forventer at avhengigheter endres sjeldnere enn selve koden vi skriver
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=.python-version,target=.python-version \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project

# Kopier vår kode inn i Docker
COPY . /app

# Installer prosjektet (vår kode)
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked

# NOTE: Nav har kjøpt tilgang til flere Chainguard bilder, så man kan fint bytte
# ut om man trenger noe annet
#
# NOTE: Vi bruker et Python bilde her slik at vi vet at vi har tilgang på alle
# avhengigheter som trengs for Python, dette kan være viktig for både kjøretid
# og eksterne pakker, men vi kommer ikke til å bruke Python fra Chainguard bildet
FROM cgr.dev/chainguard/python:latest

# Kopier uv sin Python installasjon
COPY --from=builder --chown=python:python /python /python
# Kopier kode fra byggebildet
COPY --from=builder --chown=app:app /app /app

# Eksponer pakker fra virtueltmiljø
ENV PATH="/app/.venv/bin:$PATH"

# Set arbeidsmappe slik at brukere ikke trenger å forholde seg til "/app"
WORKDIR /app

# Ikke bruk Chainguard sin default Python
ENTRYPOINT ["/app/.venv/bin/python3"]

# Erstatt følgende med det du ville kjørt for applikasjonen din
CMD ["main.py"]
