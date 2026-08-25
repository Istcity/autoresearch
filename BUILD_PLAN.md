# Stillway — Cursor Agent Build Plan v2.0

Bu döküman Mac'teki Cursor Agent'a verilecek tam uygulama geliştirme planıdır.
PRODUCT_SPEC.md ve DESIGN_SYSTEM.md ile birlikte kullan.

---

## Genel Bilgi

**Proje:** Stillway — Ambient Life Companion  
**Platform:** iOS 17+  
**Swift:** 5.10 · SwiftUI · Swift Concurrency (async/await)  
**Xcode:** 16+  
**Backend:** YOK — tamamen offline, cihaz üzerinde  
**Hedef ülkeler:** TR · JP · US · FR · UK  
**Diller:** Türkçe · 日本語 · English · Français  

---

## Tam Klasör Yapısı

```
Stillway/
├── Stillway.xcodeproj
│
├── Stillway/                          ← Ana hedef
│   │
│   ├── App/
│   │   ├── StillwayApp.swift          ← @main, SwiftData container, DI root
│   │   └── AppDelegate.swift          ← AVAudioSession, background task setup
│   │
│   ├── Core/
│   │   │
│   │   ├── Audio/
│   │   │   └── AudioEngine.swift      ← AVAudioEngine, 2 kanal, Journey Arc, fade
│   │   │
│   │   ├── Location/
│   │   │   ├── LocationManager.swift       ← CLLocationManager, izin, CLVisit
│   │   │   ├── GeofenceManager.swift        ← Dinamik 18-geofence, refresh
│   │   │   └── StationDatabase.swift        ← JSON yükleme, spatial grid index
│   │   │
│   │   ├── Context/
│   │   │   ├── ContextEngine.swift          ← Ana beyin: tüm sinyalleri birleştirir
│   │   │   ├── ContextTransitionEngine.swift ← Renk/dalga geçiş animasyonları
│   │   │   ├── VisitTracker.swift           ← CLVisit → UserPlace öğrenimi
│   │   │   ├── MotionClassifier.swift       ← CMMotionActivity + CoreML
│   │   │   └── SleepDetector.swift          ← Ev + saat + pozisyon tespiti
│   │   │
│   │   ├── Theme/
│   │   │   ├── ThemeEngine.swift            ← @Observable, context → renk/dalga
│   │   │   ├── ContextGradient.swift        ← Renk paketleri (6 bağlam × renk seti)
│   │   │   └── WaveConfig.swift             ← Dalga parametreleri (freq, amp, phase)
│   │   │
│   │   ├── Localization/
│   │   │   └── LocalizationManager.swift    ← Dil seçimi, reactive string lookup
│   │   │
│   │   ├── Haptics/
│   │   │   ├── HapticEngine.swift           ← tap/select/success/warning
│   │   │   └── HapticBreathingEngine.swift  ← CHHapticEngine, Box Breathing
│   │   │
│   │   ├── DynamicIsland/
│   │   │   └── LiveActivityManager.swift    ← ActivityKit, compact/expanded
│   │   │
│   │   └── Store/
│   │       └── PurchaseManager.swift        ← StoreKit 2, $4.99 Pro
│   │
│   ├── Models/
│   │   ├── AppContext.swift            ← enum: commute/focus/sleep/reset/walking/deepwork
│   │   ├── Sound.swift                 ← Sound struct + 12 seslik kütüphane
│   │   ├── Station.swift               ← Transit istasyon modeli
│   │   ├── SwiftDataModels.swift       ← UserPlace, CommutSession, UserPreferences
│   │   └── LanguageCode.swift          ← enum: tr/ja/en/fr
│   │
│   ├── Views/
│   │   ├── ContentRootView.swift       ← Onboarding/Ana ekran yönlendirici
│   │   │
│   │   ├── Main/
│   │   │   ├── MainView.swift          ← Ana ekran (tam immersive)
│   │   │   ├── WaveformView.swift      ← Canvas, çok katmanlı, parallax
│   │   │   ├── MeshBackgroundView.swift ← Animated mesh/radial gradient
│   │   │   ├── ContextBadge.swift      ← Mod rozeti + "OTOMATİK" pulse
│   │   │   ├── StartStopButton.swift   ← Glow efektli büyük buton
│   │   │   ├── TimerRing.swift         ← Circular progress + SF Mono rakam
│   │   │   ├── TimerSelector.swift     ← Pill row: 15/30/45
│   │   │   └── SoundMixerRow.swift     ← Ses seçici + hacim kaydırıcı
│   │   │
│   │   ├── Sheets/
│   │   │   ├── SoundPickerSheet.swift  ← Ses kütüphanesi listesi
│   │   │   ├── PlacesSheet.swift       ← Öğrenilen yerler + etiket düzenleme
│   │   │   ├── PlaceLabelSheet.swift   ← "Burası ne?" — 3. ziyarette gösterilir
│   │   │   └── SettingsSheet.swift     ← Tüm ayarlar + dil seçimi + Pro satın alma
│   │   │
│   │   └── Onboarding/
│   │       ├── OnboardingView.swift    ← 3 sayfa yöneticisi
│   │       ├── OnboardPage1.swift      ← Lokasyon izni
│   │       ├── OnboardPage2.swift      ← Shortcuts kurulum
│   │       └── OnboardPage3.swift      ← "Hazırsın" + başlat
│   │
│   ├── Components/
│   │   ├── GlassCard.swift             ← Reusable .ultraThinMaterial kart
│   │   ├── PillButton.swift            ← Glow efektli pill buton
│   │   ├── GradientText.swift          ← LinearGradient fill metin
│   │   ├── PulsingDot.swift            ← Animasyonlu yeşil nokta (auto mode)
│   │   └── CustomBottomSheet.swift     ← Native .sheet yerine özel implementasyon
│   │
│   ├── Modifiers/
│   │   ├── ContextThemeModifier.swift  ← View modifier: ThemeEngine'e bağlar
│   │   ├── HapticButtonStyle.swift     ← Her butona haptic feedback
│   │   └── ReduceMotionModifier.swift  ← Accessibility: animasyon azaltma
│   │
│   └── Resources/
│       ├── Sounds/                     ← 12 × .m4a ses dosyası
│       ├── stations.json               ← ~56.000 transit durağı
│       ├── TrainClassifier.mlmodel     ← CoreML tren tespiti
│       ├── Assets.xcassets             ← Renkler, ikonlar, app ikonu
│       └── Localizable.xcstrings       ← Tüm çeviriler (Xcode 15+ format)
│
├── StillwayWidgets/                    ← Widget hedefi
│   ├── LockScreenWidget.swift          ← Başlat/dur, tek tap
│   └── HomeScreenWidget.swift          ← Aktif ses + süre
│
└── scripts/
    ├── build_station_db.py             ← GTFS → stations.json
    └── download_gtfs.sh                ← 5 ülke veri indirici
```

---

## Swift Package Bağımlılıkları

```
GRDB.swift    https://github.com/groue/GRDB.swift    ~> 6.29
```

Sadece bu. Başka üçüncü taraf paket yok.

---

## Xcode Capabilities

```
✅ Background Modes:
   • Audio, AirPlay, and Picture in Picture
   • Location updates
   • Background fetch
✅ Push Notifications (opsiyonel, yerel bildirimler için)
✅ WidgetKit (StillwayWidgets hedefi için)
```

---

## Info.plist Zorunlu Anahtarlar

```xml
NSLocationAlwaysAndWhenInUseUsageDescription
NSLocationWhenInUseUsageDescription
NSLocationAlwaysUsageDescription
NSMotionUsageDescription
UIBackgroundModes: [audio, location, fetch]
UIUserInterfaceStyle: Dark
```

---

## Modüllerin Teknik Detayları

---

### ThemeEngine
```swift
@Observable final class ThemeEngine {
    var currentContext: AppContext = .unknown
    var gradient: ContextGradient { ContextGradient.for(currentContext) }
    var waveConfig: WaveConfig { WaveConfig.for(currentContext) }

    func transition(to context: AppContext) async {
        // 1. Dalga amplitude → 0 (0.4s)
        // 2. Arkaplan rengi sweep (0.6s)
        // 3. Dalga amplitude → normal (0.8s spring)
        // 4. Rozet güncellenir
    }
}

struct ContextGradient {
    let bgColors: [Color]       // [start, mid, end]
    let waveColors: [Color]     // gradient dalga fill
    let accentColor: Color
    let glowColor: Color        // shadow için
    let cardBackground: Color   // .ultraThinMaterial üstü tint
}

struct WaveConfig {
    let layerCount: Int
    let frequency: Double
    let amplitude: Double
    let phaseSpeed: Double
    let opacity: Double
}
```

**6 bağlam × renk değerleri DESIGN_SYSTEM.md Bölüm 2'de tanımlıdır.**

---

### LocalizationManager
```swift
enum LanguageCode: String, CaseIterable {
    case tr = "tr", ja = "ja", en = "en", fr = "fr"
    var displayName: String { ... }
    var locale: Locale { Locale(identifier: rawValue) }
}

@Observable final class LocalizationManager {
    @AppStorage("selectedLanguage") var selectedLanguage: String = autoDetect()
    
    var current: LanguageCode { LanguageCode(rawValue: selectedLanguage) ?? .en }
    
    func string(_ key: String) -> String {
        // Bundle üzerinden dil bazlı çözümleme
    }
    
    static func autoDetect() -> String {
        // Locale.current.language.languageCode → hedef 5 dilden biri
        // Eşleşmezse "en" fallback
    }
}
```

Tüm String'ler `lm.string("key")` formatıyla — sabit metin yok.  
`Localizable.xcstrings` Xcode 15 formatı kullan (JSON temelli, 4 dil tek dosyada).

---

### AudioEngine
- `AVAudioEngine` + 2 × `AVAudioMixerNode` + 1 `masterMixer`
- Seamless loop: `scheduleBuffer(_:options:.loops)`
- Fade: timer tabanlı 60 adım, lineer interpolasyon
- Journey Arc: `Aşama 0–15%` arrival (%65 vol) → `15–85%` deep (%100) → `85–100%` reset (fade)
- Route change: kulaklık çıkınca → `stop(fadeDuration: 0.5)`
- `headphonesConnected` Notification → ContextEngine yakalar

---

### GeofenceManager
```
Maksimum aktif geofence: 18 (iOS limiti 20, 2 tampon)
Güncelleme tetikleyicisi: significant location change (pil dostu)
Radius: metro/tram: 80m · rail/ferry: 150m
Collision: aynı koordinatta 2 istasyon → büyük olanı kullan
Uygulama kapalıyken: iOS yeniden başlatır (CLLocationManager background delivery)
```

---

### ContextEngine (Öncelik Sırası)

```swift
func evaluate(signals: ContextSignals) -> ContextDecision {
    // 1. Transit: geofence + tren CoreML → commute (en yüksek öncelik)
    // 2. Automotive CMMotion → commute
    // 3. Uyku koşulları → sleep
    // 4. Bilinen iş/kütüphane yeri + çalışma saati → focus
    // 5. Kısa ziyaret / yürüyüş → reset
    // 6. Hiç sinyal → unknown
}

struct ContextSignals {
    var geofenceStationID: String?
    var motionActivity: CMMotionActivity?
    var trainProbability: Double         // CoreML çıktısı
    var currentVisit: CLVisit?
    var nearestPlace: UserPlace?
    var headphonesConnected: Bool
    var currentHour: Int
    var isPhoneHorizontal: Bool          // accelerometer Z ≈ 1g
}

struct ContextDecision {
    var context: AppContext
    var shouldAutoStart: Bool
    var triggerType: TriggerType         // .automatic / .suggested / .manual
    var suggestedSoundID: String
    var confidence: Double               // 0–1
}
```

---

### VisitTracker
```swift
// CLVisit geldiğinde:
func process(visit: CLVisit) {
    // 1. Mevcut UserPlace'lerle mesafe karşılaştır (<100m eşleşme)
    // 2. Eşleşme bulundu → visitCount++, lastSeen güncelle
    // 3. Eşleşme yok → yeni UserPlace oluştur
    // 4. visitCount == 3 → PlaceLabelingPrompt yayınla
    // 5. visitCount >= 5 + kullanıcı onayı → autoStartEnabled = true
    // homeConfidence: gece saati (23-06) ziyaretlerin oranı
}
```

---

### SleepDetector
```swift
// Her 60 saniyede bir kontrol (LocationManager heartbeat ile)
func checkSleepConditions() {
    guard preferences.sleepModeEnabled else { return }
    let hour = Calendar.current.component(.hour, from: Date())
    guard hour >= preferences.sleepStartHour || hour < preferences.sleepEndHour else { return }
    guard let home = userPlaces.first(where: { $0.label == .home }) else { return }
    guard home.distance(to: currentLocation) < 150 else { return }
    guard motionActivity?.stationary == true else { return }
    guard isPhoneHorizontal else { return }
    // Tüm koşullar sağlandı → SleepPrompt yayınla
}
```

---

### HapticEngine
```swift
final class HapticEngine {
    static func tap()     { UIImpactFeedbackGenerator(style: .rigid).impactOccurred() }
    static func select()  { UISelectionFeedbackGenerator().selectionChanged() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func warning() { UINotificationFeedbackGenerator().notificationOccurred(.warning) }
    static func soft()    { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
}
```

---

### LiveActivityManager (Dynamic Island)
```swift
// ActivityKit + WidgetKit
// Widget bundle ayrı hedef (StillwayWidgets)

struct StillwayActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var contextName: String      // "YOLCULUK"
        var soundName: String        // "Tokyo Metro"
        var remainingSeconds: Int
        var accentColorHex: String
    }
}

// Compact: dalga SF Symbol + "24:17"
// Expanded: ses adı + mod + progress ring
// Minimal: dalga pulse animasyonu
```

---

## SwiftUI Ekranları — Detaylı Spesifikasyon

---

### MainView

```
Tam ekran ZStack:
  └── MeshBackgroundView()          ← animasyonlu gradient (en alt)
  └── VStack(spacing: 0) {
        Spacer()
        ContextBadge()              ← üst, merkez
          .padding(.top, 60)
        Spacer()
        WaveformView()              ← ekranın %35'i
        Spacer()
        StartStopButton()           ← 80pt circle, glow
          .padding(.bottom, 32)
        TimerSelector()             ← pill row
          .padding(.bottom, 20)
        SoundMixerRow()             ← glass card
          .padding(.horizontal, 24)
          .padding(.bottom, 48)
      }
  └── HStack {                      ← sol/sağ üst ikonlar
        PlacesButton()              ← sol üst
        Spacer()
        SettingsButton()            ← sağ üst
      }
      .padding(.top, 56)
      .padding(.horizontal, 24)
```

---

### WaveformView (Canvas)

```swift
// TimelineView(.animation) içinde Canvas
// Her frame'de:
//   Her katman için: sin(x * frequency + phase + layerOffset) × amplitude
//   Phase += phaseSpeed × deltaTime
//   Katmanlar farklı opacity ve y-offset (parallax)
//   Fill: LinearGradient(themeEngine.gradient.waveColors)
//   Blend mode: .screen veya .plusLighter (katmanlar arası)

// Reduce Motion aktifse:
//   Canvas yerine statik LinearGradient rectangle
```

---

### MeshBackgroundView

```swift
// iOS 18+:
MeshGradient(width: 3, height: 3, points: animatedPoints, colors: bgColors)

// iOS 17 fallback:
RadialGradient(colors: bgColors, center: .center, startRadius: 0, endRadius: 400)
  .overlay(LinearGradient(colors: [bgColors[0], .clear], startPoint: .top, endPoint: .bottom))

// Mesh noktaları TimelineView ile çok yavaş hareket eder:
// period: 12 saniye, amplitude: ±0.08 (normalize koordinat)
```

---

### StartStopButton

```swift
ZStack {
    // Dış glow (2 katman)
    Circle()
        .fill(theme.glowColor.opacity(0.15))
        .frame(width: 120)
        .blur(radius: 20)
    Circle()
        .fill(theme.glowColor.opacity(0.08))
        .frame(width: 160)
        .blur(radius: 40)
    
    // Buton gövdesi
    Circle()
        .fill(theme.accentColor.opacity(0.18))
        .frame(width: 80)
        .overlay(
            Circle().stroke(
                LinearGradient(colors: [theme.accentColor.opacity(0.6), .clear]),
                lineWidth: 1
            )
        )
    
    // İkon
    Image(systemName: isPlaying ? "waveform" : "play.fill")
        .font(.system(size: 28, weight: .medium))
        .foregroundStyle(theme.accentColor)
        .symbolEffect(.variableColor, isActive: isPlaying)  // iOS 17+
}
.scaleEffect(isPressed ? 0.94 : 1.0)
.animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
.onTapGesture { handleTap() }
.pressEvents(onPress: { isPressed = true }, onRelease: { isPressed = false })
```

---

### SettingsSheet

```
Bölümler:
  GENEL
    [Toggle] Bağlam Tespiti
    [Toggle] Uyku Modu
    [Picker] Uyku Başlangıcı: 20:00–24:00
    [Toggle] Haptik Nefes Rehberi
  
  DİL
    [Picker] Dil: Türkçe / 日本語 / English / Français
    Not: "Dil değişikliği anında geçerli olur."
  
  PRO
    [Section] Pro avantajları listesi (ikon + metin)
    [Button] Pro'ya Geç — $4.99 (büyük, glow efektli)
    [Button] Satın Alımı Geri Yükle
  
  HAKKINDA
    Versiyon, gizlilik politikası linki
```

---

### PlaceLabelSheet ("Burası ne?" — 3. ziyarette)

```
Başlık: "Buraya 3 kez geldiniz."
Alt:    "Bu yeri tanımlarsanız Stillway otomatik mod açabilir."

Seçenekler (grid, 2 sütun):
  🏠 Ev     💼 İş
  📚 Kütüphane  ☕ Kafe
  🏋️ Spor  ⭐ Diğer

Her seçenek: GlassCard + büyük SF Symbol + yerelleştirilmiş isim
Seçim sonrası: checkmark animasyonu → sheet kapanır → "Ayarlandı!" toast
```

---

## Lokalizasyon Dosyası Yapısı

`Localizable.xcstrings` — Xcode 15+ formatı, tüm diller tek dosyada:

```json
{
  "sourceLanguage": "en",
  "strings": {
    "ctx_commute": {
      "localizations": {
        "tr": { "stringUnit": { "state": "translated", "value": "Yolculuk" }},
        "ja": { "stringUnit": { "state": "translated", "value": "通勤" }},
        "en": { "stringUnit": { "state": "translated", "value": "Commute" }},
        "fr": { "stringUnit": { "state": "translated", "value": "Trajet" }}
      }
    }
  }
}
```

**Tam çeviri tablosu:** DESIGN_SYSTEM.md Bölüm 8'de.  
Toplam anahtar sayısı: ~80 anahtar × 4 dil = ~320 çeviri.

---

## Assets.xcassets İçeriği

```
AppIcon.appiconset/       ← 1024×1024 app ikonu (siyah + dalga gradient)
Colors/
  ├── ctxCommuteBg        ← #020818
  ├── ctxFocusBg          ← #020C18
  ├── ctxSleepBg          ← #050010
  ├── ctxResetBg          ← #180800
  ├── ctxWalkingBg        ← #001208
  ├── ctxDeepWorkBg       ← #150000
  └── (tüm aksan renkleri)
Symbols/
  └── (custom SF Symbol varyantları gerekirse)
```

---

## stations.json Üretimi

`scripts/build_station_db.py` çalıştır:

```bash
pip install requests pandas
python scripts/build_station_db.py
# → Stillway/Resources/stations.json üretir (~20–30 MB)
```

**GTFS Kaynakları:**

| Ülke | Kaynak | Not |
|------|--------|-----|
| JP | https://api.odpt.org/api/v4/files/TokyoMetro/data/TokyoMetro-Train-GTFS.zip | ODPT API key gerekli (ücretsiz kayıt) |
| US | https://feeds.nyc.gov/NYC_GTFS.zip | Ücretsiz |
| FR | https://data.iledefrance-mobilites.fr (IDFM API) | Ücretsiz kayıt |
| GB | https://data.bus-data.dft.gov.uk/timetable/download/gtfs-file/all/ | BODS, ücretsiz |
| TR | https://data.ibb.gov.tr/tr/dataset/istanbul-ulasim-guzergahlari | İBB açık veri |

**Filtreler:** transit_type IN (metro, rail, tram, ferry) · büyük şehir sınırları içinde

---

## TrainClassifier.mlmodel Üretimi

```python
# Create ML ile:
# 1. Training data: accelerometer + gyroscope CSV kayıtları
#    (yer altı metro, yürüyüş, araç, oturma — 4 sınıf)
# 2. MLActivityClassifier eğit
# 3. .mlmodel olarak export et → Stillway/Resources/

# Geliştirme sürecinde:
# CMMotionActivity.automotive → commute fallback kullan
# CoreML model hazır olduğunda swap et
```

---

## Geliştirme Aşamaları (Mac Cursor Agent İçin)

### Aşama 0 — Temel Altyapı (Önce Bu)
1. Xcode projesi oluştur (SwiftUI, iOS 17, SPM: GRDB ekle)
2. Widget hedefini ekle (StillwayWidgets)
3. `ThemeEngine` + `ContextGradient` + `WaveConfig` yaz
4. `LocalizationManager` + `Localizable.xcstrings` iskelet (4 dil, ~20 anahtar)
5. `LanguageCode` enum + `AppContext` enum yaz
6. `Assets.xcassets` renk setlerini ekle
7. Simülatörde: `ThemeEngine` bağlam değişince renk değişiyor mu? ✓

### Aşama 1 — Ses ve Temel UI
1. `AudioEngine` yaz ve test et (simülatörde — ses çalar mı?)
2. `Sound` modeli + 12 ses tanımı (placeholder .m4a dosyaları)
3. `MeshBackgroundView` (iOS 17 fallback ile)
4. `WaveformView` (Canvas, `TimelineView`, 3 katman)
5. `StartStopButton` (glow efektiyle)
6. `TimerSelector` (pill row, matchedGeometryEffect)
7. `MainView` iskelet — hepsi birleşiyor
8. Simülatörde çalıştır, ekran görüntüsü al ✓

### Aşama 2 — Onboarding ve Ayarlar
1. `OnboardingView` (3 sayfa, gradient arkaplanlar)
2. `SettingsSheet` (dil seçimi çalışıyor mu?)
3. `LocalizationManager` tam implementasyon
4. Dil değiştirince UI anında değişiyor mu test et ✓
5. `SwiftDataModels` (UserPreferences, UserPlace, CommutSession)
6. `ContentRootView` (onboarding → main geçiş)

### Aşama 3 — Lokasyon ve Transit
1. `LocationManager` (izin, CLVisit, significant change)
2. `StationDatabase` (sample data ile başla)
3. `GeofenceManager` (dinamik 18-geofence)
4. `VisitTracker` (CLVisit işleme, UserPlace öğrenimi)
5. `PlaceLabelSheet` görünümü
6. Gerçek cihazda test et (simülatör geofence desteklemiyor) ✓

### Aşama 4 — Bağlam Zekası
1. `MotionClassifier` (CMMotionActivityManager)
2. `SleepDetector`
3. `ContextEngine` (tüm sinyaller birleşiyor)
4. `ContextTransitionEngine` (renk sweep animasyonu)
5. `ContextBadge` + "OTOMATİK" pulse animasyonu
6. Otomatik başlatma akışı uçtan uca test ✓

### Aşama 5 — Haptics, Dynamic Island, Widget
1. `HapticEngine` (tüm UI etkileşimleri)
2. `HapticBreathingEngine` (Box Breathing)
3. `LiveActivityManager` (ActivityKit)
4. `StillwayWidgets` hedefi (Lock Screen + Home Screen)
5. Gerçek cihazda Dynamic Island test ✓

### Aşama 6 — Satın Alma ve Finalizasyon
1. `PurchaseManager` (StoreKit 2)
2. `SettingsSheet` Pro satın alma akışı
3. Pro özellik kilitleri (SecondarySound, AutoStart, PlaceLabeling)
4. `build_station_db.py` çalıştır, `stations.json` üret
5. Ses dosyaları final haline getir (12 × .m4a)
6. `TrainClassifier.mlmodel` entegrasyon
7. Accessibility: VoiceOver, Reduce Motion, Reduce Transparency
8. TestFlight beta ✓

### Aşama 7 — App Store
1. App Store Connect metadata (5 dil × açıklama + ekran görüntüleri)
2. ASO anahtar kelimeler (TR/JP/EN/FR)
3. Gizlilik etiketi (App Privacy)
4. App İkonu finali
5. Yayın ✓

---

## Cursor Agent'a Verilecek İlk Komut (Kopyala-Yapıştır)

```
Bu üç dökümanı oku:
• PRODUCT_SPEC.md
• DESIGN_SYSTEM.md  
• BUILD_PLAN.md

Stillway adlı iOS uygulamasını Swift/SwiftUI ile geliştir.

Aşama 0'dan başla:
1. Xcode projesi oluştur (iOS 17+, SwiftUI, GRDB paketi)
2. ThemeEngine + 6 bağlam renk seti (DESIGN_SYSTEM.md Bölüm 2)
3. LocalizationManager + Localizable.xcstrings (4 dil: TR/JA/EN/FR)
4. AppContext + LanguageCode enum'ları

Aşama 0 tamamlandığında simülatör ekran görüntüsü paylaş,
Aşama 1'e geçelim.
```

---

## Kill / Scale Kriterleri

```
SCALE:
  D7 Retention ≥ %18
  Pro dönüşüm ≥ %8
  Otomatik tetikleme opt-in ≥ %30

KILL:
  D7 Retention < %12 (ilk 200 kullanıcı)
  Pro dönüşüm < %4 (60 gün)
  Otomatik tetikleme opt-in < %25
```

---

*Versiyon: 2.0 | Ağustos 2026 | DESIGN_SYSTEM.md v1.0 ile eşzamanlı*
