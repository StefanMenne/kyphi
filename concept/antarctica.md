# Kyphi – Antarktis

Stand: 07.11.2026. Weitgehend gebaut und spielbar (Räume in `game/rooms/antarctica_*.gd`). Gegenstände aus den
noch nicht gebauten Orten gibt es bisher nur über das Cheatmenü (F10 → „Gegenstände für die Antarktis geben“).

Rolle in Teil 2: Hier holt Martin die Medaille des erfrorenen Novizen 412, das **Pfand** für Prüfung 2 (siehe
`work/concept/story.md`). Nebenbei findet er den Glykol-Kanister für Prüfung 3 und Hinweis 1 auf die Sabotage.

## Räume

| Raum | Code | Inhalt |
|---|---|---|
| Bahnsteig | `antarctica_platform` | Großer Raum über mehrere Bildschirmbreiten. Links der Zug in der Schleuse, Türen zu Kontrollraum und Schleuse, rechts die Treppe zur Außenbeobachtung. |
| Kontrollraum | `antarctica_control_room` | Pjotr, sein Kaffeeautomat mit Sicherung F7, Sicherungskasten, Schalttafel der Leiterheizung |
| Schleuse | `antarctica_airlock` | Spind mit XXL-Kälteanzug, Außentor, Wartungsschrank mit Glykol-Kanister |
| Außenbeobachtung | `antarctica_observation` | Glaskuppel, eingefrorenes Fernrohr, Windschreiber (Kulisse) |
| Antenne | `antarctica_antenna` | Draußen, ein Bildschirm: Fuß der großen Antenne, 412s Steigschutzläufer im Schnee |

## Figur

**Pjotr**, Techniker: „Technik, Heizung, Kaffee. Das Letzte ist das Wichtigste.“ Erklärt, dass 412 noch oben
liegt, weil seit dem Unfall die Leiterheizung aus ist und niemand weiß, wie man sie einstellt. Bürgt sofort für
Martin („Klar bürge ich!“), hat aber nur eine schwarze Karte; beim Notar in Area 52 zählt das nicht.

## Rätsel

### Schleuse: hinauskommen

1. **Anzug:** Im Spind hängt nur ein XXL-Anzug. Er bleibt immer im Spind: Martin zieht ihn nur draußen an.
2. **Anzugheizung:** Martin benutzt den Akkuschrauber (Teil 1) mit dem Anzug und nimmt den Akku heraus. Er passt
   ins Akkufach, ist aber leer. Laden: Werkstatt der ABC GmbH (gleiches Akkusystem), einstecken, anderswo
   weitermachen, später abholen.
3. **Tor festgefroren:** Salz (Innenerde) wirkt nur bis −21 °C, draußen sind es −68 °C. Glykol wird bei der Kälte
   „Gelee“. Die Torheizung ist aus, weil **Sicherung F7** fehlt.
4. **Sicherung:** Pjotr hat F7 in seinen Kaffeeautomaten gesteckt und steckt sie sofort zurück, wenn Martin sie
   nimmt. Der Spieler muss selbst darauf kommen, sie mit dem **Messschieber** zu messen (10 × 38 mm). Im
   Materiallager der ABC GmbH liegen Dutzende unbeschriftete Sicherungen; erst mit dem Maß nimmt Martin die richtige.
   Vorbild für die Rätsel im Spiel.
5. **Nebenbei:** Glykol-Kanister („Frostschutz (Glykol) – Pistenraupe“) aus dem Wartungsschrank, gebraucht erst in
   Stollen 7 der ABC GmbH (Prüfung 3).

### Außenbeobachtung: Wind ablesen

- Das Fernrohr ist eingefroren und wird mit dem **Tee aus der Thermoskanne** (Innenerde) aufgetaut.
- Fernrohr-Ansicht als Vollbild mit **Hoch**, **Runter** und **Verlassen**: Ebene 1 bis 6 mit je einer
  **Windfahne** (kein Wind, normaler Wind, Sturm; einmal je Spiel zufällig festgelegt, jede Stufe kommt vor) und die
  oberste Ebene mit dem erfrorenen **Novizen 412**.
- Der Spieler muss sich die sechs Windstufen merken oder aufschreiben.

### Kontrollraum: Leiterheizung

- Schalttafel (Vollbild) mit **6 Drehschaltern**, je Ebene **Aus, Low, High**.
- Richtig: **kein Wind = Aus, normaler Wind = Low, Sturm = High**.
- Die Sicherung trägt genau die Last der richtigen Einstellung (Low = 1, High = 2). Mehr, und sie fliegt raus und
  alle Schalter springen auf Aus. Ob die Einstellung stimmt, zeigt sich erst beim Aufstieg.

### Antenne: Aufstieg

- Die unteren drei Meter der Turmleiter fehlen: Martin stellt die **Malerleiter** (Teil 1) an.
- Im Schnee liegt **412s Steigschutzläufer** mit gebrochener Feder.
- Aufstieg im Dunkeln, danach berichtet Martin die erste nicht erfüllte Bedingung:
  1. kein Läufer: Martin steigt gar nicht erst hinauf;
  2. nur 412s Läufer: „Der Läufer greift nicht …“ → in der Werkstatt der ABC GmbH gegen einen neuen tauschen
     („Neu nur gegen Alt“), der Werkmeister erkennt: Feder angesägt (**Sabotage-Hinweis 1**);
  3. Anzug nicht abgebunden: „Der riesige Anzug ist wie ein Segel.“ → **Gewebeband** mit dem Anzug benutzen
     (Ärmel, Hüfte, Beine), das Band bleibt am Anzug;
  4. Heizung falsch: „Ebene x ist komplett zugefroren.“ (x = unterste falsche Ebene, nur ein Hinweis);
  5. alles richtig: Martin bringt die **Medaille** von 412 mit und sagt Pjotr Bescheid, dass man ihn holen kann.

## Gegenstände

| Gegenstand | Woher | Wofür | Stand |
|---|---|---|---|
| Akku (leer → geladen) | Akkuschrauber aus Teil 1 | Anzugheizung | Laden in der ABC GmbH fehlt |
| Sicherung F7 | Materiallager ABC GmbH | Sicherungskasten → Torheizung | Materiallager fehlt |
| Thermoskanne mit Tee | Innenerde | Fernrohr auftauen | Innenerde fehlt |
| Salz | Kantine Innenerde | falsche Fährte am Tor | Fundort fehlt |
| Gewebeband | offen | Anzug abbinden | Fundort fehlt |
| Steigschutzläufer, kaputt | Fuß der Antenne | Tausch in der ABC-Werkstatt | eingebaut |
| Steigschutzläufer, neu | Werkstatt ABC GmbH | Aufstieg | Werkstatt fehlt |
| Glykol-Kanister | Wartungsschrank Schleuse | Stollen 7, ABC GmbH | eingebaut |
| Medaille von 412 (gesprungen) | Aufstieg | Reparatur in Innenerde, dann Pfand in Area 52 | eingebaut |
| Malerleiter, Messschieber | Teil 1 | Antenne, Sicherung | eingebaut |

## Offen

- **Gewebeband:** Fundort fehlt (Teil 1 oder Werkstatt der ABC GmbH).
- **Akku:** Dass er geladen werden muss, bleibt; als Rätsel ist er noch zu einfach.
- **Kondenswasser:** Die eiskalte Medaille beschlägt im Warmen, dann hält das Komposit nicht. Martin lässt sie in
  der **Fundtüte** (Teil 1) angleichen. Wann und wo das passiert, ist noch nicht festgelegt und nicht eingebaut.
- **Bergung von 412:** übernimmt die Station, nachdem Martin oben war; im Spiel nur erwähnt.

## Ideen für später

### Medaille oben auf der Antenne

Bisher nimmt Martin die Medaille beim erfolgreichen Aufstieg einfach mit (im Dunkeln, nur als Bericht). Idee für
ein eigenes kleines Rätsel:

- Die Medaille ist an ihrer Kette an 412 bzw. auf dem Gitterrost der Plattform festgefroren.
- Bei −68 °C ist Eis spröde wie Glas: Ein gezielter Schlag mit dem **Spatel** bricht es auf. Dann fällt die
  Medaille aber durch den Rost.
- **Lösung:** die Kette mit der **Pinzette** halten und mit dem Spatel schlagen. Kein Auftauen nötig.

Umsetzung entweder als weitere Bedingung beim Aufstieg („Die Medaille ist festgefroren. Wenn ich das Eis
wegschlage, fällt sie durch den Rost.“) oder als eigener Bildschirm oben auf der Plattform mit Nahansicht von 412
(damit ließe sich auch das bisherige Bild der Plattform ersetzen: 412 ist dort zu groß, die Plattform sieht noch
nicht gut aus).

### Aufstieg zeigen

Statt nur abzudunkeln, den Aufstieg kurz zeigen (Video oder Bildfolge von unten), vor allem beim Scheitern im Wind.
