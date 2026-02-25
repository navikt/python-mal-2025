# NOTE: Nav har kjøpt tilgang til flere Chainguard bilder, så man kan fint bytte
# ut om man trenger en annen versjon av Python, pass da på at versjonen man
# bruker må være lik for "builder" og under ved neste "FROM"
FROM cgr.dev/chainguard/python:latest-dev AS builder

# Be uv kompilere kilder for raskere oppstart
ENV UV_COMPILE_BYTECODE=1
# Kopier fra cache siden vi bruker --mount
ENV UV_LINK_MODE=copy
# Ikke synkroniser disse gruppene
ENV UV_NO_GROUP="dev"

# Opprett arbeidsmappe for prosjektet i Docker
WORKDIR /app

# Installer avhengigheter for prosjektet uten å installere selve prosjektet,
# dette er gjort for å kunne mellomlagre steg i Docker og bygge hurtigere siden
# vi forventer at avhengigheter endres sjeldnere enn selve koden vi skriver
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project

# Kopier vår kode inn i Docker
COPY . /app

# Installer prosjektet (vår kode)
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --locked

# For å bygge brukte vi `latest-dev`, her bruker vi bare `latest` for å minimere
# antall eksterne avhengigheter i bildet
#
# NOTE: Nav har kjøpt tilgang til flere Chainguard bilder, så man kan fint bytte
# ut om man trenger en annen versjon av Python, pass da på at versjonen man
# bruker må være lik her og for "builder" over
FROM cgr.dev/chainguard/python:latest

# Kopier kode fra byggebildet
COPY --from=builder --chown=app:app /app /app

# Eksponer pakker fra virtueltmiljø
ENV PATH="/app/.venv/bin:$PATH"

# Set arbeidsmappe slik at brukere ikke trenger å forholde seg til "/app"
WORKDIR /app

# Selv om det ser ut til at vi bruker "egen" Python distribusjon så vil den peke
# på Chainguard sin distribusjon
ENTRYPOINT ["/app/.venv/bin/python3"]

# Erstatt følgende med det du ville kjørt for applikasjonen din
CMD ["main.py"]
