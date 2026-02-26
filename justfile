# https://just.systems

# Hvis ingen kommando vis alle tilgjengelige oppskrifter
default:
    @just --list

# Klargjør prosjektet ved å installere `prek` og oppdatere avhengigheter fra malen
prepare:
    uv run --only-dev prek install
    uv lock --upgrade

# Fiks feil og formater kode med ruff
fix:
    uv run --only-dev ruff check --fix .
    uv run --only-dev ruff format .

# Sjekk at alt koden ser bra ut og er klar for å legges til i git
lint:
    uv run --only-dev prek run --all-files --color always

# Lag et preview med Quarto
preview:
    uv run --group quarto quarto preview .

# Bygg Quarto-prosjektet
render:
    uv run --group quarto quarto render .

# Bygg prosjektet i Docker
[arg('image', pattern='chainguard_python.Dockerfile|Dockerfile')]
build image='Dockerfile':
    docker build -f {{image}} .

# Sjekk etter sårbarheter i Python-avhengigheter
audit:
    uv run --all-groups --with pip-audit pip-audit --local

# Oppdater Python og pre-commit avhengigheter
update:
    uv lock --upgrade
    uv run prek auto-update
