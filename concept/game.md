# Kyphi – Grundlagen

Grundsätzliche Festlegungen, die für alle Teile des Spiels gelten.

## Genre

Ein klassisches **2D-Point-and-Click-Adventure**. Der Spieler steuert den Restaurator Martin Kessler, untersucht
Schauplätze, sammelt Gegenstände, kombiniert sie und führt Gespräche.

## Sprache

- **Spiel:** deutsch (Texte, Dialoge, Sprachausgabe).
- **Projekt:** Verzeichnisse, Dateinamen und Code englisch.

## Aufbau

Das Spiel erscheint in Teilen, je Teil ein Story-Dokument in diesem Ordner:

| Teil | Titel | Dokument |
|---|---|---|
| 1 | Der Zugang | [part_1_access.md](part_1_access.md) |
| 2 | Der Weg zur purpurnen Karte | [part_2_purple_card.md](part_2_purple_card.md) |

## Bildformat

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

## Regeln für die Geschichte

- **Alles bleibt plausibel.** Jedes Rätsel und jede Wendung muss sich in der realen Welt so zutragen können.
- **Keine Esoterik, nichts physikalisch Unmögliches.** Was übernatürlich wirkt, hat immer eine nachvollziehbare
  Erklärung.

## Regeln für Rätsel

- **Der Spieler soll selbst darauf kommen.** Martin benennt nur das Problem, nicht die Lösung.
- **Nicht schwer, aber auch nicht zu einfach:** ein Schritt, den man aus der Situation heraus erschließen kann,
  mit einem Gegenstand, den man schon kennt.
- **Echtes Wissen statt Zufall:** Die Lösung funktioniert so auch in der Wirklichkeit.
- **Vorbild (Teil 2, Antarktis):** Im Lager liegen Dutzende unbeschriftete Sicherungen, Martin sagt nur, dass er
  nicht weiß, welche er nehmen soll. Der Spieler muss selbst darauf kommen, die Sicherung im Kaffeeautomaten mit
  dem Messschieber zu messen, und kann dann die passende nehmen.
