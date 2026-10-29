# Kyphi

Ein Point-and-Click-Adventure. Der Restaurator Martin Kessler entdeckt im gesperrten Flügel eines Museums
Spuren nächtlicher Rituale und findet den verborgenen Zugang zu einem unterirdischen Tunnelsystem, das eine Sekte
gebaut hat. Das Spiel erscheint in Teilen; in Arbeit ist **Teil 1: Der Zugang**.

## Verzeichnisse

| Pfad | Inhalt | Im Repo |
|---|---|---|
| `concept/game.md` | Grundlagen des Spiels: Genre, Sprache, Aufbau, Regeln für die Geschichte | ja |
| `concept/part_*.md` | Story, je Teil ein Dokument (`part_1_access.md`) | nein (`.gitignore`) |
| `assets/` | Fertige Assets: Szenen-Hintergründe mit Ebenen (`scenes/`), Inventar-Icons (`items/`), Katalog, Herkunft, Übersicht (`overview.html`) | ja |
| `work/` | Arbeitsdateien: generierte Bilder, Stimmen, Videos, 3D-Modelle, Entwürfe | nein (`.gitignore`) |

## Sprache

Das Spiel ist deutsch: Texte, Dialoge und Sprachausgabe. Verzeichnisse, Dateinamen und Code sind englisch.

## Asset-Erzeugung

Alle Bilder, Stimmen, Videos und 3D-Modelle werden mit [gb10-assets](https://github.com/StefanMenne/gb10-assets)
erzeugt: einer selbst gehosteten Pipeline auf einem NVIDIA-GB10-System, angesteuert über die Kommandozeile
(`gb10-assets`) oder das Claude-Code-Plugin. Es laufen ausschließlich lokal installierte Modelle mit freien
Lizenzen; keine Cloud-Dienste und keine Modelle, deren Lizenz die Nutzung der Ergebnisse einschränkt.

### Verwendete Werkzeuge und Lizenzen

Stand: gb10-assets 0.1.2 (Commit `40c9d8c`, 29.10.2026)

| Tool | Modell | Wofür | Lizenz |
|---|---|---|---|
| `flux2-klein` | [FLUX.2 \[klein\] 4B](https://huggingface.co/black-forest-labs/FLUX.2-klein-4B) (Black Forest Labs) | Bilder aus Text, optional mit Referenzbildern | Apache-2.0 |
| `qwen-image-edit` | [Qwen-Image-Edit-2511](https://huggingface.co/Qwen/Qwen-Image-Edit-2511) (Alibaba) mit [Lightning-LoRA](https://huggingface.co/lightx2v/Qwen-Image-Edit-2511-Lightning) | Bilder bearbeiten und kombinieren | Apache-2.0 |
| `qwen-tts` | [Qwen3-TTS 1.7B VoiceDesign](https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign) und [Base](https://huggingface.co/Qwen/Qwen3-TTS-12Hz-1.7B-Base) (Alibaba) | Stimmen entwerfen, Sprachausgabe | Apache-2.0 |
| `ltx-video` | [LTX-2.5](https://huggingface.co/Lightricks/LTX-2.5) 22B (Lightricks) | Videos mit Ton (geplant) | [LTX-2.x Community License](https://github.com/Lightricks/LTX-2/blob/main/LICENSE-2_x) |
| `pixal3d` | [Pixal3D](https://huggingface.co/Comfy-Org/Pixal3D) auf TRELLIS.2, ausgeführt von ComfyUI | 3D-Modelle (GLB) aus einem Bild | MIT; Bildencoder DINOv3: [DINOv3 License](https://huggingface.co/facebook/dinov3-vitl16-pretrain-lvd1689m); ComfyUI: GPL-3.0 |
| `blender` | [Blender](https://www.blender.org) 5.2 (bpy) | Riggen, Animieren, Rendern, Texturkorrekturen | GPL-3.0 |

Hinweise zu den Lizenzen, die nicht Apache-2.0 oder MIT sind:

- **LTX-2.x Community License:** keine Open-Source-Lizenz, aber kostenlos und auch kommerziell nutzbar für
  Personen und Unternehmen mit weniger als 10 Mio. US-Dollar Jahresumsatz. Die Lizenz wurde auf Hugging Face
  akzeptiert. Wird diese Grenze je überschritten, sind Videos aus `ltx-video` neu zu bewerten.
- **DINOv3 License (Meta):** gilt für den Bildencoder, den Pixal3D intern nutzt. Sie regelt die Nutzung des
  Modells; die erzeugten 3D-Modelle sind davon nicht eingeschränkt.
- **GPL-3.0 (Blender, ComfyUI):** betrifft nur die Programme selbst. Mit ihnen erzeugte oder bearbeitete Dateien
  (Modelle, Renderings) fallen nicht unter die GPL.

### Herkunft der Assets festhalten

Damit sich für jedes Asset belegen lässt, wie es entstanden ist, wird beim Übernehmen ins Spiel festgehalten:
Tool, Prompt, Seed, Referenzbilder und Datum. gb10-assets liefert diese Angaben pro Job (Job-ID, Parameter).
Fremdmaterial (Fotos, Fonts, Musik, Geräusche aus anderen Quellen) kommt nur mit dokumentierter Lizenz ins Spiel.

Für die Assets in `assets/` stehen diese Angaben in `assets/provenance.json`.

Bilder entstehen in der Regel in zwei Schritten: ein Entwurf mit `flux2-klein`, danach Bearbeitung und
Angleichung mit `qwen-image-edit`. So sind auch die bisherigen Entwürfe in `work/` entstanden (Figuren Martin,
Ackermann, Hollmann; Schauplätze Lobby, Altarraum, Depot, Werkstatt, Wohnung); ihre Prompts sind nicht einzeln
festgehalten.

### Urheberrecht an KI-Ergebnissen

Rein KI-generierte Inhalte sind nach deutschem und EU-Recht in der Regel nicht urheberrechtlich geschützt, weil
die menschliche schöpferische Leistung fehlt. Für das Spiel heißt das: Die Nutzung ist frei, Dritte könnten
einzelne unbearbeitete Assets aber ebenfalls verwenden. Schutz entsteht durch eigene Gestaltung: Auswahl,
Bearbeitung, Zusammenstellung im Spiel, Story und Code. Prompts nennen keine geschützten Figuren, Marken oder
lebenden Künstler und Personen, und Stimmen werden entworfen (`design_voice`) statt von fremden Aufnahmen geklont.

Dieser Abschnitt ist eine Dokumentation der Vorgehensweise, keine Rechtsberatung.
