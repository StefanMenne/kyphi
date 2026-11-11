# Kyphi

Ein klassisches **2D-Point-and-Click-Adventure**. Der Spieler steuert den Restaurator Martin Kessler, untersucht
Schauplätze, sammelt Gegenstände, kombiniert sie und führt Gespräche. 

## Story und Entwicklungsstand

Das Spiel besteht aus 5 Arealen (Änderungen möglich), verbunden durch einen Hochgeschwindigkeitszug:

- **Museum** (Teil 1, „Der Zugang“): fertig und spielbar; Änderungen sind möglich, um andere Orte anzubinden.
- **Antarktis:** weitgehend fertig, aber mit offenen Fäden, z. B. Gegenständen, die noch nicht platziert sind.
- **ABC GmbH:** bisher nur Ideen.
- **Innenerde:** bisher nur Ideen.
- **Area 52:** bisher nur Ideen; enthält einen abgegrenzten Bereich, der nur mit der purpurnen Karte betreten
  werden kann.

Das Areal Museum bildet den ersten Teil. Am Ende von Teil 1 hat der Spieler den verborgenen Zugang zu einem unterirdischen Tunnelsystem gefunden. Eine mächtige **Sekte** hat es gebaut und nutzt es im Verborgenen. Alle Areale sind dann zugänglich bis auf den unterirdischen
Teil von Area 52, der den dritten abschließenden Teil bildet.
Die Geschichte darf lustig sein, soll aber vor allem spannend bleiben und überraschende Wendungen bieten.
Harte Grenzen zwischen den Teilen gibt es nicht. Das Museum bleibt jederzeit betretbar.

Alles Weitere zur Geschichte und zu den Rätseln steht in den Konzeptdateien, eine je Ort. Einen etwas genaueren 
Überblick und Ideen für den Fortgang der Story befindet sich in `work/concept/story.md`. 
Gebaute Orte liegen im Spiel-Repo (`concept/museum.md`, `concept/antarctica.md`),
die übrigen sind grobe Ideen in `work/concept/` (`abc_gmbh.md`, `inner_earth.md`, `area_52.md`, `part_3.md`;
`items.md` beschreibt die Gegenstände über alle Orte hinweg). Bei Bedarf lesen und anpassen, sobald sich der
Spielablauf ändert. Wird ein Ort gebaut, wandert seine Datei nach `concept/`.

## Martin Kessler (Spielfigur)

Martin ist Restaurator, Mitte 30, gründlich und trocken-ironisch. Seit drei Wochen restauriert er einen altägyptischen Opferaltar im für die Öffentlichkeit gesperrten Flügel des Museums.

## Technische Regeln

### Bildformat

- **Referenzauflösung: 1344×864.** Davon sind **1344×768 das Spielbild**, darunter liegt die Inventarleiste mit
  96 px. Auf anderen Bildschirmen skaliert Godot das Ganze mit gleichem Seitenverhältnis und füllt den Rest mit
  Schwarz (`stretch/mode=canvas_items`, `aspect=keep`).
- **Raumhintergründe sind 768 px hoch**, damit sie im Spiel 1:1 erscheinen. Räume ohne Scrollen sind 1344×768,
  scrollende Räume sind breiter (Vielfache von 64, z. B. 2048×768 oder 2688×768).
- **Videos (Zwischensequenzen) sind 1344×768** und laufen im Spielbild. Zeigt ein Video einen Raum, sind seine
  Schlüsselbilder genau der Ausschnitt, den der Spieler in diesem Moment sieht, damit Raum und Video nahtlos
  ineinander übergehen.
- **Vollbild-Ansichten** (Nahansichten, Tafeln, Fernrohr) sind 1344×768.
- Abweichende Größen nur für Teilbilder, die in eine Szene eingesetzt werden (Sprites, Edit-Ausschnitte), und für
  Icons (Gegenstände 512×512, im Inventar 128×128; Verben 96×96).

### Sonstiges

- Das Spiel ist deutsch (Texte, Dialoge, Sprachausgabe); Verzeichnisse, Dateinamen und Code sind englisch.

## Assets (Sprites, Animationen usw.)

- Assets werden mit den Tools des `gb10-assets`-Plugins erzeugt. Fremdmaterial nur mit dokumentierter Lizenz.
- `work/` ist ein eigenes privates Repo (`git@github.com:StefanMenne/kyphi-assets.git`), getrennt pullen,
  committen und pushen (`git -C work …`). Fertige Assets, die das Spiel tatsächlich verwendet, liegen in `assets/`.
- Verzeichnisse in `work/`:
  - `work/tmp/`: neue, noch nicht ausgewählte Ergebnisse, z. B. Varianten während der Entwicklung.
  - `work/old/`: verworfene Ergebnisse.
  - `work/cache/`: Zwischenergebnisse, die sich aus `assets/provenance.json`, `work/assets/` und `work/scripts/`
    wieder erzeugen lassen.
  - `work/assets/`: alles, was für die Erzeugung der fertigen Assets nötig ist, sich aber **nicht** deterministisch
    erzeugen lässt, z. B. von Hand bearbeitete Bilder, Konzeptbilder ohne festgehaltenen Prompt,
    Referenzaufnahmen. Die Gliederung spiegelt `assets/` (z. B. `work/assets/items/ladder/`).
  - `work/scripts/`: Skripte für die deterministischen lokalen Schritte (Freistellen, Zuschneiden, Sprite-Sheets).
  - `work/tmp/`, `work/old/` und `work/cache/` werden nicht committet.
- `work/characters/<figur>/` (martin, martin_suit): je Figurensatz `gen.json` (alle Schritte, Schema
  wie `provenance.json`), `src/` (Bildauswahl, Arbeitsstand, eigene Skripte; committet) und `gen/`
  (Zwischenergebnisse, nicht committet). Diese Figuren stehen nicht in `provenance.json`. Ansehen und Quellen
  ändern mit `work/run.sh anim` (Werkzeuge in `work/tools/`, nicht Teil des Spiels).
- `assets/provenance.json` beschreibt für jedes fertige Asset, wie es entsteht: im Idealfall eine Kette
  deterministischer Schritte (gb10-assets-Jobs mit vollständiger Anfrage und Seed, lokale Skripte mit Parametern),
  deren Eingaben andere Schritte oder Dateien in `work/assets/` sind. Ziel: Alle Assets lassen sich rekonstruieren,
  und es werden so wenige Zwischenergebnisse wie möglich gespeichert. Das Plugin liefert bei gleicher Anfrage und
  gleichem Seed pixelgleiche Ergebnisse (bei Videos die dekodierten Frames, nicht die MP4-Datei).
- `assets/provenance_old.json`: Herkunft des Altbestands, bevor die Rekonstruierbarkeit systematisch umgesetzt
  wurde. Einträge wandern nach `provenance.json`, sobald ein Asset neu aufgebaut wird.
- Ablauf, Schema von `provenance.json` und Erfahrungen zur Erzeugung stehen in `work/assets.md`.
