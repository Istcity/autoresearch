# Stillway — Suno nasıl yazılır

Suno şarkı üretir; biz **vokalsiz, sonsuz loop ambient bed** istiyoruz. Aşağıdaki alanları birebir doldur.

## 1) Suno’da ekran

1. [suno.com](https://suno.com) → Create  
2. **Custom** aç (Simple kullanma)  
3. **Instrumental** switch’ini **ON** yap  
4. Model: mümkünse **v4 / v4.5 / v5** (hangisi varsa en yenisi)

### Alanlar

| Alan | Ne yazacaksın |
|------|----------------|
| **Title** | Dosya adı mantığı: `tokyo_rain` |
| **Styles** | Tür + tempo + yasaklar (aşağıdaki Style kutusu) |
| **Lyrics** | Vokal yok; sadece yapı etiketleri |
| **Exclude styles** (Advanced varsa) | `vocals, singing, rap, speech, drums, drop, edm, guitar solo` |

---

## 2) Her parça için kopyala-yapıştır şablonu

### Styles (aynı kalıp, ortadaki cümleyi değiştir)

```
ambient soundscape, field recording texture, slow evolving drone,
soft dynamics, no melody hook, headphone listening, 55 BPM,
[BURAYA PARÇA CÜMLESİ],
instrumental
```

> `instrumental` **en sonda** kalsın (Suno v5.x’te vokal kaçırma ihtimalini düşürür).

### Lyrics

```
[Intro]
[Instrumental]
[Ambient Texture]
[Soft Evolution]
[Outro]
[Fade Out]
```

Lyrics’e **hiç kelime yazma**. Sadece bu etiketler.

---

## 3) 12 parça — Styles içindeki “[PARÇA CÜMLESİ]”

| Dosya adı | Styles ortasına yapıştır |
|-----------|---------------------------|
| `tokyo_metro.m4a` | Tokyo subway carriage rumble, soft motor drone, distant rail clacks, muffled station PA far away, warm low end, calm night commute |
| `shinkansen.m4a` | Shinkansen cabin ambience, aerodynamic hush, subtle track rhythm, pressurized air whisper, deep stable drone |
| `paris_metro.m4a` | Paris Metro tunnel resonance, rubber-tire whoosh, soft squeal far off, concrete echo, evening blue mood |
| `istanbul_ferry.m4a` | Bosphorus ferry deck, gentle water slap, engine throb, seagull distant, wood and metal creaks, open air breeze |
| `tokyo_rain.m4a` | Soft Tokyo rain on glass and leaves, sparse drops, no thunder, intimate close mic, deep focus bed |
| `deep_train.m4a` | Distant freight train low-pass rumble under rain, hypnotic pulse, library-level quiet midrange |
| `night_cafe.m4a` | Quiet night cafe room tone, espresso machine far, soft cup clinks rare, warm AC hush, intimate |
| `minka_library.m4a` | Wooden Japanese room library hush, paper rustle rare, floor creak sparse, dust-in-sunlight stillness |
| `kyoto_bamboo.m4a` | Kyoto bamboo grove wind, soft hollow knocks, leaf shimmer, birds very distant, zen garden air |
| `temple_bell.m4a` | Soft temple bell decay into night air, long reverb tails, cricket bed under, sacred calm |
| `rain_window.m4a` | Rain on bedroom window, slow streaks, radiator hush, safe indoor perspective |
| `night_forest.m4a` | Night forest for sleep, soft wind in pines, distant owl rare, no sudden peaks, very low dynamics |

### Örnek tam Styles (`tokyo_rain`)

```
ambient soundscape, field recording texture, slow evolving drone,
soft dynamics, no melody hook, headphone listening, 55 BPM,
Soft Tokyo rain on glass and leaves, sparse drops, no thunder, intimate close mic, deep focus bed,
instrumental
```

---

## 4) İnce ayarlar (Creative / Advanced)

Suno sürümüne göre isimler değişir; mantık aynı:

| Ayar | Öneri | Neden |
|------|--------|--------|
| **Instrumental** | ON | Vokal istemiyoruz |
| **Weirdness / Chaos / Weird** | **20–35** | Çok yüksekse ani efekt / melodi çıkar |
| **Style Influence / Adherence** | **65–80** | Prompt’a daha sadık kalsın |
| **Audio Influence** (varsa, referans yüklerken) | **30–50** | Sadece ikinci denemede |
| **BPM** (Styles içinde) | Focus/Sleep **50–60**, Commute **55–70** | Hızlı hissettirmesin |
| **Exclude** | vocals, drums, bass drop, trap, pop, speech | Bed’i bozar |

Sliders yoksa sadece Styles + Instrumental + Exclude yeterli.

---

## 5) Üretim → Stillway’e koyma

1. Her parça için **2–4 varyasyon** üret, en düzgün “sonsuz hisseden”i seç.  
2. İdeal: **2–3 dakika**, ani vuruş / konuşma / melodi yok.  
3. Suno’dan **WAV veya yüksek kalite** indir.  
4. Loop için Audacity / Logic / CapCut’ta **2–4 sn crossfade** yap (baş–son birleşsin).  
5. AAC **`.m4a`** export et, peak ≈ **−6 dBFS**.  
6. Dosyayı birebir şu isimle koy:

```text
Stillway/Resources/Sounds/tokyo_rain.m4a
```

İsim `Sound.swift` içindeki `fileName` ile aynı olmalı.

---

## 6) Yaygın hatalar

| Sorun | Çözüm |
|-------|--------|
| Vokal / mırıldanma geliyor | Instrumental ON + Styles sonunda `instrumental` + Exclude: `vocals` |
| Şarkı gibi melodi | Styles’a ekle: `no melody, no hook, drone only` |
| Çok hareketli / agresif | Weirdness düşür, BPM 50–55, “soft dynamics, sparse” ekle |
| Gök gürültüsü / ani peak (yağmur) | Prompt’a `no thunder, no sudden peaks` |
| Loop’ta tıkırtı | Editörde crossfade; ham Suno çıktısını olduğu gibi kullanma |

---

## 7) Hızlı rutin (12 parça)

1. Custom + Instrumental ON  
2. Lyrics’i sabit etiketlerle yapıştır  
3. Styles şablonuna parça cümlesini koy  
4. Generate → beğenmezsen Weirdness ±5 veya bir kelime değiştir  
5. En iyi take’i export → loop → `Sounds/`  

Uygulama `.m4a` bulunca prosedürel sesi bırakıp gerçek dosyayı çalar.
