# Stillway — Design System v1.0

> Premium his. İlk açılıştan son kapanışa kadar.

---

## 1. Tasarım Felsefesi

```
Minimalist değil — özlenmiş.
Sade değil — arındırılmış.
Karanlık değil — derin.
```

Stillway'i açan kullanıcı şunu hissetmeli:
"Bu uygulama benim için yapılmış."

Referans noktaları: Endel'in sadeliği + Darkroom'un polisajı +
BeReal'ın samimiyeti + Apple'ın materyali — ama hiçbirinin kopyası değil.

---

## 2. Renk Sistemi — Bağlam Degradeleri

Her bağlam kendi renk evrenine sahip. Geçiş anlık değil —
1.2 saniye boyunca tam ekran renk süpürmesi (color sweep).

### COMMUTE — Lacivert / Gece Mavisi Evreni
```
Arkaplan gradient (radial, ekranı doldurur):
  #020818  →  #0D1B4D  →  #1B0D4D

Dalga rengi (animated):
  #1B3FDB  →  #6B21DB  →  #9B59B6

Buton glow:  rgba(27, 63, 219, 0.4)
Aksan:       #4169E1
Kart zemin:  rgba(13, 27, 77, 0.6) + blur
```

### FOCUS — Gece Mavisi / Derin Okyanus
```
Arkaplan gradient:
  #020C18  →  #041B2D  →  #062040

Dalga rengi:
  #0A84FF  →  #0066CC  →  #00B4A0

Buton glow:  rgba(10, 132, 255, 0.35)
Aksan:       #0A84FF
Kart zemin:  rgba(4, 27, 45, 0.6) + blur
```

### SLEEP — Derin Mor / Gece Evreni
```
Arkaplan gradient:
  #050010  →  #0F0226  →  #1A0533

Dalga rengi:
  #5E5CE6  →  #7C3AED  →  #4C1D95

Buton glow:  rgba(94, 92, 230, 0.35)
Aksan:       #5E5CE6
Kart zemin:  rgba(15, 2, 38, 0.65) + blur
```

### RESET — Amber / Akşam Sıcaklığı
```
Arkaplan gradient:
  #180800  →  #2D1200  →  #3D1A00

Dalga rengi:
  #FF9F0A  →  #FF6B35  →  #FF453A

Buton glow:  rgba(255, 159, 10, 0.4)
Aksan:       #FF9F0A
Kart zemin:  rgba(45, 18, 0, 0.6) + blur
```

### WALKING — Zümrüt / Orman
```
Arkaplan gradient:
  #001208  →  #002010  →  #003018

Dalga rengi:
  #30D158  →  #34C759  →  #00BFB3

Buton glow:  rgba(48, 209, 88, 0.35)
Aksan:       #30D158
Kart zemin:  rgba(0, 32, 16, 0.6) + blur
```

### DEEP WORK — Kırmızı / Kriz Odağı
```
(İsteğe bağlı mod: "Sıkı Odak / Deadline")

Arkaplan gradient:
  #150000  →  #2D0000  →  #3D0A0A

Dalga rengi:
  #FF453A  →  #FF2D20  →  #C0000A

Buton glow:  rgba(255, 69, 58, 0.4)
Aksan:       #FF453A
Kart zemin:  rgba(45, 0, 0, 0.65) + blur
```

### UNKNOWN (Başlangıç / Geçiş)
```
Arkaplan gradient:
  #050505  →  #0A0A0A  →  #111111

Dalga rengi:
  #48484A  →  #636366  →  #48484A

Aksan:       #8A8A8E
```

---

## 3. Arkaplan Animasyonu (Mesh Gradient)

```swift
// Her bağlam için SwiftUI animated mesh gradient
// iOS 18+ MeshGradient kullanılır
// iOS 17 fallback: animasyonlu radial gradient

MeshGradient(
    width: 3, height: 3,
    points: animatedPoints,   // TimelineView ile hareket eder
    colors: contextColors
)
.animation(.easeInOut(duration: 8).repeatForever(autoreverses: true))
```

Mesh hareketi: çok yavaş, neredeyse görünmez drift —
kullanıcı fark etmez ama uygulama "nefes alıyor" hissini verir.

---

## 4. Tipografi

### Font Ailesi
```
Başlık (Display):   SF Pro Display — Weight: Light (300)
Alt başlık:         SF Pro Display — Weight: Regular (400)
Mod adı:            SF Pro Rounded — Weight: Semibold (600)
Gövde:              SF Pro Text — Weight: Regular (400)
Zamanlayıcı:        SF Mono — Weight: Medium (500)
Küçük etiket:       SF Pro Text — Weight: Medium (500), letterspacing: +0.5
```

Neden SF Pro ailesi:
- Lisans sorunu yok (Apple native)
- Her cihazda optical size ile otomatik optimize
- Dynamic Type desteği tam
- Japonca/Türkçe/Fransızca tüm karakterleri mükemmel render

### Boyut Hiyerarşisi
```
96pt  — Zamanlayıcı rakamı (ana ekran merkezi)
34pt  — Mod adı (COMMUTE, FOCUS vb.)
28pt  — Ses adı
17pt  — Gövde metni
15pt  — İkincil bilgi
13pt  — Etiket, küçük not
11pt  — Mikro etiket
```

### Harf Aralığı ve Satır Yüksekliği
```
Mod adı:      letterspacing +2.0, ALL CAPS
Ses adı:      letterspacing +0.3
Zamanlayıcı:  letterspacing -1.0 (rakamlar birbirine yakın)
```

---

## 5. Komponent Kataloğu

### Ana Başlatma Butonu
```
Şekil:          Circle (80pt çap)
Arkaplan:       Bağlam aksan rengi, %20 opaklık
Kenarlık:       1pt, aksan rengi %60 opaklık
İkon:           SF Symbol — "waveform" (çalıyor) / "play.fill" (dur.)
Glow efekti:    shadow(color: accentGlow, radius: 20, x: 0, y: 0)
                shadow(color: accentGlow, radius: 40, x: 0, y: 10)  — çift katman
Basınç:         scaleEffect(0.94) spring animasyon
Haptic:         .rigid (başlatma) / .soft (durdurma)
```

### Zamanlayıcı Seçici (Pill Row)
```
Şekil:          Capsule (pill)
Seçili:         Aksan rengi fill + beyaz metin
Seçilmemiş:     rgba(255,255,255,0.08) fill + %50 beyaz metin
Geçiş:          matchedGeometryEffect (smooth selection slide)
Yükseklik:      36pt
Padding:        H: 20pt, V: 8pt
```

### Ses Kartı (Glass Card)
```
Arkaplan:       .ultraThinMaterial
Kenarlık:       LinearGradient(beyaz %15 → şeffaf %0), 1pt
Corner radius:  20pt
Gölge:          shadow(color: siyah %30, radius: 16, y: 8)
İçerik:         Ses adı (sol) + Hacim slider (sağ)
Alt bilgi:      Yerel ses adı (Japonca vb.), %40 opaklık
```

### Alt Sayfa (Bottom Sheet)
```
Tetikleyici:    Sürükleme + tap → .sheet veya custom detent
Arkaplan:       .regularMaterial (bağlam renginin üzerinde)
Tutamaç:        Rounded rect, 4×36pt, %20 beyaz
Köşe yarıçapı:  Üst: 24pt
Animasyon:      .spring(response: 0.4, dampingFraction: 0.82)
Arka planda:    İçerik %60 scale + blur
```

### Context Badge (Mod Rozeti)
```
Şekil:          Capsule
Metin:          Mod adı ("YOLCULUK") — SF Pro Rounded Semibold 13pt ALL CAPS
Renk:           Aksan rengi, %20 arkaplan + aksan rengi metin
Animasyon:      Bağlam değişince:
                  1. Eski rozet → scale(0.8) + opacity(0) (0.2s)
                  2. Yeni rozet → scale(1.0) + opacity(1.0) (0.3s, spring)
"Auto" etiketi: Yeşil nokta (animasyonlu pulse) + "OTOMATİK" yazısı
```

### Hacim Kaydırıcı
```
Track:          Custom — 4pt yükseklik, rounded
Fill:           Aksan rengi gradient
Thumb:          28pt circle, .ultraThinMaterial + shadow
Haptic:         .selection her %10 değişimde
```

### Navigasyon Çubuğu
```
Yok. Tam immersive ekran.
Ayarlar: Sağ üst köşe gear ikonu (22pt, %60 beyaz)
Yerlerim: Sol üst köşe location.north.fill (22pt, %60 beyaz)
Şeffaf arkaplan, status bar içeriği beyaz.
```

---

## 6. Animasyon Sistemi

### Bağlam Geçiş Animasyonu (signature moment)
```
Tetikleyici: AppContext değişti

1. Mevcut dalga → amplitude sıfıra iner (0.4s ease-in)
2. Arkaplan → tam ekran overlay, eski renk (0s)
3. Overlay → bağlam rengine geçiş (0.6s ease-in-out)
4. Yeni dalga → sıfırdan amplitude artışı (0.8s spring)
5. Rozet değişimi (0.3s, gecikmeli 0.2s)
Toplam: ~1.5s, kesintisiz
```

### Dalga Animasyonu Parametreleri (bağlama göre)
```swift
struct WaveConfig {
    var layerCount: Int         // dalga katmanı
    var frequency: Double       // Hz
    var amplitude: Double       // piksel
    var phaseSpeed: Double      // radyan/saniye
    var opacity: Double
}

COMMUTE: WaveConfig(layerCount: 4, frequency: 0.9, amplitude: 32, phaseSpeed: 1.8, opacity: 0.85)
FOCUS:   WaveConfig(layerCount: 3, frequency: 0.5, amplitude: 24, phaseSpeed: 0.9, opacity: 0.75)
SLEEP:   WaveConfig(layerCount: 3, frequency: 0.25, amplitude: 18, phaseSpeed: 0.5, opacity: 0.65)
RESET:   WaveConfig(layerCount: 4, frequency: 0.7, amplitude: 28, phaseSpeed: 1.2, opacity: 0.80)
WALKING: WaveConfig(layerCount: 3, frequency: 1.1, amplitude: 22, phaseSpeed: 2.0, opacity: 0.75)
```

### Micro-animasyonlar
```
Buton tap:          scaleEffect(0.94, anchor: .center) → 1.0 — spring(0.3, 0.7)
Ses kart seçimi:    scaleEffect(1.03) + glow artışı → 300ms
Zamanlayıcı tick:   Rakam → scale(0.95) → 1.0, opacity dip — 100ms
Otomatik tetik:     Pulsing green dot, animasyonlu ripple (3 katman)
Başlatma:           Buton → scale(1.15) → 1.0 + haptic + glow burst
Durdurma:           Glow → sıfır + scale(0.9) → 1.0 + soft haptic
```

### Zamanlayıcı Göstergesi
```
Daire progress ring:
  Stroke: 2pt, aksan rengi, lineCap: .round
  Animasyon: trim(from: 0, to: progress) — her saniye smooth
  Arka ring: %8 beyaz

Merkezdeki rakam:
  SF Mono 96pt
  Her dakika geçişte: blur(0→3→0) + opacity(1→0.3→1) — 400ms
```

---

## 7. Premium İlk Açılış Deneyimi

### Splash Sequence (uygulama ilk açıldığında, her seferinde değil)
```
0.0s  — Siyah ekran
0.3s  — Stillway logosu (SF Symbols "waveform" büyük, merkez) fade-in
0.8s  — Logo altında bir dalga animasyonu başlar
1.4s  — Logo yavaşça yukarı kayar, ana ekrana geçiş başlar
1.8s  — Ana ekran tam görünür
```

### Onboarding (3 tam ekran, kaydırmasız)
```
Sayfa 1 — "Seni Tanımak İstiyoruz"
  Arka plan: COMMUTE gradyeni (bağlamı hissettir)
  Animasyon: Metro silueti + dalga
  Başlık: "Stillway seni öğreniyor."
  Alt metin: "Nerede olduğunu, ne yaptığını anlıyor.
               Sen hiçbir şey seçmeden doğru müziği açıyor."
  Buton: "Konuma İzin Ver" (büyük pill buton)

Sayfa 2 — "Kulaklık Tak, Gerisi Bize Kalır"
  Arka plan: FOCUS gradyeni
  Animasyon: Kulaklık + waveform pulse
  Başlık: "Telefonu kaldır."
  Alt metin: "AirPods'unu taktığında ve bir durağa yaklaştığında
               Stillway otomatik olarak başlar."
  Buton: "Kısayolu Ayarla" (opsiyonel, atlayabilir)
  Alt link: "Şimdi değil →"

Sayfa 3 — "Hazırsın"
  Arka plan: Tüm bağlam renklerinin karışımı (animated mesh)
  Animasyon: Dalga büyüyüp ekranı kaplıyor
  Başlık: "İyi yolculuklar."
  Buton: "Başla" → ana ekrana geçiş (sweep animasyon)
```

---

## 8. Lokalizasyon Sistemi

### Desteklenen Diller
```
TR  — Türkçe        (birincil — Türkiye App Store)
JA  — 日本語         (birincil — Japonya App Store)
EN  — English       (birincil — ABD + İngiltere App Store)
FR  — Français      (birincil — Fransa App Store)
EN-GB — English UK  (İngiltere için ince farklar)
```

### Otomatik Dil Algılama
```swift
// Cihaz dil ayarından otomatik
Locale.current.language.languageCode → dil seç

// Kullanıcı Ayarlar > Dil seçeneğiyle override edebilir
// Seçim UserDefaults'a kaydedilir
// Uygulama yeniden başlatma GEREKMEZ — tüm görünümler reactive
```

### Tüm Katmanlarda Lokalizasyon
```
✅ UI metinleri (Localizable.strings)
✅ Ses adları (her dilde yerel isim)
✅ Bağlam adları (COMMUTE → YOLCULUK / 通勤 / TRAJET / COMMUTE)
✅ Bildirimler ("Yolculuk başlatılsın mı?" vs "通勤を開始しますか？")
✅ Onboarding metinleri
✅ Ayarlar etiketleri
✅ Yer etiketleri (Ev/家/Home/Maison)
✅ App Store açıklaması (5 dil ayrı metadata)
✅ Hata mesajları
✅ Shortcut isimleri (Siri)
```

### Anahtar Çeviri Tablosu

| Anahtar | TR | JA | EN | FR |
|---------|-----|-----|-----|-----|
| ctx_commute | Yolculuk | 通勤 | Commute | Trajet |
| ctx_focus | Odak | 集中 | Focus | Concentration |
| ctx_sleep | Uyku | 睡眠 | Sleep | Sommeil |
| ctx_reset | Dinlenme | リセット | Reset | Pause |
| ctx_walking | Yürüyüş | 散歩 | Walking | Marche |
| btn_start | Başlat | 開始 | Start | Démarrer |
| btn_stop | Durdur | 停止 | Stop | Arrêter |
| auto_badge | Otomatik | 自動 | Auto | Auto |
| place_home | Ev | 家 | Home | Maison |
| place_work | İş | 職場 | Work | Bureau |
| place_library | Kütüphane | 図書館 | Library | Bibliothèque |
| place_cafe | Kafe | カフェ | Café | Café |
| place_gym | Spor Salonu | ジム | Gym | Salle de sport |
| notif_commute | Yolculuk başlatılsın mı? | 通勤を開始しますか？ | Start commute? | Démarrer le trajet? |
| notif_sleep | Uyku modu başlatılsın mı? | 睡眠モードを開始しますか？ | Start sleep mode? | Démarrer le mode sommeil? |
| onboard_title1 | Seni Tanımak İstiyoruz | あなたを知りたい | Getting to Know You | Apprenons à vous connaître |
| pro_cta | Pro'ya Geç | Proにアップグレード | Go Pro | Passer à Pro |

### Ses Adları (Lokalize)

| ID | TR | JA | EN | FR |
|----|-----|-----|-----|-----|
| tokyo_metro | Tokyo Metrosu | 東京メトロ | Tokyo Metro | Métro de Tokyo |
| shinkansen | Shinkansen | 新幹線 | Shinkansen | Shinkansen |
| paris_metro | Paris Metrosu | パリのメトロ | Paris Métro | Métro Parisien |
| istanbul_ferry | İstanbul Vapuru | イスタンブールのフェリー | Istanbul Ferry | Ferry d'Istanbul |
| tokyo_rain | Tokyo Yağmuru | 東京の雨 | Tokyo Rain | Pluie de Tokyo |
| deep_train | Derin Tren | 深い列車 | Deep Train | Train Profond |
| night_cafe | Gece Kafesi | 夜のカフェ | Night Café | Café Nocturne |
| minka_library | Minka Kütüphanesi | 民家の書斎 | Minka Library | Bibliothèque Minka |
| kyoto_bamboo | Kyoto Bambusu | 京都の竹林 | Kyoto Bamboo | Bambous de Kyoto |
| temple_bell | Tapınak Çanı | 寺の鐘 | Temple Bell | Cloche du Temple |
| rain_window | Yağmurlu Pencere | 窓の雨 | Rain Window | Pluie sur Vitre |
| night_forest | Gece Ormanı | 夜の森 | Night Forest | Forêt Nocturne |

---

## 9. App İkonu

```
Tasarım konsepti:
  Siyah zemin
  Merkez: SF Symbol "waveform" — gradient fill (lacivert → mor)
  veya: Özel dalga formu ikonu (3 katman, farklı yükseklik)

Alternatif:
  Dalga + sessiz "S" harfi birleşimi
  (Stillway logomark)

Boyutlar: 1024×1024px, köşe yuvarlama App Store otomatik uygular
Format: PNG, şeffaf arka plan yok (solid siyah)
```

---

## 10. Trend Kontrol Listesi (2026 iOS)

```
✅ Animated mesh gradient arkaplan
✅ Glassmorphism kartlar (.ultraThinMaterial)
✅ Context-aware renk geçişleri (tam ekran sweep)
✅ Multi-layer glow efekti butonlarda
✅ Spring physics tüm animasyonlarda
✅ Haptic feedback her etkileşimde
✅ matchedGeometryEffect seçim geçişleri
✅ Custom bottom sheet (native .sheet değil)
✅ SF Symbols 6 kullanımı (animasyonlu semboller)
✅ Dynamic Island entegrasyonu (aktif oturum)
✅ Circular progress ring (zamanlayıcı)
✅ Pulse animasyonu (otomatik tetiklenme göstergesi)
✅ Parallax derinlik (dalga katmanları farklı hızda hareket)
✅ Monospace zamanlayıcı (SF Mono)
✅ Dark-first (dark-only) tasarım
✅ Large title → compact geçişi kaydırmada
✅ Context-sensitive status bar rengi
```

---

## 11. Ekranlar Arası Geçiş Haritası

```
Splash
  ↓ (1.8s otomatik)
Onboarding Sayfa 1
  ↓ tap
Onboarding Sayfa 2
  ↓ tap
Onboarding Sayfa 3
  ↓ tap "Başla"
Ana Ekran ← — — — — — — — — — — — — ←
  |                                   |
  ├→ Settings Sheet (gear tap)        |
  |     ↓ "X" veya swipe down        |
  |   Ana Ekran                       |
  |                                   |
  ├→ Places Sheet (pin tap)           |
  |     ↓ yer seç → label sheet      |
  |   Ana Ekran                       |
  |                                   |
  └→ Sound Mixer Sheet (ses tap)      |
        ↓                             |
      Ana Ekran — — — — — — — — — — →
```

---

## 12. Eksiklikler ve Düzeltmeler (BUILD_PLAN'a ek)

### Önceki Planda Eksik Olanlar

1. **LocalizationManager** → yeni dosya: `Core/Localization/LocalizationManager.swift`
   - `@AppStorage("selectedLanguage")` ile dil saklama
   - `Bundle.main.localizedString(forKey:)` wrapper
   - `LanguageCode` enum: tr, ja, en, fr

2. **ThemeEngine** → yeni dosya: `Core/Theme/ThemeEngine.swift`
   - `@Observable` sınıf, context değişince tüm renkleri günceller
   - `ContextGradient` struct (start, mid, end, accent, glow renklerini tutar)
   - `WaveConfig` struct (frequency, amplitude, phase speed)
   - `AnimatedMeshGradient` view modifier

3. **HapticEngine** (genişletilmiş)
   - Mevcut breathing için değil, her UI etkileşimi için de
   - `HapticEngine.tap()`, `.select()`, `.success()`, `.warning()`

4. **DynamicIslandManager** → yeni dosya: `Core/DynamicIsland/LiveActivityManager.swift`
   - `ActivityKit` + `WidgetKit`
   - Compact: dalga ikonu + kalan süre
   - Expanded: ses adı + mod + zamanlayıcı

5. **ContextTransitionEngine** → `Core/Context/ContextTransitionEngine.swift`
   - Renk geçişi animasyonlarını yönetir
   - Dalga konfigürasyon geçişini koordine eder

6. **AppIconProvider** — programmatic alternatif ikonlar (Pro için opsiyonel)

7. **AccessibilityEngine**
   - VoiceOver desteği (tüm görünümler label'li)
   - Reduce Motion: dalga animasyonu → statik gradient
   - Reduce Transparency: materyal efektler → solid

8. **WidgetKit**
   - Lock Screen widget: başlat/durdur single tap
   - Home Screen widget: aktif ses + süre

### BUILD_PLAN Sırası Güncellemesi

```
Aşama 0 (önce eklendi): ThemeEngine + LocalizationManager iskelet
Aşama 1: Audio + temel UI (ThemeEngine ile)
Aşama 2: Lokasyon + Transit
Aşama 3: Bağlam zekası
Aşama 4: DynamicIsland + Widget + Haptic genişletmesi
Aşama 5: Ses dosyaları + Store + TestFlight
```

---

*DESIGN_SYSTEM.md, BUILD_PLAN.md ile birlikte kullanılır.*  
*Versiyon: 1.0 | Ağustos 2026*
