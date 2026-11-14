# Kyphi – ABC GmbH

## Hintergrund

Ehemals zivile Firma, baut für die Sekte Tunnel und unterirdische Anlagen. Die Antarktis erwartet von hier
Akku-Ladung, Sicherung, neuen Steigschutzläufer (mit „Feder angesägt“) und das Gewebeband und liefert den
Glykol-Kanister.

Die Fäden aus Teil 1 bleiben unberührt (Tonband-Stimmen für Teil 3, Lohnbuchhalter als eigene Figur, Hollmann
hat die Karte gestohlen, Brenner kennt ihn nur von früher).

## Story in Kürze: „Unfallfrei seit 4.012 Tagen“

Ein deutscher Mittelständler mit Stechuhr und Materialschein, der für eine Weltuntergangssekte baut. Vor elf
Tagen ist Stollen 7 eingebrochen. Betriebsleiter Brenner (purpur) ist eingefahren, um den Hauer Mirko zu
holen; ein zweiter Bruch hat beide eingeschlossen, 58 m unter der Maschinenhalle. Sie werden über eine armdicke
Versorgungsbohrung versorgt. Die große Rettungsbohrung frisst sich bei 41 m fest. Offiziell ist das kein Unfall,
sondern ein „Ereignis“. Martin bringt die Bohrung in Gang, fährt als Einziger, der in die Rettungskapsel passt,
selbst ein, befreit Mirko und entdeckt, dass der Einsturz gesprengt war.

Figuren: Kowalke (Werkmeister), Siebert (Lohnbuchhalter), Brenner (zuerst nur Stimme am
Grubentelefon), Mirko (unten). Running Gag: Niemand weiß mehr, wofür „ABC“ steht.

## Was Martin mitbringt

| Gegenstand | Woher |
|---|---|
| Messschieber, Fundtütchen, übriges Werkzeug | Teil 1 |
| Akku (leer) | Antarktis, aus dem Akkuschrauber genommen |
| Steigschutzläufer, kaputt | Antarktis, Fuß der Antenne |
| Maß der Sicherung (10 × 38 mm, Wissen) | Antarktis, Kaffeeautomat mit Messschieber gemessen |
| Glykol-Kanister | Antarktis, Wartungsschrank der Schleuse |
| Salzstreuer | Innenerde, Kantinentisch |

## Lage der Räume

```
                  ┌───────────────┐      ┌───────────────┐
                  │ Materiallager │      │ Brenners Büro │
                  └───────▲───────┘      └───────▲───────┘
                  ┌───────┴───────┐      ┌───────┴───────┐
                  │ Werkstatt     │      │ Lohnbüro      │
                  └───────▲───────┘      └───────▲───────┘
 Zug ══ Schleuse ═════════╧══════ Werkstor ══════╧═════ Tor ══▶ Maschinenhalle
                                                                 │ Rettungsbohrung und
                                                                 │ Versorgungsbohrung, 58 m
                                                                 ▼
                                                          Kammer in Stollen 7
```

Feste Regeln, damit die Bilder zueinander passen:

- **Türen:** Die Tür zurück in Richtung Werkstor liegt in jedem Raum in der **linken Seitenwand**, die Tür weiter
  (Materiallager, Betriebsleitung) in der **rechten Seitenwand**. In der Maschinenhalle ist es das Tor in der
  linken Seitenwand.
- **Aussehen:** ein deutscher Betrieb der Siebzigerjahre, in den Berg gebaut. Werkstatt, Lager und Halle haben
  cremeweiße Wände über einem dunkelgrünen Ölsockel, Emaille-Hängelampen und dunkelgrüne Stahltüren mit kleinem
  Drahtglasfenster; die Büros sind holzgetäfelt, die Tür zur Betriebsleitung ist mit Leder gepolstert. Am
  Werkstor steht eine Klinkerfassade vor dem Fels. Dunkelgrün ist die Farbe des Betriebs (Türen, Tor,
  Bohranlage), Gelb die der Maschinen unter Tage (Bohrwagen).
- **Schrift:** Im Bild steht nur große Schrift („ABC GmbH“ über dem Tor, „HFC“ auf dem Fass, die Tafel in der
  Nahansicht). Alles Kleine (Anhänger, Säcke, Listen, Einträge) liest Martin vor oder setzt das Spiel.

## Räume

| Raum | Code | Größe | Bildschirme | Martin (Rückwand / vorn) |
|---|---|---|---|---|
| Werkstor (Bahnhof) | `abc_station` | 2688×768 | 2, scrollt | klein, etwa 150 / 190 px |
| Werkstatt | `abc_workshop` | 2048×768 | 1,5, scrollt | normal, etwa 300 / 500 px |
| Materiallager | `abc_store` | 1344×768 | 1 | normal |
| Lohnbüro | `abc_payroll_office` | 1344×768 | 1 | normal |
| Maschinenhalle | `abc_machine_hall` | 2688×768 | 2, scrollt | mittel, etwa 230 / 320 px |
| Kammer in Stollen 7 | `abc_chamber` | 2048×768 | 1,5, scrollt | normal |
| Brenners Büro | `abc_manager_office` | 1344×768 | 1 | normal |
| Tafel „Unfallfrei“ (Nahansicht) | `abc_safety_board` | 1344×768 | Vollbild | nicht zu sehen |
| Sprengplan (Nahansicht) | `abc_blast_plan` | 1344×768 | Vollbild | nicht zu sehen |
| Sprengstoffbuch (Nahansicht) | `abc_ledger` | 1344×768 | Vollbild | nicht zu sehen |
| Bohrwagen, Wartungsklappe (Nahansicht) | `abc_rig_panel` | 1344×768 | Vollbild | nicht zu sehen |

Die englischen Raumbeschreibungen und Bildprompts mit allen Zuständen stehen in
`work/concept/abc_gmbh_prompts.md`.

## Räume: was dort ist und was dort geschieht

### 1. Werkstor (Bahnhof)

Zwei Bildschirme breit, hoher Felsraum wie die anderen Bahnhöfe, Martin ist klein. Die Rückwand ist frontal zu
sehen, davor über die ganze Breite der Bahnsteig. Von links nach rechts:

- **Vakuumröhre** mit Schleuse und Zug wie in der Innenerde (linkes Drittel).
- **Sprengstofflager:** niedriger Betonbunker vor dem Fels mit schwerer Stahltür und Warnraute. Rechts neben der
  Tür die Ausgabeluke in Brusthöhe, darunter ein schmales Stahlbord mit dem Sprengstoffbuch an der Kette.
- **Klinkerfassade** bis zur Decke (rechte Hälfte): Stechuhr zwischen zwei Kartenregalen, Schwarzes Brett mit dem
  Sprengplan, Tür zur Werkstatt, Tür zum Lohnbüro. Über den beiden Türen hängt groß die Tafel „Unfallfrei“.
- **Werkstor:** ganz rechts ein breites, dunkelgrünes Schiebetor, doppelt so hoch wie eine Tür, mit Schlupftür;
  darüber in Metallbuchstaben „ABC GmbH“. Das Tor bleibt zu, Martin geht durch die Schlupftür in die
  Maschinenhalle.

| Objekt | Aktion |
|---|---|
| Zug in der Schleuse | Ein- und Aussteigen |
| Tafel „Unfallfrei seit 4.012 Tagen“ | Ansehen (Nahansicht). Am Ende springt sie auf 0. |
| Stechuhr mit Kartenregal | Ansehen: Die Karten von Brenner und Mirko sind bis heute gestempelt (Kowalke stempelt für sie). Nur Kulisse. |
| Aushang „Sprengplan Stollen 7“ | Ansehen (Nahansicht): links die Ortsbrust von vorn mit den Bohrlöchern, rechts der Stollen im Längsschnitt. Bohrlöcher nur in der Ortsbrust, keine in der Firste. Jedes Loch trägt seine Zündstufe, 1 bis 9; eine Stufe 0 kommt im Plan nicht vor. |
| Sprengstofflager: Stahltür, Ausgabeluke zu | Nicht zu öffnen. |
| Sprengstoffbuch an der Kette | Ansehen (Nahansicht): Listen ohne Bedeutung. Zünderdraht mit Stufenschild benutzen: Eintrag „6 Zünder Stufe 0, 412“. Die Einträge setzt das Spiel als Schrift. |
| Türen | Werkstatt, Lohnbüro, Schlupftür im Tor zur Maschinenhalle |

Gegenstände zum Mitnehmen: keine.

### 2. Werkstatt

Anderthalb Bildschirme. Von links nach rechts: Tür zum Werkstor (linke Wand); Kaffeeecke mit Spüle, Kaffeemaschine
und Becherstapel; Stahlregal mit dem Ladegerät in Brusthöhe; lange Werkbank mit Schraubstock, darüber die
Lochwand mit Werkzeug; Tür zum Materiallager (rechte Wand). Kowalke steht vor der Werkbank. Er nimmt Gegenstände
hier und später am Bohrplatz an.

| Objekt | Aktion |
|---|---|
| Kowalke | Reden. Gegenstände geben (siehe unten). Wechselt an den Bohrplatz, sobald die Bohrung wieder läuft. |
| Ladegerät im Regal | Akku (leer) benutzen: steckt. Ist geladen, sobald Martin die ABC GmbH einmal verlassen hat: Akku (geladen) nehmen. |
| Werkbank | Gewebeband nehmen. |
| Kaffeeecke, Becherstapel | Becher nehmen (beliebig oft). |
| Waschbecken | Becher benutzen: Becher mit Wasser. |
| Tür | Materiallager |

An Kowalke geben:

- Steigschutzläufer, kaputt → Steigschutzläufer, neu. „Die Feder ist angesägt. Den habe ich vor sechs
  Wochen geprüft, da war sie heil.“ (Hinweis 1)
- Materialschein (unterschrieben) → Hydraulikschlauch (er holt ihn hinter dem Gitter).
- Becher mit festem Brocken → er kippt Streusalz in den Spültank, die Bohrung läuft (nur wenn Martin vorher
  den Brocken in klarem Wasser quellen sah).

### 3. Materiallager

Ein Bildschirm. Tür zur Werkstatt in der linken Wand. Das linke Drittel der Rückwand ist gemauert, davor steht
das Regal „Kleinteile“. Die rechten zwei Drittel der Rückwand sind das **Gitter** (grobes Drahtgitter vom Boden
bis zur Decke, Gittertür mit Vorhängeschloss); dahinter liegt ein zweiter, dunklerer Lagerraum, in den man
hineinsieht: links das Schlauchregal, in der Mitte das Fass, rechts die Palette. Martin kommt nie hinter das
Gitter; Kowalke holt den Schlauch, während das Bild abblendet.

| Objekt | Aktion |
|---|---|
| Regal „Kleinteile“, Kiste mit Sicherungen | Ohne Maß: „Ich weiß nicht, welche.“ Mit Maß: Sicherung F7 nehmen. |
| Gitter, verschlossen | Nur ansehen. Dahinter sichtbar: |
| – Schlauchregal | „Dafür brauche ich einen Materialschein.“ |
| – Fass „HFC“, roter Anhänger „LEER – Lieferung KW 47“ | Ansehen. Hinweis auf die fehlende Flüssigkeit. |
| – Palette „Winterdienst – Streusalz“ | Ansehen. „Da komme ich nicht ran.“ Hinweis auf Salz. |

### 4. Lohnbüro

Ein Bildschirm, Eichenfurnier und brauner Teppich. Von links nach rechts: Tür zum Werkstor (linke Wand); an der
Rückwand das Schwarze Brett mit der Beitragsliste und daneben der einzelne Aushang; in der Mitte Sieberts
Schreibtisch, dem Betrachter zugewandt, dahinter das Regal mit den Ordnern; in der rechten Wand die gepolsterte
Tür „Betriebsleitung“. Siebert sitzt hinter dem Schreibtisch.

| Objekt | Aktion |
|---|---|
| Siebert | Reden. Stellt den Materialschein aus, sobald Martin von Brenner weiß, dass er den Schlauch braucht. „Unterschrift Betriebsleiter. Vorschrift ist Vorschrift.“ |
| Beitragsliste an der Wand | Ansehen: „666 – Rückstand 26 Monate“. Siebert will kassieren (Gag, offen). |
| Aushang „Verschüttetsein: Arbeitszeit oder Bereitschaft?“ | Ansehen (Gag). |
| Tür „Betriebsleitung“ | Zu. Nach der Rettung offen: Brenners Büro. |

### 5. Maschinenhalle (scrollend)

Zwei Bildschirme. Die Halle ist höher als das Bild; Martin ist mittelgroß, damit die kleinen Dinge am Bohrplatz
noch zu erkennen sind. Linker Bildschirm Kulisse und Kapsel, rechter Bildschirm der **Bohrplatz**. Von links nach
rechts:

- Tor zum Werkstor (linke Wand).
- **Dahlbusch-Bombe und Lehrring:** Die Bombe liegt von Anfang an fertig auf zwei Böcken an der Rückwand, der
  rote Lehrring hängt darüber an einem Haken. So sieht der Spieler früh, worauf alles hinausläuft (Kowalke: „Die
  Bombe ist fertig. Fehlt nur das Loch.“).
- **Schneidrad:** eine runde Tunnelbucht in der Rückwand, darin eine Tunnelbohrmaschine, das Schneidrad zum
  Betrachter.
- **Bohrkernkisten** auf einem Bocktisch.
- **Rettungsbohranlage:** dunkelgrün, auf Kufen, mit Steuerpult und Meldeleuchte; der Gittermast ragt oben aus
  dem Bild, das Gestänge führt in das Standrohr im Boden. Kowalkes Platz, sobald die Bohrung läuft.
- **Spültank** rechts daneben, an ihm lehnen die leeren Säcke.
- **Versorgungsbohrung:** ein armdickes Rohr, kniehoch aus dem Boden, darüber ein kleines Dreibein mit Handwinde
  und der Kapsel am Seil. Daneben auf einem Pfosten das **Grubentelefon**; sein Kabel führt in das Rohr.

Ist die Bohrung durch, ist das Gestänge gezogen, und die Bombe hängt am Seil der Bohranlage über dem Standrohr.

| Objekt | Aktion |
|---|---|
| Schneidrad einer Tunnelbohrmaschine, 9 m | Ansehen. Kulisse. |
| Rettungsbohranlage | Ansehen: „Steht. Bei 41 Metern sitzt der Meißel fest.“ Läuft später (Leuchte grün); ist durch, sobald Martin den Ort einmal verlassen hat. |
| Bohrkernkisten | Ansehen: Der Kern endet bei 41 m in grauem Bruch. Bohrkernbrocken nehmen (beliebig oft). |
| Spültank | Ansehen: grauer Schlamm, dick wie Pudding. Läuft die Bohrung: dünne braune Brühe. |
| Leere Säcke am Spültank | Ansehen: „Spülungszusatz KCl – Toninhibitor“. Kowalke dazu: „Ist alle. Kommt in KW 47.“ |
| Versorgungsbohrung mit Winde und Kapsel | Materialschein in die Kapsel legen, Winde benutzen (hinunter, herauf). |
| Grubentelefon | Mit Brenner reden. |
| Lehrring an der Wand (38,5 cm) | Benutzen, wenn die Bohrung durch ist: Martin passt hindurch, Kowalke nicht. |
| Dahlbusch-Bombe | Auf den Böcken: nur ansehen. Am Seil der Bohranlage (Bohrung durch): Benutzen: Einfahrt in die Kammer (Video). Kowalke lässt Martin nur mit Schlauch und Glykol einfahren. |

### 6. Kammer in Stollen 7

Martin kommt mit Hydraulikschlauch und Glykol-Kanister an.

Anderthalb Bildschirme: ein kurzes Stück Stollen, von der Seite gesehen, an beiden Enden vom Bruch verschlossen.
Die Rückwand ist der Stoß mit Stahlbögen und Verzugsmatten, oben die Firste. Von links nach rechts:

- **Erster Bruch**, daneben das Bohrloch der Rettungsbohrung in der Firste. Darunter steht die Dahlbusch-Bombe am
  Seil.
- **Lager:** Kiste (Brenners Platz), Wasserkanister, Decke, das Rohr der Versorgungsbohrung mit dem Grubentelefon.
  Daneben der **Stapel Kanthölzer** und die **Tropfstelle** mit dem Eimer.
- **Bohrwagen:** niedrig, gelb, von der Seite, Bohrarm nach rechts. Hinten die **Handpumpe** mit langem Hebel
  (die Notpumpe der Hydraulik), an der Seite die Wartungsklappe (Nahansicht: Tank mit Schauglas, gerissener
  Schlauch zwischen zwei Steckkupplungen).
- **Zweiter Bruch** ganz rechts. Ein **Stahlbogen** des Ausbaus ist herabgebrochen: Ein Ende steckt im Bruch, das
  andere liegt auf der Spitze des Bohrarms, darunter Mirkos Unterschenkel. Brenner hat versucht, den Bogen mit dem
  Bohrarm anzuheben; dabei ist der Schlauch gerissen, und der Arm ist wieder abgesackt.
- **Zünderdrähte:** Über dem zweiten Bruch hängen fünf dünne gelbe und rote Drähte aus kurzen Bohrlöchern in der
  Firste, jeder mit einem kleinen Stufenschild.

Das Heben: Die Handpumpe hebt den Bohrarm und damit das freie Ende des Bogens um eine Stufe. Unterbaut wird neben
Mirkos Bein, zwischen Sohle und Bogen. Im Spiel drehen sich Bohrarm und Bogen als eigene Ebenen um ihre Gelenke.

| Objekt | Aktion |
|---|---|
| Brenner, Arm in der Schlinge | Reden. Kann den Schlauch einhändig nicht tauschen. |
| Mirko, Bein unter dem Stahlbogen | Reden. |
| Bohrwagen, Wartungsklappe (Nahansicht) | Gerissener Schlauch: Hydraulikschlauch benutzen: getauscht (Steckkupplungen, ohne Werkzeug). Tank: Glykol-Kanister benutzen: Schauglas halb voll. Eimer mit Tropfwasser benutzen: halb voll. Beides in beliebiger Reihenfolge: voll. |
| Eimer unter der Tropfstelle | Eimer mit Tropfwasser nehmen. |
| Handpumpe | Ohne neuen Schlauch: „Dann pumpe ich alles auf die Sohle.“ Tank nicht voll: „Die Pumpe zieht Luft.“ Sonst: hebt eine Stufe. Zweimal hintereinander ohne Unterbauen: Martin bricht ab („Wenn der Schlauch noch einmal reißt, liegt alles wieder auf seinem Bein.“). |
| Stapel Kanthölzer | Kantholz nehmen (drei Stück). |
| Stahlbogen | Kantholz benutzen: unterbaut (nur nach einer Stufe Heben). Nach der dritten Stufe und dem dritten Kantholz zieht Brenner Mirko heraus. |
| Zünderdrähte in der Firste | Ansehen, dann Zünderdraht mit Stufenschild nehmen. Brenner: „In der Firste hat keiner was zu bohren.“ (Hinweis 2) |
| Dahlbusch-Bombe | Erst wenn Mirko frei ist: Mirko fährt aus, dann Martin, Brenner zuletzt. |

### 7. Brenners Büro (nach der Rettung)

Ein Bildschirm, dunkles Nussbaumfurnier. Gepolsterte Tür zum Lohnbüro in der linken Wand. In der Mitte Brenners
Schreibtisch, dem Betrachter zugewandt; links daneben an der Rückwand das gerahmte Foto, hinter dem Schreibtisch
ein großes Grubenbild (Kulisse), rechts Garderobe mit weißem Helm und ein Ledersofa.

| Objekt | Aktion |
|---|---|
| Brenner | Reden: gibt die Bürgschaft von Brenner („Ich war mit Ihnen unter Tage.“). Lässt Siebert die Unfallanzeige schreiben (Martin als Retter, Mirko als Zeuge). Tafel am Werkstor: 0. |
| Foto an der Wand | Ansehen: Brenner und Hollmann jung in Pionieruniform. Brenner: Hollmann rief vor gut zwei Jahren an und fragte, wie man eine Stahltür unsichtbar in eine Altbauwand setzt. Mehr weiß er nicht. |

## Ablauf mit allen Kombinationen

### A. Besorgungen für die Antarktis (jederzeit)

1. Kiste mit Sicherungen (mit Maß) → Sicherung F7
2. Steigschutzläufer, kaputt → Kowalke → Steigschutzläufer, neu
3. Akku (leer) + Ladegerät → nach Rückkehr Akku (geladen)
4. Gewebeband von der Werkbank

### B. Die Bohrung in Gang bringen

5. Bohrkernkisten → Bohrkernbrocken
6. Becher + Waschbecken → Becher mit Wasser
7. Bohrkernbrocken + Becher mit Wasser → Becher mit Tonbrei. Martin: „Bentonit. Trinkt Wasser und wird dreimal
   so dick. Und die spülen ihre Bohrung mit Wasser.“
8. Becher + Waschbecken → zweiter Becher mit Wasser
9. Salzstreuer + Becher mit Wasser → Becher mit Salzwasser (der Streuer bleibt)
10. Bohrkernbrocken + Becher mit Salzwasser → Becher mit festem Brocken
11. Becher mit festem Brocken → Kowalke → Bohrung läuft; Ort verlassen und wiederkommen → Bohrung ist durch

### C. Material für unten

12. Grubentelefon → Brenner sagt, was fehlt: Schlauch gerissen, Flüssigkeit ausgelaufen, Mirkos Bein darunter
13. Siebert → Materialschein
14. Materialschein + Kapsel der Versorgungsbohrung, Winde → Grubentelefon (Brenner unterschreibt) → Winde →
    Materialschein (unterschrieben)
15. Materialschein (unterschrieben) → Kowalke → Hydraulikschlauch
16. Glykol-Kanister aus der Antarktis mitbringen (Fass „HFC“ ist leer; Kowalke: „HFC ist Wasser mit Glykol.
    Öl darf nicht runter, das brennt.“)

### D. Rettung

17. Lehrring benutzen → Dahlbusch-Bombe benutzen → Kammer
18. Wartungsklappe des Bohrwagens: Hydraulikschlauch + gerissener Schlauch
19. Glykol-Kanister + Tank, Eimer mit Tropfwasser + Tank (beliebige Reihenfolge; erst dann ist der Tank voll)
20. Handpumpe, Kantholz + Stahlbogen, dreimal im Wechsel → Mirko frei
21. Zünderdraht mit Stufenschild nehmen
22. Ausfahren

### E. Schluss

23. Brenners Büro → Bürgschaft von Brenner, Unfallanzeige
24. Zünderdraht mit Stufenschild + Sprengstoffbuch → Eintrag 412: Der Novize von der Antenne hat sechs Wochen
    vorher sechs Zünder zu viel geholt. Gezündet hat vor elf Tagen ein anderer. Wer, klärt sich in Area 52.

B und C sind in beliebiger Reihenfolge lösbar, A ist unabhängig vom Rest.

## Gegenstände des Ortes

| Gegenstand | Woher | Wofür | Bleibt |
|---|---|---|---|
| Sicherung F7 | Materiallager | Antarktis | Antarktis |
| Steigschutzläufer, neu | Kowalke | Antarktis | Antarktis |
| Akku (geladen) | Ladegerät | Antarktis | Antarktis |
| Gewebeband | Werkbank | Antarktis | Antarktis |
| Becher (in vier Zuständen) | Kaffeeecke | Tonversuch | im Ort |
| Bohrkernbrocken | Bohrkernkisten | Tonversuch | im Ort |
| Materialschein (leer, unterschrieben) | Siebert | Hydraulikschlauch | im Ort |
| Hydraulikschlauch | Kowalke | Bohrwagen | im Ort |
| Eimer mit Tropfwasser | Kammer | Tank des Bohrwagens | im Ort |
| Kantholz (drei Stück) | Kammer | Stahlbogen unterbauen | im Ort |
| Zünderdraht mit Stufenschild | Kammer | Sprengstoffbuch; Area 52, Anhörung | Area 52 |
| Bürgschaft von Brenner | Brenner | Area 52, Anhörung | Area 52 |
| Unfallanzeige | Siebert | Area 52, Anhörung | Area 52 |

## Warum die Lösungen in der Wirklichkeit stimmen

Quellton klemmt Bohrgestänge, Salzspülungen hemmen das Quellen; Restauratoren kennen Bentonit aus
Entsalzungskompressen. Wasser-Glykol ist die schwer entflammbare Hydraulikflüssigkeit des Bergbaus (HFC). Die
Dahlbusch-Bombe hat 38,5 cm Durchmesser (Lengede 1963). „Einen Zoll heben, einen Zoll unterbauen“ ist eine
Grundregel der technischen Rettung. HFC besteht etwa zur Hälfte aus Wasser: Glykol und Tropfwasser ergeben
zusammen die richtige Flüssigkeit. Hydraulische Maschinen haben eine Handpumpe für den Notbetrieb. In einem
Sprengplan trägt jedes Bohrloch die Zeitstufe seines Zünders; Stufe 0 ist der Momentzünder.

## Offen / Ideen

- Wohin Stollen 7 führt. Vorschlag: zweiter, unfertiger Zugang unter Area 52, Fluchtweg im Finale.
- Wer 666 vorher war (Beitragsliste).
- Akku als Rätsel weiterhin zu einfach.
- **Engine:** In der Kammer drehen sich Bohrarm und Stahlbogen als ausgeschnittene Ebenen um ihre Gelenke (drei
  Stufen); die Maschinenhalle braucht eine dritte Figurgröße zwischen Bahnhof und normalem Raum.
- **Einfahrt:** Video; erstes Bild ist die Maschinenhalle, wie der Spieler sie in dem Moment sieht, letztes Bild
  der linke Teil der Kammer.
