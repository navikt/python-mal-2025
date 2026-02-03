# https://just.systems

# Klargjør prosjektet ved å installere `prek` og oppdatere avhengigheter fra malen
prepare:
    uv run --only-group lint prek install
    uv sync --only-group lint --upgrade

# Fiks feil og formater kode med ruff
fix:
    uv run --only-group lint ruff check --fix .
    uv run --only-group lint ruff format .

# Sjekk at alt koden ser bra ut og er klar for å legges til i git
lint:
    uv run --only-group lint prek run --all-files --color always

# Lag et preview med Quarto
preview:
    uv run --group quarto quarto preview .

# Bygg prosjektet i Docker
build:
    docker build .
