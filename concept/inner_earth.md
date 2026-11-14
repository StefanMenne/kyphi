# Kyphi – Innenerde

## Hintergrund

Eine riesige Halle mit den rotierenden Scheiben der Sekte, tief unter der Erde, gespeist mit Unmengen an Strom aus
der Antarktis. Die Scheiben bilden ein Gyroskop und können die Erdrotation abbremsen. Die Sekte will den Tag
verlängern und so die Menschheit auslöschen.

## Rolle im Spiel

Martin macht hier aus seiner grauen Karte eine schwarze. Dafür braucht er drei Dinge:

| Was | Woher | Rätsel |
|---|---|---|
| Bindemittel (Walnussöl) | Küche | am Koch vorbei über den Essenslift hinausschmuggeln |
| Pigment (Kohlestaub) | Maschinenraum, Kohlebürsten | Weg durch den Luftschacht, an der Küche vorbei nur bei Dunst |
| Gewicht der schwarzen Karte | Essenslift, eingebaute Waage | Lift blockieren, Kantinengast bestellen lassen, im Vorbeifahren ablesen |

Die umgearbeitete Karte hat weiter den grauen Chip. Sie besteht nur dort, wo jemand hinsieht (und beim Koch die
Waage), nicht an Kartenlesern.

**Belohnung:** Das bessere Menü der schwarzen Karte enthält eine **Thermoskanne mit Tee** (Antarktis, Fernrohr).
Das **Salz** (Antarktis, falsche Fährte; ABC GmbH, Tonversuch) steht auf den Tischen der Kantine.

## Lage der Räume

Kantine, Hydroponik und Küche liegen als **Versorgungsblock** übereinander hinter der Rückwand des Bahnhofs. Der
Maschinenraum schließt auf Bahnsteigebene rechts an die Küche an, dahinter liegt die Scheibenhalle. Schnitt durch
den Block (links der Bahnhof):

```
 Bahnhof          Versorgungsblock                           Maschinenraum
               ┌──────────────────────────────┐
 Galerie ─Tür─▶│ Kantine      [Automat]       │
 Gitter ▒══════╪═════════════════╤═══════╗    │   oberer Lauf, unter der Decke der Hydroponik
               │               Klappe    ║    │
 Zwischen-─Tür▶│ Hydroponik   [Luke]     ║    │   Steigschacht in der hinteren rechten Ecke
 geschoss      ├─────────────────────────╫────┴──────────────┬──────────────────────┐
               │                         ╚═▒▒▒ Haube ▒▒▒═════╪════▒ Endgitter       │
 Bahnsteig─Tür▶│ Küche        [Luke]         Herd, Koch      │       Werkbank       │
               └─────────────────────────────────────────────┴──────────────────────┘
                              ▲ Liftschacht                    unterer Lauf, unter der Decke der Küche
```

Der Schnitt zeigt die Höhen und die Reihenfolge am Schacht. Auch der Maschinenraum hat seine Tür zum Bahnhof, sie
ist im Schnitt nicht eingezeichnet.

Feste Regeln, damit die Bilder zueinander passen:

- **Tür zum Bahnhof:** in allen vier Räumen in der **linken Seitenwand**.
- **Essenslift:** in Kantine, Hydroponik und Küche an derselben Stelle, **links an der Rückwand** nahe der Tür.
  Breitere Räume wachsen nur nach rechts.
- **Luftschacht:** überall derselbe **blassgelbe Blechkanal** (im Bergbau sind Lutten gelb), in den Räumen offen
  unter der Decke verlegt. So sieht der Spieler in jedem Raum, wo der Schacht verläuft.
- **Türleuchten:** über jeder Tür am Bahnhof eine kleine runde Leuchte, grün oder rot (Wetteralarm).

## Räume

| Raum | Code | Größe | Bildschirme | Martin (Rückwand / vorn) |
|---|---|---|---|---|
| Bahnhof | `inner_earth_station` | 2688×768 | 2, scrollt | klein, etwa 150 / 190 px |
| Kantine | `inner_earth_canteen` | 1344×768 | 1 | normal, etwa 300 / 500 px |
| Hydroponik | `inner_earth_hydroponics` | 1344×768 | 1 | normal |
| Küche | `inner_earth_kitchen` | 2048×768 | 1,5, scrollt | normal |
| Maschinenraum | `inner_earth_machine_room` | 2048×768 | 1,5, scrollt | normal |
| Luftschacht | `inner_earth_air_shaft` | 1344×768 | 1, Schnittbild | kriechend, etwa 200 px lang |
| Liftluke (Nahansicht) | `inner_earth_lift_hatch` | 1344×768 | Vollbild | nicht zu sehen |
| Schleifring (Nahansicht) | `inner_earth_slip_ring` | 1344×768 | Vollbild | nicht zu sehen |
| Scheibenhalle (noch nicht eingeordnet) | `inner_earth_disc_hall` | 4032×768 | 3, scrollt | sehr klein, etwa 70 px |
| Zeitkammer (noch nicht eingeordnet) | `inner_earth_time_chamber` | 1344×768 | 1 | normal |

Alle Räume sind 768 px hoch, auch der Bahnhof: Seine drei Ebenen sollen zugleich zu sehen sein, weil der Spieler
daran versteht, dass Küche, Hydroponik und Kantine übereinanderliegen. Bahnhof und Scheibenhalle sind breiter als
die 2048 px, die Qwen-Image-2512 in einem Bild erzeugt; wie sie entstehen, steht bei den Bildprompts. Die
englischen Bildprompts mit allen Zuständen stehen in `work/concept/inner_earth_prompts.md`.

### Bahnhof

Langgezogener, hoher Raum wie in der Antarktis, zwei Bildschirme breit. Hier kommt der Zug an. Die Rückwand ist
frontal zu sehen, davor über die ganze Breite der Bahnsteig. Weil drei Ebenen ins Bild müssen, ist Martin hier
klein. Von links nach rechts:

- **Vakuumröhre:** ein riesiges Stahlrohr aus Ringsegmenten, das links aus dem Fels kommt und an der Rückwand
  entlangläuft. In seiner Seite sitzt die Schleuse mit genietetem Rahmen und roten Warnleuchten wie in „Museum
  Bahn“; dahinter steht der Zug in der Röhre, eine Tür offen.
- **Versorgungsblock:** eine dreistöckige Fassade im Fels mit drei gleichen Türen genau übereinander:
  **Küche** (Bahnsteig), **Hydroponik** (Zwischengeschoss, Stahlbalkon), **Kantine** (Galerie).
- **Zweite Galerietür:** auf der Galerie links hinter der Treppe, wie die anderen mit grüner Leuchte. Sie ist
  verschlossen („Abgeschlossen.“) und vorerst ohne Funktion; Platz für später.
- **Treppe:** am linken Ende der Fassade, im Zickzack wie eine Feuertreppe und von der Seite zu sehen. Je
  Stockwerk zwei Läufe mit einem Zwischenpodest auf halber Höhe: Der erste Lauf steigt vom Bahnsteig nach rechts
  zum Podest, der zweite zurück nach links zum linken Ende des Balkons; vom Balkon geht es ebenso über ein zweites
  Podest zum linken Ende der Galerie. Die Galerie läuft über die ganze Breite der Fassade, der Balkon nur rechts
  der Treppe.
- **Luftschachtgitter:** auf der Galerie links neben der Kantinentür, in Bodenhöhe, mit gelbem Rahmen. Es lässt
  sich ohne Hilfsmittel öffnen (zwei Flügelmuttern).
- **Tür zum Maschinenraum:** auf Bahnsteigebene rechts vom Block, mit Hochspannungszeichen.
- **Wetterschleuse:** ganz rechts in der Rückwand, siehe unten.

**Laufflächen:** Martin läuft auf allen drei Ebenen und sichtbar die Treppe hinauf. Dafür braucht die Engine
mehrere Laufflächen je Raum, jede mit eigener Figurgröße, und Verbindungsstrecken dazwischen (bisher: eine
Lauffläche, Figurgröße linear nach der Fußhöhe, `game/room.gd`).

| Lauffläche | Form | Fußhöhe (Richtwert) | Martin |
|---|---|---|---|
| Bahnsteig | Fläche über die ganze Breite | y 610 hinten bis 768 vorn | 150 bis 190 px |
| Treppe unten | zwei Strecken mit Podest, erst nach rechts, dann nach links oben | y 610 → 510 → 410 | 150 px |
| Balkon | Streifen | y 410 | 150 px |
| Treppe oben | zwei Strecken mit Podest, erst nach rechts, dann nach links oben | y 410 → 310 → 210 | 150 px |
| Galerie | Streifen | y 210 | 150 px |

Ein Stockwerk ist damit 200 px hoch, eine Tür etwa 165 px. Klickt der Spieler auf eine andere Ebene, sucht die
Engine den Weg über die Treppenläufe. Die Geländer von Treppe, Balkon und Galerie liegen als Vordergrund-Ebenen
vor Martin.

### Wetterschleuse

Zwei große **Rolltore** hintereinander in der Rückwand des Bahnhofs, dazwischen eine Schleusenkammer, so tief wie
ein Transportwagen. Tor 1 liegt am Bahnhof, Tor 2 an der Anlage. Beide Tore rollen sich nach oben in einen Kasten
über der Öffnung auf.
Eines muss immer geschlossen sein, sonst entsteht ein **Wetterkurzschluss** (so heißt das im Bergbau wirklich): Die
Luft nimmt den kurzen Weg durch die offenen Tore und zieht nicht mehr durch die Räume ab.

Der Bahnhof steht unter leichtem Überdruck, die Anlage unter Unterdruck. Dieser Druckunterschied zieht die Luft
vom Bahnhof durch die Räume und den Luftschacht in den Maschinenraum und von dort in die Anlage. Stehen beide Tore
offen, bricht er zusammen.

- **Steuerkasten** links neben Tor 1: Taster „Tor 1“ und „Tor 2“, je eine Meldeleuchte „geschlossen“.
- **Endlage unten:** Die alte Steuerung hat unten keinen Endschalter. Sie hält ein Tor für geschlossen, sobald
  sein Antrieb beim Herunterfahren auf Widerstand stößt (Kraftabschaltung). Normalerweise ist das der Boden.
- **Manipulation:** Tor 1 öffnen (erlaubt, Tor 2 ist zu). Die **Malerleiter** (Teil 1) aufgeklappt in die
  Toröffnung stellen und Taster „Tor 1“ drücken: Das Tor fährt herunter, setzt auf der Leiter auf und bleibt
  stehen. Die Leuchte „Tor 1 geschlossen“ geht an, obwohl unter dem Tor ein mannshoher Spalt bleibt. Taster
  „Tor 2“: Das zweite Tor fährt auf. Martin: *„Die Leiter hält mehr aus als die Steuerung denkt.“*
- **Folge 1:** Der Abzug in der Küche zieht nicht mehr, der Dunst sammelt sich.
- **Folge 2:** Die Türsteuerung misst den Druckunterschied selbst und löst **Wetteralarm** aus: Alle Türleuchten
  werden rot, alle Türen am Bahnhof sind gesperrt, auch von innen. Es bleibt nur der Luftschacht, der keine Tür
  braucht. So ist die Schleuse immer nur kurz ganz offen, der Spieler öffnet sie nicht wahllos, und es gibt keine
  Abkürzungen (z. B. das Öl im Dunst einfach zur Küchentür hinaustragen).
- **Rückgängig:** Taster „Tor 2“: Tor 2 schließt. Dann zieht der Dunst ab, die Leuchten werden grün, und die
  Türen gehen wieder. Taster „Tor 1“: Tor 1 fährt hoch, Martin nimmt die Leiter wieder mit und schließt das Tor.
  Solange die Leiter unter Tor 1 steht, hat Martin sie nicht im Inventar.

### Kantine

Ein Bildschirm, heller Raum. Von links nach rechts:

- Tür zur Galerie (linke Wand).
- **Essensautomat:** kein Verkaufsautomat mit Fächern, sondern eine **Ausgabe aus Edelstahl**, in die Rückwand
  eingebaut. Sie ist die oberste Station des Essenslifts: dieselbe **Liftluke** mit Glasfenster wie in Hydroponik
  und Küche, aber **ohne Knöpfe**, davor eine kurze Tablettablage, daneben eine Säule mit Kartenschlitz und der
  defekten Menüanzeige (dunkel, Sprung im Glas). Die Luke öffnet nur der Automat; von Hand geht sie nicht auf.
- Direkt daneben ein kleiner Tisch: Hier sitzt der **Gast mit schwarzer Karte** und wartet. Er muss nur aufstehen
  und einen Schritt machen, um seine Karte einzustecken (zwei Einzelbilder genügen).
- Rechts zwei lange Tische, auf jedem ein Salzstreuer.

### Hydroponik

Ein Bildschirm, rosaviolettes Pflanzenlicht. Von links nach rechts:

- Tür zum Bahnhof (linke Wand) mit Drehknauf innen. Sie ist verschlossen, lässt sich aber **von innen
  entriegeln**. Beim ersten Mal kommt Martin von oben durch den Luftschacht, danach durch die Tür.
- **Liftluke** mit Glasfenster links an der Rückwand, daneben die drei Lift-Knöpfe. Hier stört niemand: Das ist
  Martins Platz, um den Lift zu bedienen und Dinge in der Kabine zu wiegen (Nahansicht).
- **Pikiertisch** in der Mitte der Rückwand: Hier mischt Martin die Farbe, streicht die Karte und lässt sie unter
  der Pflanzenlampe trocknen (Licht und Wärme lassen Öl wirklich schneller trocknen).
- Pflanzregale an Rückwand und rechter Wand.
- **Luftschacht:** Der gelbe Kanal kommt oben aus der linken Wand, läuft unter der Decke die Rückwand entlang und
  führt in der hinteren rechten Ecke senkrecht durch den Boden. An seiner Unterseite hängt eine Gitterklappe
  offen herab, direkt über dem ersten Pflanzregal. Dessen Seitenteil hat Sprossen: Martin klettert darüber hinab
  und wieder hinauf.

### Küche

Anderthalb Bildschirme. Die Liftluke links und der Herd rechts sind nie zugleich im Bild. Von links nach rechts:

- Tür zum Bahnhof (linke Wand).
- **Liftluke** links an der Rückwand, daneben dieselben drei Lift-Knöpfe wie in der Hydroponik, darüber die
  Anzeige „Nicht betriebsbereit“. Von hier lässt sich das Öl nicht wegschicken: Ist irgendwo eine andere Luke
  offen, öffnet Martin die Küchenluke zwar ohne Warnton, aber die Knöpfe tun nichts. Sind alle anderen Luken
  zu, ertönt beim Öffnen das Warnsignal, der Koch wird aufmerksam, und Martin kommt nicht weiter.
- **Kühlschrank**, raumhoch, rechts neben der Luke. Die Luke liegt am anderen Ende des Raums, anderthalb
  Bildschirme vom Herd entfernt; der Koch hat dort nur seine Töpfe im Blick und merkt nichts, solange kein
  Warnsignal ertönt. Die Tür sieht er.
- **Tafel** mit dem, was gerade gekocht wird.
- Arbeitsfläche, darüber ein Bord mit mehreren **Ölflaschen**. Nur trocknende Öle binden Farbe: Martin braucht das
  **Walnussöl**, Olivenöl trocknet nie. Leinöl steht nicht dabei. Er kann die Flasche nehmen, aber der Koch
  lässt ihn damit nicht aus der Küche.
- **Herd** mit Abzugshaube, davor der **Koch**. Der gelbe Kanal kommt links von der Haube aus der Decke (der
  Steigschacht aus der Hydroponik), läuft unter der Decke nach rechts in die Haube und weiter durch die rechte
  Wand zum Maschinenraum. Über dem Herd ist der Boden des Kanals ein offener Gitterrost.
- Zeigt der Lift „Nicht betriebsbereit“, schimpft der Koch („Das Ding spinnt, sobald irgendwo eine Klappe
  offen ist“). So lernt der Spieler die Liftregel.

### Maschinenraum

Anderthalb Bildschirme. Raum bei den Drehlagern und Antrieben der Scheiben; die Scheibenhalle liegt hinter der
Rückwand. Der Raum gehört zur Unterdruckseite, seine Tür zum Bahnhof ist deshalb verschlossen und lässt sich wie in
der Hydroponik **von innen entriegeln**. Beim ersten Mal kommt Martin nur durch den Luftschacht hinein, also nur
bei Dunst. Danach kann er die Wetterschleuse wieder in Ordnung bringen. Von links nach rechts:

- Tür zum Bahnhof (linke Wand) mit Drehknauf innen.
- **Luftschacht:** Der gelbe Kanal läuft oben an der Rückwand entlang und endet mit einem Gitter rechts neben
  der Werkbank. Martin steigt dort hinab und wieder hinauf.
- **Werkbank** mit Schublade (**Ersatzbürsten**) und einer Rolle **Schleifleinen**, daneben ein Abfalleimer mit
  gebrauchten Streifen.
- Drei **Scheibenantriebe** nebeneinander an der Rückwand: Aus der Wand kommt je ein Wellenende mit einem
  radgroßen kupfernen Schleifring, davor **Kohlebürsten** (Kupfergraphit), darum ein Blechgehäuse mit Tür und
  Sichtfenster. Der Abrieb der Bürsten ist ein echtes schwarzes Pigment. Der linke und der rechte Antrieb laufen,
  ihre Türen sind verriegelt.
- Der mittlere Antrieb steht. Am Gehäuse hängt ein Anhänger, zu klein, um ihn im Raum zu entziffern; mit
  „Lesen“ sagt Martin, was draufsteht: „Scheibe 3 – Revision“. Seine Tür geht auf, die Bürstenhalter sind leer. Er hat eine
  **Drehvorrichtung** mit Taster, die die Welle langsam dreht (Nahansicht).
- Vor und unter den Antrieben Gitterrost, unter jedem Ring eine Wanne mit altem Staub, verklebt mit Lagerfett.

### Noch nicht eingeordnet

- **Scheibenhalle (Galerie):** der große Raum hinter der Wetterschleuse, drei Bildschirme breit, Galerie rechts
  oben über den Scheiben, Martin sehr klein. Die Scheiben stehen aufrecht auf waagerechten Wellen in einer Reihe;
  ihre Wellenenden sind die Antriebe im Maschinenraum. Evtl. Zugang zur Zeitkammer. Ob Martin regulär durch die
  Schleuse hierher kommt (Tor 1 auf, hinein, Tor 1 zu, Tor 2 auf), ist offen.
- **Zeitkammer:** Foucault-Pendel, das die Erdrotation misst, und eine Anzeige, um wie viel der Tag schon
  verlängert wurde. Nur mit purpurner Karte zu öffnen, aber durch eine Glasscheibe einsehbar. Platz für eine
  spätere Geschichte mit der purpurnen Karte.

## Essenslift

Ein **Speiseaufzug**, kein Personenaufzug: Die Kabine ist ein Edelstahlkasten von etwa 60 × 60 × 70 cm, die Luke
sitzt in Brusthöhe und ist nicht größer als eine Backofentür. Martin passt nicht hinein. Der Lift verbindet
**Kantine (oben) ↔ Hydroponik (Mitte) ↔ Küche (unten)**. Auf dem Weg zwischen Kantine und Küche fährt die Kabine am
Glasfenster der Hydroponik vorbei. Der Kabinenboden ist eine Waage; ihre Anzeige (auf Zehntelgramm) sitzt als
Leiste unter der Kabinenöffnung und ist durch das Fenster und bei offener Luke zu lesen.

| Station | Luke | Bedienung |
|---|---|---|
| Kantine | Klapptür mit Glasfenster in der Ausgabe, ohne Knöpfe | nur der Automat |
| Hydroponik | Klapptür mit Glasfenster | drei Knöpfe (Symbole: Besteck, Blatt, Topf), Martin |
| Küche | Klapptür mit Glasfenster, links neben dem Kühlschrank | drei Knöpfe wie in der Hydroponik; der Koch, für Martin nutzlos (siehe Küche) |

Regeln:

- Der Lift fährt nur, wenn alle drei Luken geschlossen sind. Dann funktionieren die drei Knöpfe (Kantine,
  Hydroponik, Küche).
- Wird eine Luke geöffnet, während der Lift betriebsbereit ist, ertönt an dieser Luke ein dezentes, anhaltendes
  Warnsignal, und der ganze Lift ist gesperrt.
- An den anderen Stationen zeigt der Lift dann „Nicht betriebsbereit“. Öffnet man dort eine Luke, ertönt **kein**
  Warnton.
- Während der Fahrt sind alle Luken verriegelt. Eine vorbeifahrende Kabine lässt sich nicht anhalten; Martin
  kommt also nicht an die Karte eines anderen.
- Steht die Kabine an einer anderen Station, blickt man durch Fenster oder offene Luke in den leeren Schacht.

Ablauf einer Bestellung am Automaten in der Kantine:

1. Der Automat nimmt die Karte entgegen.
2. Er holt den Lift und wartet, bis er da ist.
3. Er räumt alles aus dem Lift.
4. Er stellt ein Tablett hinein und legt die Karte darauf.
5. Er schickt den Lift in die Küche.
6. Der Koch prüft die Karte mit einem Blick und ihr Gewicht an der Waage, bereitet das Essen zu, stellt es aufs
   Tablett und schickt den Lift in die Kantine.
7. Der Automat gibt Essen und Karte aus.

Mit der grauen Karte gibt es das Standardmenü, mit der schwarzen das bessere (mit Thermoskanne Tee).

## Luftschacht

Verbindet **Bahnhof ↔ Hydroponik ↔ Küche ↔ Maschinenraum**. Man kommt nur kriechend voran. Der Raum ist ein
**Schnittbild** von der Seite (ein Bildschirm): Der Fels ist eine dunkle Fläche, der Schacht darin ein gelber
Kanal in Form einer Stufe. Aus jeder Öffnung fällt das Licht des Raums dahinter, so erkennt der Spieler die
Ausgänge. Oberer Lauf, Steigschacht und unterer Lauf sind drei Verbindungsstrecken wie die Treppenläufe im
Bahnhof; Martin kriecht darin sichtbar. Von links nach rechts:

| Stelle | Im Schnittbild | Licht | Führt nach |
|---|---|---|---|
| Gitter Bahnhof | senkrechtes Gitter am linken Ende des oberen Laufs | kaltweiß | Bahnhof, Galerie |
| Klappe Hydroponik | Öffnung im Boden des oberen Laufs | rosaviolett | Hydroponik, über das Regal hinab |
| Steigschacht | senkrecht mit Sprossen, ein Stockwerk tief | – | verbindet oberen und unteren Lauf |
| Haubenrost | langer Gitterrost im Boden des unteren Laufs, gleich hinter dem Steigschacht | warmgelb, Dampf | kein Ausgang (fest, darunter der heiße Herd) |
| Endgitter | senkrechtes Gitter am rechten Ende des unteren Laufs | blauweißes Flackern | Maschinenraum, über die Werkbank hinab |

Am Haubenrost geht es nicht weiter zum Maschinenraum: Martin müsste über den offenen Rost kriechen, direkt über
dem Herd, an dem der Koch steht, und der würde ihn sehen. Es sei denn, in der Küche steht eine **Dunstwolke**
(Wetterschleuse manipuliert): Dann quillt Dampf durch den Rost, und Martin kriecht ungesehen hinüber.

## Rätsel

### Öl hinausschmuggeln

1. Hydroponik: Lift in die Küche schicken, dann die Liftluke öffnen (Warnton, den hier niemand hört). Der Lift ist
   gesperrt.
2. Küche: Walnussöl vom Bord nehmen. An der Tür hält der Koch Martin auf.
3. Küche: Liftluke öffnen. Kein Warnton, der Koch am Herd merkt nichts.
4. Walnussöl in die Kabine stellen, Luke schließen. Mehr tut Martin in der Küche nicht.
5. Hydroponik: Luke schließen, „Lift nach Hydroponik“ wählen, Luke öffnen, Öl herausnehmen.

### Gewicht der schwarzen Karte

1. Hydroponik: Liftluke öffnen, der Lift ist blockiert.
2. Kantine: den Gast dazu bringen, Essen zu bestellen (siehe unten). Der Automat nimmt seine Karte und wartet auf
   den Lift.
3. Hydroponik: Luke schließen. Der Lift fährt in die Kantine, wird beladen und fährt zur Küche.
4. Im Vorbeifahren durch das Glasfenster ablesen: **Tablett + schwarze Karte**.
5. Dasselbe noch einmal mit der eigenen grauen Karte: **Tablett + graue Karte**. Die Differenz (etwa 1 g) ist das,
   was der grauen Karte fehlt. Auf die zweite Messung muss der Spieler selbst kommen.

**Kantinengast:** Die Menüanzeige ist defekt, er wartet auf sein Lieblingsgericht und bestellt vorher nicht.
Martin liest in der Küche an der Tafel, was gekocht wird, und sagt es ihm. Das muss in den Dialogen stecken:

- Gast, erstes Gespräch: nennt das Gericht, auf das er wartet, und schimpft über die kaputte Anzeige („Ich
  bestelle doch nicht blind.“).
- Koch bzw. Tafel in der Küche: was es heute gibt.
- Gast, wenn Martin es ihm sagt: steht auf und steckt seine Karte in den Automaten.
- Sagt Martin es ihm, ohne es zu wissen, oder das Falsche, bleibt er sitzen.

### Dunst in der Küche

1. Bahnhof: Tor 1 der Wetterschleuse öffnen, die Leiter in die Öffnung stellen, Tor 1 auf die Leiter herunterfahren,
   Tor 2 öffnen. Alle Türen sind gesperrt, in der Küche sammelt sich Dunst.
2. Galerie: durch das Gitter in den Luftschacht, den Steigschacht hinab und über den Haubenrost an der Küche
   vorbei in den Maschinenraum.
3. Kohlestaub holen (siehe „Pigment abschleifen“), Tür von innen entriegeln. Sie bleibt gesperrt, solange der
   Wetteralarm anhält.
4. Durch den Schacht zurück zum Bahnhof, Tor 2 schließen. Der Dunst zieht ab, die Türen gehen wieder, auch die
   zum Maschinenraum. Tor 1 hochfahren und die Leiter wieder einpacken.

### Pigment abschleifen

Die Maschine schleift selbst. So werden neue Kohlebürsten wirklich „eingeschliffen“: Schleifleinen um den
Schleifring kleben und den Ring drehen, bis die Bürste dessen Rundung hat.

Geometrie in der Nahansicht: Der Ring ist von schräg vorn zu sehen, sodass seine breite Lauffläche sichtbar ist.
Der Bürstenhalter sitzt unten rechts am Ring („5 Uhr“), eine Handbreit über dem Gitterrost; was abfällt, fällt
gerade nach unten. Unter dem Rost steht die Wanne.

1. **Von Hand geht es nicht.** Mit dem Spatel bekommt Martin von einer Ersatzbürste nur Krümel, mit Schleifleinen
   kaum mehr: „So schleife ich bis morgen.“
2. **Der alte Staub in der Wanne taugt nicht.** Reichlich, aber fettig; Fett trocknet nicht, die Karte würde
   schmieren (derselbe Grund wie beim Ruß).
3. **Hinweis:** Die gebrauchten Streifen im Abfalleimer sind so lang wie der Ringumfang, in einer Spur schwarz und
   haben Klebebandreste an beiden Enden. Martin beschreibt nur, was er sieht.
4. **Lösung** am stehenden Antrieb:
   - Schleifleinen mit **Kreppband** um den Schleifring kleben, Körnung nach außen.
   - Eine Ersatzbürste in den Halter stecken; die Feder drückt sie auf den Ring.
   - Ein **Fundtütchen** unter den Halter auf den Rost legen.
   - Drehvorrichtung einschalten: Der Ring dreht sich, der Staub rieselt ins Tütchen.
5. **Ohne Tütchen** fällt der Staub durch den Rost in die fettige Wanne. Martin benennt das Problem, der Spieler
   wiederholt es. Ersatzbürsten gibt es genug (keine Sackgasse).

Die Einsicht für den Spieler: nicht selbst schleifen, sondern den Ring arbeiten lassen, und zwar den stehenden.

### Karte umarbeiten

Martins Arbeitsplatz ist der Pikiertisch in der Hydroponik.

1. Die rote **666** mit **Kreppband** abkleben. Ohne Nummer weist der Koch die Karte ab.
2. Kohlestaub und Walnussöl zu Farbe mischen und die Karte streichen.
3. **Gewicht:** Die fehlenden etwa 1 g kommen allein aus der Farbschicht (rund 50 µm auf beiden Seiten, das ist
   realistisch). Martin trägt Schicht um Schicht auf und wiegt in der Hydroponik in der Liftkabine nach, bis die
   Differenz stimmt.
4. **Trocknen:** dauert. Karte unter der Pflanzenlampe liegen lassen, anderswo weitermachen, später abholen (wie
   beim Akku).
5. In der Kantine mit der Karte bestellen: besseres Menü mit Thermoskanne.

### Falsche Fährte: Ruß

Der Spieler kennt Ruß aus Teil 1 und wird ihn als Pigment versuchen. Das ist erlaubt, scheitert aber aus einem
echten Grund:

- Lampenschwarz ist unter Malern als das am langsamsten trocknende Pigment bekannt; in Öl bleibt es wochenlang
  klebrig. Martin kann die Karte mit Ruß und Walnussöl schwärzen, aber sie schmiert, und der Koch weist sie ab.
  Martin wischt sie wieder sauber (keine Sackgasse).
- Der Kohlestaub ist aus einem echten Grund richtig: Kohlebürsten für hohe Ströme enthalten Kupfer, und Metalle
  beschleunigen das Trocknen von Öl. Schwerer ist er auch, was zum Gewicht passt.
- Martin benennt nach dem Fehlversuch nur das Problem (die Farbe trocknet nicht), nicht die Lösung.

## Stand im Spiel

- **Gebaut (14.11.2026):** Bahnhof (`game/rooms/inner_earth_station.gd`) mit Bahnsteig, Balkon, Galerie und den
  zwei Treppen als Laufflächen und Strecken; Wetterschleuse mit Rolltoren, Leiter und Wetteralarm (rote
  Türleuchten, alle Türen gesperrt). Hydroponik (`inner_earth_hydroponics.gd`) und die Nahansicht der Liftluke
  (`inner_earth_lift_hatch.gd`); der Essenslift als gemeinsames Modell (`inner_earth_lift.gd`, Klasse `Lift`)
  für Kantine und Küche. Gegenstände lassen sich in die Kabine legen und wiegen.
- **Luftschacht** (`inner_earth_air_shaft.gd`): Schnittbild ohne sichtbaren Martin (noch keine Kriech-Animation);
  eine Marke zeigt, wo er ist, jede Strecke ist eine Blende mit kurzem Text. Über den Haubenrost nur bei Dunst
  (Wetteralarm); zurück geht es immer. Am Endgitter geht es über die Werkbank in den Maschinenraum.
- **Maschinenraum** (`inner_earth_machine_room.gd`) mit der Nahansicht des stehenden Antriebs
  (`inner_earth_slip_ring.gd`): Pigment abschleifen wie oben, mit Fehlversuch ohne Tütchen. Neue Gegenstände
  Ersatzbürste, Schleifleinen, Fundtütchen mit Kohlestaub. Die Tür zum Bahnhof entriegelt Martin von innen; im
  Wetteralarm bleibt sie zu.
- **Fundtütchen:** Martin hat aus der Werkstatt einen ganzen Stapel. Das Haar im Altarraum kommt in ein eigenes
  Tütchen, die leeren bleiben im Inventar (für den Kohlestaub).
- **Küche** (`inner_earth_kitchen.gd`): Koch als einfache Figur (`assets/characters/cook/`, drei Bilder), Anzeige
  „Nicht betriebsbereit“ und Tafel als Schrift im Spiel, Walnussöl als Gegenstand. Öl hinausschmuggeln wie oben;
  der Koch nimmt die Flasche an der Tür ab, die Küchenluke piept bei betriebsbereitem Lift, und er schickt Martin
  weg. Im Wetteralarm Dunst über Herd und Haube, der Koch verschwindet darin.
- **Kantine** (`inner_earth_canteen.gd`): Gast als einfache Figur mit zwei Haltungen (sitzend mit eigenem Stuhl,
  stehend am Kartenschlitz; `assets/characters/guest/`). Er bestellt, wenn Martin ihm das Gericht von der Tafel
  nennt (auch mehrmals). Bestellungen laufen über das Liftmodell (`Lift.order`, `Lift.run_order`): Ist eine Luke
  offen, wartet der Automat; wird die Luke in der Hydroponik geschlossen, fährt die Kabine am Fenster vorbei, die
  Anzeige zeigt Tablett und Karte (Tablett 412,3 g: schwarz 418,9 g, grau 417,9 g). Martins Karte: grau gibt das
  Standardmenü, schwarz mit richtigem Gewicht das bessere mit Thermoskanne, falsches Gewicht weist der Koch ab.
  Was in der Kabine lag, stellt der Automat auf die Ablage (Martin holt es an der Ausgabe). Salzstreuer zum
  Mitnehmen.
- Damit ist die ganze Innenerde (ohne Scheibenhalle und Zeitkammer) spielbar.
- **Bahnhof, Geländer:** Vordergrund-Ebene `railings`, liegt vor Martin, solange er nicht auf dem Bahnsteig ist.
- **Fehlt:** Dunst in der Küche selbst (kommt mit der Küche).
- **Karte umarbeiten** (Hydroponik, Pikiertisch): Walnussöl und Kohlestaub (oder Ruß, falsche Fährte) auf dem
  Tisch zu Farbe anrühren; Karte mit Pinsel und Kreppband (666 abkleben) streichen, sie trocknet unter der Lampe
  und ist fertig, wenn Martin den Raum verlassen hat und wiederkommt. Ruß bleibt klebrig, Martin wischt ab. Jede
  Schicht Kohlefarbe wiegt 0,25 g; die graue Karte 5,6 g, die schwarze 6,6 g, also vier Schichten (`Lift.GREY_CARD`,
  `BLACK_CARD`, `PAINT_LAYER`). Zu viel Farbe schabt Martin mit dem Spatel wieder ab (Spatel + Karte). Die
  gestrichene Karte öffnet weiter die Stahltür im Museum (grauer Chip).
- **Karte grau:** Hollmanns Karte ist jetzt auch im Spiel grau (Text); Icon und die zwei vertonten Sätze („Eine
  graue Karte …“ im Inventar und im Depot) müssen noch neu entstehen, das alte schwarze Icon ist jetzt das der
  gestrichenen Karte.

## Offen

- **Engine:** Mehrere Laufflächen je Raum mit eigener Figurgröße, Verbindungsstrecken und Wegsuche sind gebaut
  (`areas`/`links` in `game/rooms/<id>.json`, `Room.route`, Test `tests/walk_areas.tscn`). Offen: Martin läuft
  Treppen mit dem normalen Laufzyklus (keine Treppen- oder Kletteranimation), hält an jedem Podest kurz an;
  Geländer als Vordergrund-Ebenen vor Martin; im Layout-Editor lassen sich Strecken noch nicht bearbeiten
  (nur Flächen, Tab wechselt die Fläche).
- **Kriechen im Luftschacht:** Martin hat noch keine Kriech-Animation (Kriechzyklus, dazu Klettern im
  Steigschacht oder dort eine Blende).
- **Gericht des Tages:** vorläufig „Linseneintopf mit Würstchen“ (Konstante `DISH` in der Küche). Die Tafel bleibt
  im Hintergrundbild leer, das Spiel setzt die Schrift.

## Ideen

- **Gitter am Luftschacht:** evtl. nur mit Werkzeug zu öffnen; nicht mit dem Akkuschrauber, dessen Akku für die
  Antarktis gebraucht wird (Spatel oder Flügelmuttern).
- **Untere Sohle mit Grubenwehrstation:** Treppe eine Ebene tiefer, Station der Grubenwehr (Erste Hilfe, Tragen,
  Atemschutzgeräte). Der Lüfter dieser Ebene steht, die Lutte hängt abgekoppelt an der Wand.
- **Wohnmodul** mit Spind.

## Abhängigkeiten zu anderen Orten

- Thermoskanne mit heißem Tee (Antarktis, Fernrohr auftauen): besseres Menü.
- Salz (Antarktis, falsche Fährte am Tor; ABC GmbH, Tonversuch): Tische der Kantine.
- Kreppband aus Teil 1: 666 abkleben, Schleifleinen am Schleifring.
- Malerleiter aus Teil 1: Tor 1 der Wetterschleuse blockieren.
- Fundtütchen aus Teil 1: Kohlestaub auffangen.

## Verworfen

- Küche und Kantine nur durch den Luftschacht sichtbar, nie betretbar.
- Koch mit drei zurückgeschickten Tabletts ablenken.
- Wetterschleuse als eigener Gang: jetzt die beiden Tore im Bahnhof.
- Schiebetore mit Endschalter, den Martin mit Kreppband festklebt (mit Nahansicht): jetzt Rolltore und die Leiter.
- Essensautomat als Verkaufsautomat mit Fächern, Essenslift als Personenaufzug, Zug auf offenem Gleis ohne
  Vakuumröhre, Luftschacht als Innenansicht mit Rohren (erste Bildentwürfe).
