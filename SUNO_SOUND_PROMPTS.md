# Stillway — Suno sound prompts

Real field-like loops for the 12 Stillway beds. Generate in **Suno**, export seamless **m4a/wav**, drop into `Stillway/Resources/Sounds/` with the exact filenames below.

## Global style (append to every prompt)

```
seamless looping ambient soundscape, no vocals, no lyrics, no melody hook,
slow evolving texture, high quality stereo, soft dynamics, 0–8kHz gentle presence,
designed for headphones, endless loop friendly, fade-safe edges
```

## Tracks

| File | Mode | Suno prompt |
|------|------|-------------|
| `tokyo_metro.m4a` | COMMUTE | Tokyo subway carriage rumble, soft motor drone, distant rail clacks, muffled station PA far away, warm low end, calm night commute |
| `shinkansen.m4a` | COMMUTE | Shinkansen cabin ambience, aerodynamic hush, subtle track rhythm, pressurized air whisper, deep stable drone |
| `paris_metro.m4a` | COMMUTE | Paris Metro tunnel resonance, rubber-tire whoosh, soft squeal far off, concrete echo, evening blue mood |
| `istanbul_ferry.m4a` | COMMUTE | Bosphorus ferry deck, gentle water slap, engine throb, seagull distant, wood and metal creaks, open air breeze |
| `tokyo_rain.m4a` | FOCUS | Soft Tokyo rain on glass and leaves, sparse drops, no thunder, intimate close mic, deep focus bed |
| `deep_train.m4a` | FOCUS | Distant freight / train low-pass rumble under rain, hypnotic pulse, library-level quiet midrange |
| `night_cafe.m4a` | FOCUS | Quiet night cafe room tone, espresso machine far, soft cup clinks rare, warm AC hush, intimate |
| `minka_library.m4a` | FOCUS | Wooden Japanese room / library hush, paper rustle rare, floor creak sparse, dust-in-sunlight stillness |
| `kyoto_bamboo.m4a` | RESET | Kyoto bamboo grove wind, soft hollow knocks, leaf shimmer, birds very distant, zen garden air |
| `temple_bell.m4a` | RESET | Soft temple bell decay into night air, long reverb tails, cricket bed under, sacred calm |
| `rain_window.m4a` | RESET | Rain on bedroom window, slow streaks, radiator hush, safe indoor perspective |
| `night_forest.m4a` | SLEEP | Night forest for sleep, soft wind in pines, distant owl rare, no sudden peaks, very low dynamics |

## Suno settings tips

- Style: `Ambient / Soundscape / ASMR-adjacent`
- Duration: generate 2–3 min, then loop-crossfade in audio editor (2–4 s overlap)
- Avoid: drums, vocal chops, bright leads, speech
- Export: AAC `.m4a`, mono-compatible stereo, peak around −6 dBFS

## After export

```bash
# names must match Sound.swift fileName
ls Stillway/Resources/Sounds/*.m4a
```

Until files exist, Stillway plays distinct procedural beds per track (not final quality).
