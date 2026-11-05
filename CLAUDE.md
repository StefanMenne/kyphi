# Kyphi

2D-Point-and-Click-Adventure, Grundlagen in `concept/game.md`, Story je Teil in `concept/part_<n>_<name>.md`.

- Das Spiel ist deutsch (Texte, Dialoge, Sprachausgabe); Verzeichnisse, Dateinamen und Code sind englisch.
- `work/` ist ein eigenes privates Repo (`git@github.com:StefanMenne/kyphi-assets.git`) mit Story (`work/story/`; `concept/part_*.md` sind Symlinks dorthin), Konzeptbildern, Fixpunkten und Rezepten; Regeln in `work/README.md`. Generierte Assets kommen zuerst nach `work/`, fertige nach `assets/` (Herkunft in `assets/provenance.json`). Cache und verworfene Varianten nicht in `work/` committen.
- Assets nur mit den in der README genannten gb10-assets-Tools erzeugen und ihre Herkunft festhalten.
