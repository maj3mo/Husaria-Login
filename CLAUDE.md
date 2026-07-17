# StarLoco-Login — serwer logowania (Java 8)

Serwer autoryzacji Dofus Retro (StarLoco fork). Uwierzytelnia gracza i rozdziela go na
serwery świata. W stacku odpowiada usłudze `starloco_login` (port **450**).

> ⚠️ **Java 8** — `sourceCompatibility = 1.8` / `targetCompatibility = 1.8`, oficjalny
> obraz na OpenJDK 11 JRE. **Nie** JDK 21 (to jest serwer Game). Nie mieszaj wersji.

## Build

- System: **Gradle**, Java 8.
- Główna klasa: `org.starloco.locos.kernel.Main`.
- Artefakt: fat-jar `build/libs/login.jar` (task `jar`, zależności w środku).
- Build ze źródeł: `gradle jar`.
- **Własny multi-stage `Dockerfile`** (MDE-18): stage build `gradle:7.6.4-jdk8`
  (Temurin JDK 8 + git — `build.gradle` liczy `version` przez `git rev-parse`) → `gradle jar`;
  stage runtime `alpine` + `openjdk11-jre`. Build: `docker build -t husaria/login:src .`
  (context = ten katalog). W compose stack wciąż biega prebuilt `starloco/login:latest` —
  podmiana na build ze źródeł to integracja kroku 2 (compose `build:`), nie ten Dockerfile.

## Layout źródeł (`src/org/starloco/locos/`)

| Pakiet       | Rola |
|--------------|------|
| `kernel`     | bootstrap: `Main` (start, init DB), `Config` (loader properties), logging |
| `login`      | protokół logowania, handlery pakietów klienta |
| `exchange`   | komunikacja Login ↔ Game (kanał exchange, port 666) |
| `database`   | warstwa DB (HikariCP pooling), ładowanie danych serwerów |
| `object`     | encje domenowe (Server itd.) |
| `tool`       | narzędzia (filtrowanie pakietów) |

Kluczowe zależności: HikariCP 4.0.3, Jackson 2.12.6, JJWT 0.11.5, SLF4J+Logback, Apache Commons.

## Konfiguracja

- Plik `login.config.properties` (w stacku bind-mount z `docker/config/`).
- Porty: **450** (klient), **666** (exchange do Game).
- Baza: `starloco_login` w MariaDB (HikariCP).
- Sekwencja startu: wczytaj config → init DB → wczytaj dane serwerów → ExchangeServer(666)
  → LoginServer(450) → cykliczny update wolnych slotów co 30 s.

## Reguły dla zmian

- Trzymaj **Java 8** — nie używaj API z nowszych JDK.
- Zmiany protokołu (pod migrację 1.40) dotykają pakietu `login/` (handlery) — patrz EPIC 3
  (MDE-31). Trzymaj altitude: minimalne, spójne z istniejącym stylem.
- Po zmianach w kodzie serwer w stacku i tak biegnie z prebuilt obrazu — żeby testować
  własny build, potrzebny jest własny Dockerfile (MDE-18).
