# Mal for Python-prosjekt (2025)

Dette prosjektet inneholder en mal for hvordan man kan starte et Python-prosjekt
(datert 2025 siden det er forventet at 'best practice' oppdateres jevnlig!).

Malen passer for Python utvikling både som applikasjon og som samling av Jupyter
notatbøker.

## Komme i gang

For å komme i gang med denne malen trenger man i hovedsak 3 programmer (og
resten blir ordnet gjennom Python-oppsettet, f.eks. Jupyter eller Quarto).

- [`git`](https://git-scm.com/) brukes for versjonskontroll
- [`uv`](https://docs.astral.sh/uv/getting-started/installation/) brukes for
prosjektstyring og håndtering av avhengigheter
- [`just`](https://just.systems/man/en/) brukes for å kjøre kommandoer som ofte
gjentas (`just` er en moderne versjon av `make`)

Når disse er installert (eller kanskje du har de fra før) kan vi klargjøre
prosjektet.

### Lag et nytt prosjekt basert på malen

Start med å [lage et nytt prosjekt med `python-mal-2025` som "template"](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template).

> [!TIP]
> Dette kan gjøres med [`gh`](https://cli.github.com/) verktøyet direkte:
>
> `gh repo create "navikt/<navn-på-nytt-prosjekt>" --internal --template "navikt/python-mal-2025" --clone`

Deretter går vi inn i prosjektet, dette kan vi enten gjøre med `code
<navn-på-nytt-prosjekt>` (hvis du bruker VSCode) eller naviger til
`<navn-på-nytt-prosjekt>` i din favoritt editor.

### Klargjør prosjektet

For å passe på at alt er på stell i prosjektet, og at vi har oppdatert alle
avhengigheter, skal vi nå initialisere prosjektet. Heldigvis kan vi automatisere
dette, så du trenger bare å kjøre (inne i prosjektet du lagde over i en
terminal):

```bash
just prepare
```

Dette vil installere `pre-commit` og oppdatere alle avhengigheter som hører til
denne malen.

---

Ditt nye prosjekt er nå klart til å utvikles! Resten av denne README-en vil
forklare hvilke avhengigheter vi har tatt med og hvorfor, men hvis du bare vil
komme i gang så trenger du ikke å lese mer.

## Hva må _du_ holde oppdatert

Det er et par elementer i malen som ikke enkelt lar seg automatisk oppdatere.
Disse avhengighetene burde _du_ ta en titt på når du oppretter prosjektet (og
fra tid til annen) for å passe på at de er relevante.

- [`.pre-commit-config.yaml`](./.pre-commit-config.yaml) inneholder referanser
`pre-commit` "repo"-er som må oppdateres for å holde tritt. Merk spesielt `ruff`
burde være samme versjon som prosjektet benytter i `uv.lock`.
- [`Dockerfile`](./Dockerfile) refererer til et `uv` bilde, dette burde holdes
oppdatert.

Utover disse som krever manuel oppdatering kan det være greit å oppdatere Python
avhengigheter. Dette må selvsagt testes før det legges til og det er mange
nyanser i hvordan vi kan oppdatere, så vi dokumenterer bare en generell
"oppdater alle avhengigheter" her:

```bash
uv lock --upgrade
```

## Tilgjengelige kommandoer

Vi har satt opp `just` som en del av malen for å automatisere en del gjentakende
kommandoer. Den enkleste måten å sjekke kommandoene er å kjøre:

```bash
just --list
```

I skrivendestund er følgende kommandoer støttet:

```txt
Available recipes:
    build   # Bygg prosjektet i Docker
    fix     # Fiks feil og formater kode med ruff
    lint    # Sjekk at alt koden ser bra ut og er klar for å legges til i git
    prepare # Klargjør prosjektet ved å installere `pre-commit` og oppdatere avhengigheter fra malen
    preview # Lag et preview med Quarto
```

## Hva er konfigurert i malen

### `pre-commit`

En av de viktigste tingene denne malen konfigurerer er
[`pre-commit`](https://pre-commit.com/). Dette er et system for å kjøre sjekker
når (men før lagring!) kjører `git commit`. Denne funksjonaliteten gjør at vi
kan passe på koden vår før vi lagrer noe til `git`.

> [!TIP]
> Vi har lagt ved en kommando for å manuelt kjøre `pre-commit`: `just lint`.

`pre-commit` er konfigurert i
[`.pre-commit-config.yaml`](./.pre-commit-config.yaml) og denne malen legger ved
et "standard" oppsett som sjekker litt diverse rundt filene vi har i `git`, den
sjekker at koden er formatert riktig (i følge `ruff`), den sjekker at typene ser
riktig ut (med `mypy`) og den vil også kjøre `nbstripout` for å fjerne
resultater i Jupyter notatbøker.

#### Feil i `mypy`

Hvis du opplever at `mypy` rapporterer feil eller manglende typer så er
problemet mest sannsynlig at `mypy` ikke har tilgang til pakkene du har
installert lokalt. Dette er en bakdel med `pre-commit` og `mypy` hvor
`pre-commit` oppretter et eget virtueltmiljø uavhengig av vårt miljø. For å
utbedre disse feilene kan man legge til manglende pakker i
[`.pre-commit-config.yaml`](./.pre-commit-config.yaml) under
`additional_dependencies` for `mypy`.

### Python oppsett

Malen legger også opp til et konservativt oppsett for Python ved å tvinge bruk
av `uv`. Vi har videre satt opp regel for hvilken Python versjon som skal
brukes, men med muligheter for lokale tilpasninger hvis nødvendige avhengigheter
ikke støtter nyeste Python.

For å endre hvilken Python versjon som brukes kan man endre i
[`.python-version`](./.python-version), malen legger opp til `3.14`, men
tillater ned til `3.12`. Eldre Python versjoner enn dette burde begrunnes godt
før bruk.

Vi har også lagt til et par avhengighetsgrupper for å gjøre det raskere å komme
i gang. Disse kan du se i [`pyproject.toml`](./pyproject.toml) under
`[dependency-groups]`. Disse gruppene må ikke brukes hvis ikke nødvendig, men er
lagt ved for å vise "best-practice" for Python med avhengigheter som er eksterne
for selve koden som skal kjøres.

Hvis du ønsker å kjøre notatbøker så kan du installere nødvendige avhengigheter
med:

```bash
uv sync --group notebooks
```

> [!TIP]
> Det kan også være lurt å legge til `notebooks` i `pyprojects.toml` under
> `[tool.uv.default-groups]` slik at denne avhengigheten alltid blir lastet
> lokalt.

For [Quarto](https://quarto.org/) så kan man gjøre samme som for Jupyter over,
bare bytt ut `notebooks` med `quarto`.

> [!TIP]
> For Quarto har vi lagt ved en egen kommando `just preview` som ordner å starte
> preview med `quarto-cli`. Dette gjør at man slipper å ha Quarto installert
> lokalt.

### `ruff`

For å passe på at koden vi skriver ser lik (følger samme regler for utseende) og
er strukturert på samme måte bruker vi [`ruff`](https://docs.astral.sh/ruff/).

> [!TIP]
> Vi har konfigurert en kommando for å kjøre `ruff`: `just fix`.

`ruff` er konfigurert i [`ruff.toml`](./ruff.toml) og vi har lagt ved et greit
oppsett som vi mener burde føre til bedre kode. Hvis du ønsker et strengere
regelsett så kan man endre under `[lint.select]`.

> [!NOTE]
> Vi har konfigurert at `ruff` skal sjekke at docstring følger Google sin
> standard. Det er ikke sikkert alle er enige i denne avgjørelsen og dette kan
> endres eller skrues av under `[lint.pydocstyle]`.

### Github Action

Denne malen prøver å sørge for at kodenkvaliteten er god før den legges til i
`git`. Men... det kan jo alltids skje feil så av den grunn har vi også lagt til
en Github Action i [`.github/workflows/ci.yml`](./.github/workflows/ci.yml).
Denne er satt opp til å kjøre tilsvarende sjekker som ved `just lint` (altså
kjører den `pre-commit`).

> [!IMPORTANT]
> Vi anbefaler at du konfigurerer Github prosjektet ditt til å ikke tillate push
> til `main` slik at endringer må gå gjennom pull request og godkjennes. Dette
> gjør at Github Action som vi har lagt til vil kjøres automatisk før koden går
> inn i `main`.
>
> Se hvordan du kan konfigurere dette på [github sin dokumentasjon](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule).

### Docker

Vi har også lagt ved et enkelt Docker oppsett for å bygge koden inn i et Docker
bildet. Dette bildet er satt opp til å bruke
[`distroless`](https://github.com/GoogleContainerTools/distroless) for å
minimere antall eksterne pakker som ligger i Docker, noe som igjen reduserer
antall sårbarheter.

> [!TIP]
> Vi har lagt ved en kommando for å bygge oppsettet: `just build`.

Bygging av Docker bildet er konfigurert med 2 filer, `Dockerfile` som beskriver
hvordan bilde skal settes opp og `.dockerignore` som beskriver hvilke filer og
mapper som _ikke_ skal være med i bildet.

---

## Henvendelser

Spørsmål knyttet til koden eller prosjektet kan stilles som issues her på
GitHub.

### For Nav-ansatte

Interne henvendelser kan sendes via Slack i kanalen
[`#data-science`](https://nav-it.slack.com/archives/C6WB7DXNC) eller i
[`#python`](https://nav-it.slack.com/archives/C01N19F99PV).
