# Stillway — Eksikler ve Yapılacaklar

Bu dosya Mac Cursor Agent'ına verilecek görev listesidir.
PRODUCT_SPEC.md + DESIGN_SYSTEM.md + BUILD_PLAN.md ile birlikte kullan.

---

## Mevcut Durum

Repoda şu an yalnızca planlama dökümanları var:
- `PRODUCT_SPEC.md` — ürün vizyonu
- `DESIGN_SYSTEM.md` — renk, tipografi, animasyon sistemi
- `BUILD_PLAN.md` — klasör yapısı, modül detayları, aşamalar

**Xcode projesi YOK. Tek satır Swift kodu YOK.**

---

## Mac Cursor Agent'ının Yapacakları (Sırayla)

---

### AŞAMA 0 — Xcode Projesi ve Altyapı

**Görev:** Xcode projesi oluştur, temel konfigürasyonu yap.

```
✅ Yapılacak 1: Xcode projesi oluştur
   - Proje adı: Stillway
   - Interface: SwiftUI
   - Language: Swift
   - iOS Deployment Target: 17.0
   - Bundle ID: com.sinannergiz.stillway

✅ Yapılacak 2: Swift Package Manager bağımlılığı ekle
   - GRDB.swift → https://github.com/groue/GRDB.swift (versiyon ~> 6.29)

✅ Yapılacak 3: Xcode Capabilities aç
   - Background Modes: Audio + Location updates + Background fetch
   - Push Notifications (yerel bildirimler için)
   - WidgetKit (StillwayWidgets hedefi için ayrı target ekle)

✅ Yapılacak 4: Info.plist anahtarları ekle
   - NSLocationAlwaysAndWhenInUseUsageDescription
   - NSLocationWhenInUseUsageDescription  
   - NSLocationAlwaysUsageDescription
   - NSMotionUsageDescription
   - UIBackgroundModes: [audio, location, fetch]
   - UIUserInterfaceStyle: Dark

✅ Yapılacak 5: StillwayWidgets adlı ayrı Widget Extension target ekle
   - Widget Extension (iOS)
   - Include Live Activity: YES

✅ Yapılacak 6: Assets.xcassets içine renkleri ekle (DESIGN_SYSTEM.md Bölüm 2)
   - Her AppContext için: bgStart, bgMid, bgEnd, accent, glow renkleri
   - Toplam 6 bağlam × 5 renk = 30 renk tanımı

✅ Yapılacak 7: App ikonu ekle (Assets.xcassets → AppIcon)
   - 1024×1024px
   - Siyah zemin + merkezdeki "waveform" SF Symbol, lacivert→mor gradient fill
```

---

### AŞAMA 1 — Model Katmanı

**Görev:** Tüm Swift model dosyalarını yaz.

```
YENİ DOSYALAR OLUŞTURULACAK:

Stillway/Models/LanguageCode.swift
  - enum LanguageCode: String, CaseIterable (tr, ja, en, fr)
  - displayName, flag, locale property'leri
  - static func detect() → cihaz dilinden otomatik seçim

Stillway/Models/AppContext.swift
  - enum AppContext: Int, Codable, Comparable (unknown=0 ... deepWork=6)
  - localizationKey, defaultSoundID, sfSymbol, defaultTimerMinutes
  - enum TriggerType: String (automatic, suggested, manual)

Stillway/Models/Sound.swift
  - struct Sound: Identifiable, Equatable, Codable
  - 12 seslik static library (tam liste BUILD_PLAN.md'de)
  - freeLibrary, sounds(for:), find(_:) helper'lar
  - enum SoundRegion: String (JP, FR, UK, US, TR, NATURE, URBAN)

Stillway/Models/Station.swift
  - struct Station: Identifiable, Codable
  - id, name, nameEn, lat, lon, country, city, type, lines
  - var coordinate: CLLocationCoordinate2D
  - var geofenceRadius: Double (metro:80m, rail/ferry:150m, bus:60m)
  - enum TransitType: String (METRO, RAIL, TRAM, FERRY, BUS, BRT)

Stillway/Models/SwiftDataModels.swift
  @Model UserPlace:
    - id, latitude, longitude, radius, labelRaw, visitCount
    - firstSeen, lastSeen, defaultSoundID, autoStartEnabled
    - homeConfidence: Double (0–1), customName: String?
    - var label: PlaceLabel (computed)
    - func distance(to: CLLocationCoordinate2D) → Double
  
  enum PlaceLabel: String (unknown/home/work/library/cafe/gym/other)
    - localizationKey, suggestedContext, sfSymbol
  
  @Model CommutSession:
    - id, startDate, endDate, contextRaw, soundID
    - fromStationID, toStationID, triggeredAutomatically, durationSeconds
    - func end()
  
  @Model UserPreferences:
    - id, contextDetectionEnabled, sleepModeEnabled
    - sleepStartHour (default 22), sleepEndHour (default 7)
    - hapticBreathingEnabled, shortcutOnboardingDone
    - isPro, onboardingCompleted, selectedLanguage
    - lastKnownLatitude, lastKnownLongitude
```

---

### AŞAMA 2 — Core/Theme Katmanı

**Görev:** ThemeEngine, ContextGradient, WaveConfig yaz.

```
Stillway/Core/Theme/ContextGradient.swift
  struct ContextGradient:
    - bgColors: [Color]     → arkaplan (3 renk)
    - waveColors: [Color]   → dalga gradient fill
    - accentColor: Color    → buton, rozet, ring
    - glowColor: Color      → buton shadow
    - cardTint: Color       → glass card tint
  
  static func gradient(for: AppContext) → ContextGradient
  
  Tüm hex değerleri DESIGN_SYSTEM.md Bölüm 2'de:
    commute:  bg #020818→#0D1B4D→#1B0D4D | wave #1B3FDB→#6B21DB→#9B59B6 | accent #4169E1
    focus:    bg #020C18→#041B2D→#062040 | wave #0A84FF→#0066CC→#00B4A0 | accent #0A84FF
    sleep:    bg #050010→#0F0226→#1A0533 | wave #5E5CE6→#7C3AED→#4C1D95 | accent #5E5CE6
    reset:    bg #180800→#2D1200→#3D1A00 | wave #FF9F0A→#FF6B35→#FF453A | accent #FF9F0A
    walking:  bg #001208→#002010→#003018 | wave #30D158→#34C759→#00BFB3 | accent #30D158
    deepWork: bg #150000→#2D0000→#3D0A0A | wave #FF453A→#FF2D20→#C0000A | accent #FF453A
    unknown:  bg #050505→#0A0A0A→#111111 | wave #48484A→#636366→#48484A | accent #8A8A8E

  Color(hex:) extension de bu dosyaya ekle.

Stillway/Core/Theme/WaveConfig.swift
  struct WaveConfig:
    - layerCount: Int, frequency: Double, amplitude: Double
    - phaseSpeed: Double, opacity: Double
  
  static func config(for: AppContext) → WaveConfig
  
  Değerler (BUILD_PLAN.md'den):
    commute:  (4, 0.9, 32, 1.8, 0.85)
    focus:    (3, 0.5, 24, 0.9, 0.75)
    sleep:    (3, 0.25, 18, 0.5, 0.65)
    reset:    (4, 0.7, 28, 1.2, 0.80)
    walking:  (3, 1.1, 22, 2.0, 0.75)
    deepWork: (4, 1.3, 36, 2.2, 0.90)
    unknown:  (2, 0.4, 16, 0.6, 0.50)

Stillway/Core/Theme/ThemeEngine.swift
  @Observable final class ThemeEngine:
    - currentContext: AppContext
    - gradient: ContextGradient  (computed)
    - waveConfig: WaveConfig     (computed)
    - isTransitioning: Bool
    - transitionAmplitude: Double
    - effectiveAmplitude: Double (computed = waveConfig.amplitude * transitionAmplitude)
    
    func transition(to: AppContext) async
      1. transitionAmplitude → 0 (0.4s easeIn)
      2. currentContext = newContext, gradient/waveConfig güncelle
      3. transitionAmplitude → 1 (0.8s spring)
    
    func apply(context: AppContext)  ← Task ile async wrapper
```

---

### AŞAMA 3 — Core/Localization

```
Stillway/Core/Localization/LocalizationManager.swift
  @Observable final class LocalizationManager:
    - currentLanguage: LanguageCode (didSet → Bundle yenile, UserDefaults kaydet)
    - func string(_ key: String) → String
    - private func loadBundle()
  
  EnvironmentKey: "lm" olarak inject edilir
    struct LocalizationManagerKey: EnvironmentKey
    extension EnvironmentValues { var lm: LocalizationManager }

Stillway/Resources/tr.lproj/Localizable.strings   ← ~75 anahtar, Türkçe
Stillway/Resources/ja.lproj/Localizable.strings   ← ~75 anahtar, Japonca
Stillway/Resources/en.lproj/Localizable.strings   ← ~75 anahtar, İngilizce
Stillway/Resources/fr.lproj/Localizable.strings   ← ~75 anahtar, Fransızca

Tam anahtar listesi (DESIGN_SYSTEM.md Bölüm 8'deki tablodan):
  ctx_commute, ctx_focus, ctx_sleep, ctx_reset, ctx_walking, ctx_deepwork, ctx_unknown, ctx_auto
  snd_tokyo_metro, snd_shinkansen, snd_paris_metro, snd_istanbul_ferry,
  snd_tokyo_rain, snd_deep_train, snd_night_cafe, snd_minka_library,
  snd_kyoto_bamboo, snd_temple_bell, snd_rain_window, snd_night_forest
  place_unknown, place_home, place_work, place_library, place_cafe, place_gym, place_other
  btn_start, btn_stop, btn_cancel, btn_continue, btn_save, btn_skip
  timer_min, timer_until_end, volume, mix_layer, pro_badge
  notif_commute, notif_sleep, notif_focus, notif_place_label
  onboard_1_title, onboard_1_body, onboard_1_btn
  onboard_2_title, onboard_2_body, onboard_2_btn, onboard_2_skip
  onboard_3_title, onboard_3_body, onboard_3_btn
  settings_title, settings_general, settings_context, settings_context_desc,
  settings_sleep, settings_sleep_desc, settings_sleep_start, settings_haptic,
  settings_haptic_desc, settings_language, settings_language_note,
  settings_pro_section, settings_pro_feature_1..6, settings_pro_btn,
  settings_restore, settings_about, settings_version, settings_privacy
  places_title, places_empty, places_visits, places_last_seen, places_auto_on, places_auto_off
  label_title, label_body, label_done
  pro_title, pro_body, pro_active, pro_restored, pro_error
```

---

### AŞAMA 4 — Core/Audio

```
Stillway/Core/Audio/AudioEngine.swift
  @MainActor @ObservableObject final class AudioEngine:
  
  State:
    - isPlaying: Bool
    - primarySound: Sound?
    - secondarySound: Sound?
    - primaryVolume: Float (0.8)  → didSet: primaryMixer.outputVolume
    - secondaryVolume: Float (0.5) → didSet: secondaryMixer.outputVolume
    - journeyPhase: JourneyPhase (enum: idle/arrival/deepZone/slowReset)
  
  Engine setup:
    - AVAudioEngine
    - primaryMixer, secondaryMixer, masterMixer (AVAudioMixerNode)
    - primaryPlayer, secondaryPlayer (AVAudioPlayerNode)
    - Bağlantı: player → mixer → masterMixer → engine.mainMixerNode
  
  Public API:
    func play(sound: Sound, fadeDuration: Double = 1.5)
    func playSecondary(sound: Sound)
    func stopSecondary()
    func stop(fadeDuration: Double = 2.0)
    func startJourneyArc(minutes: Double)
      → 0–15%: masterVol=0.65 | 15–85%: masterVol=1.0 | 85–100%: masterVol=0.3 (fade)
    func setMasterVolume(_ vol: Float, duration: Double)
    var isHeadphonesConnected: Bool
      → AVAudioSession.currentRoute.outputs filtrele: headphones/BT

  Fade: Timer tabanlı, 60 adım, lineer interpolasyon
  Loop: scheduleBuffer(_:options:.loops)
  
  Notification gönder:
    .headphonesConnected (yeni cihaz gelince)
  
  Notification gözlemle:
    AVAudioSession.routeChangeNotification
      → oldDeviceUnavailable: stop(0.5s)
      → newDeviceAvailable: .headphonesConnected yayınla
    AVAudioSession.interruptionNotification
      → .ended + shouldResume: engine yeniden başlat

  Notification.Name extensions (bu dosyada tanımla):
    .headphonesConnected, .contextDidChange,
    .autoSessionTriggered, .placeNeedsLabel, .sleepPromptNeeded
```

---

### AŞAMA 5 — Core/Location

```
Stillway/Core/Location/LocationManager.swift
  final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject:
    - static let shared
    - authStatus: CLAuthorizationStatus (Published)
    - currentLocation: CLLocation? (Published)
    - onVisit: ((CLVisit) → Void)?
    - onRegionEnter: ((String) → Void)?
    - onRegionExit: ((String) → Void)?
    
    CLLocationManager config:
      desiredAccuracy = kCLLocationAccuracyThreeKilometers
      distanceFilter = 500
      allowsBackgroundLocationUpdates = true
      pausesLocationUpdatesAutomatically = false
    
    func requestAlwaysAuthorization()
    func startAllServices() → startUpdatingLocation + startMonitoringVisits + startMonitoringSignificantLocationChanges
    func stopAllServices()
    func startMonitoring(region: CLCircularRegion)
    func stopMonitoring(region: CLCircularRegion)
    func stopAllGeofences()

Stillway/Core/Location/GeofenceManager.swift
  final class GeofenceManager:
    - Maks 18 aktif geofence
    - onTransitEntry: ((Station) → Void)?
    - onTransitExit: ((Station) → Void)?
    
    func setup()   → locationManager callback'lerini bağla
    func refresh(near: CLLocationCoordinate2D)
      → StationDatabase.nearest(limit:18)
      → Eski geofence'leri kaldır, yenilerini ekle
    func clearAll()
    
    CLCircularRegion oluşturma:
      center: station.coordinate
      radius: station.geofenceRadius
      identifier: station.id

Stillway/Core/Location/StationDatabase.swift
  final class StationDatabase (singleton):
    - stations: [Station] (JSON'dan yükle, yoksa sampleData)
    - Grid spatial index: 0.01 derece hücre (~1km)
    
    func nearest(to: CLLocationCoordinate2D, limit: Int, maxMeters: Double) → [Station]
    func station(id: String) → Station?
    var count: Int
    
    Sample data (stations.json yokken):
      Tokyo: Shibuya, Shinjuku, Ikebukuro, Tokyo, Ueno, Akihabara, Otemachi
      Osaka: Osaka, Umeda
      New York: Times Sq, Grand Central, Union Sq, Penn Station, Fulton
      Paris: Châtelet, Gare du Nord, St-Germain, Montparnasse
      London: King's Cross, Waterloo, Oxford Circus, Canary Wharf
      Istanbul: Taksim, Kadıköy, Eminönü (ferry), Levent, Yenikapı
```

---

### AŞAMA 6 — Core/Context

```
Stillway/Core/Context/MotionClassifier.swift
  @ObservableObject final class MotionClassifier:
    - currentActivity: ActivityState (Published)
    - isPhoneHorizontal: Bool (Published)
    
    CMMotionActivityManager → startActivityUpdates
    CMMotionManager accelerometer (2s interval) → Z ekseninden horizontal tespit
    
    enum ActivityState: String
      (stationary/walking/running/automotive/cycling/unknown)
      init(from: CMMotionActivity)
      var isTransit: Bool, var isStationary: Bool

Stillway/Core/Context/VisitTracker.swift
  final class VisitTracker:
    init(modelContext: ModelContext)
    func process(visit: CLVisit) → SwiftData'ya işle
    func setAutoStart(for: UserPlace, enabled: Bool)
    
    Mantık:
      - Gelen koordinata 100m içinde UserPlace var mı? → visitCount++
      - Yoksa → yeni UserPlace oluştur
      - visitCount == 3 → .placeNeedsLabel notification
      - homeConfidence: gece saatleri (23–06) ziyaret oranı

Stillway/Core/Context/SleepDetector.swift
  final class SleepDetector:
    - configure(preferences: UserPreferences, homePlace: UserPlace?)
    - startMonitoring() → 60s timer
    - stopMonitoring()
    
    Her 60s kontrol:
      1. sleepModeEnabled?
      2. Şu an uyku saati mi?
      3. Ev konumu < 200m?
      4. motionActivity.stationary?
      5. isPhoneHorizontal?
      → Hepsi true → .sleepPromptNeeded yayınla

Stillway/Core/Context/ContextEngine.swift
  @MainActor @ObservableObject final class ContextEngine:
    
    Alt sistemler:
      - audioEngine: AudioEngine
      - themeEngine: ThemeEngine
      - locationManager: LocationManager.shared
      - geofenceManager: GeofenceManager
      - motionClassifier: MotionClassifier
      - sleepDetector: SleepDetector
      - visitTracker: VisitTracker? (modelContext ile init)
    
    Published state:
      - currentContext: AppContext
      - triggerType: TriggerType
      - activeStationID: String?
    
    func configure(modelContext: ModelContext) → tüm bağlamaları kur
    func startManually(context: AppContext, sound: Sound)
    func stop()
    
    Öncelik sırası (yüksekten düşüğe):
      1. Geofence + headphones → commute
      2. CMMotion automotive → commute
      3. Uyku koşulları → sleep
      4. Bilinen yer + iş saati → focus
      5. Walking + headphones → reset
      6. Default → unknown
```

---

### AŞAMA 7 — Core/Haptics + Store + DynamicIsland

```
Stillway/Core/Haptics/HapticEngine.swift
  enum HapticEngine (static methods):
    tap(), soft(), medium(), select(), success(), warning(), error()
  → UIImpactFeedbackGenerator, UISelectionFeedbackGenerator, UINotificationFeedbackGenerator

Stillway/Core/Haptics/HapticBreathingEngine.swift
  final class HapticBreathingEngine:
    - CHHapticEngine
    - func start(), func stop()
    - Box Breathing (4-4-4-4):
        3 kısa transient (0.15s ara) → nefes al
        t=8s: 1 uzun continuous (0.8s) → nefes ver
        16s döngü, recursion ile tekrar

Stillway/Core/Store/PurchaseManager.swift
  @MainActor @ObservableObject final class PurchaseManager:
    - static let proProductID = "com.sinannergiz.stillway.pro"
    - isPro: Bool (Published)
    - isLoading: Bool (Published)
    - proProduct: Product? (Published)
    - errorMessage: String? (Published)
    
    StoreKit 2:
      init → loadProduct(), listenForTransactions(), refreshEntitlements()
      func purchase() async
      func restorePurchases() async

Stillway/Core/DynamicIsland/LiveActivityManager.swift
  struct StillwayActivityAttributes: ActivityAttributes
    ContentState: contextName, soundName, remainingSeconds, accentHex, isPlaying
  
  @MainActor @ObservableObject final class LiveActivityManager:
    func start(contextName:soundName:totalMinutes:accentHex:)
    func update(remainingSeconds: Int)
    func end()
```

---

### AŞAMA 8 — Components ve Modifiers

```
Stillway/Components/GlassCard.swift
  struct GlassCard<Content: View>: View
    - .ultraThinMaterial arkaplan
    - 1pt gradient border (beyaz %15 → şeffaf)
    - cornerRadius: 20, shadow(color: .black.opacity(0.3), radius: 16, y: 8)

Stillway/Components/PillButton.swift
  struct PillButton: View
    - label: String, color: Color, action: () → Void
    - isPro: Bool (kilit ikonu göster)
    - Yükseklik: 44pt, cornerRadius: 22, padding H:20
    - Glow: shadow(color: color.opacity(0.35), radius: 12)
    - Haptic: HapticEngine.tap()

Stillway/Components/PulsingDot.swift
  struct PulsingDot: View
    - color: Color (default .green)
    - 8pt circle + 2 katman pulsing ring animasyonu
    - @State phase: Double, animation .easeInOut.repeatForever

Stillway/Components/GradientText.swift
  struct GradientText: View
    - text: String, colors: [Color], font: Font
    - Text üzerine LinearGradient mask

Stillway/Components/CustomBottomSheet.swift
  ViewModifier olarak implemente et:
    func customSheet<Content: View>(isPresented: Binding<Bool>, content: () → Content)
    - Spring animasyon: response 0.4, dampingFraction 0.82
    - Drag handle: 36×4pt rounded rect, %20 beyaz
    - .regularMaterial arkaplan
    - Üst köşe radius: 24pt
    - Kapatma: aşağı sürükle veya arkaplan tıkla

Stillway/Modifiers/HapticButtonStyle.swift
  struct HapticButtonStyle: ButtonStyle
    - makeBody: tap'te HapticEngine.tap() + scale(0.94) animasyon

Stillway/Modifiers/ReduceMotionModifier.swift
  ViewModifier: @Environment(\.accessibilityReduceMotion)
    - reduceMotion true ise animasyonları .linear(0) ile override

Stillway/Modifiers/ContextThemeModifier.swift
  ViewModifier: @Environment(ThemeEngine.self)
    - View'a bağlam rengini inject eder
```

---

### AŞAMA 9 — SwiftUI Views (Ana Ekran)

```
Stillway/Views/Main/MeshBackgroundView.swift
  - iOS 18+: MeshGradient(3×3, animatedPoints, meshColors)
  - iOS 17 fallback: RadialGradient + LinearGradient overlay
  - TimelineView(.animation) → t değişkeni ile nokta hareketi
  - Hareket: sin/cos × 0.06 offset, 12s period

Stillway/Views/Main/WaveformView.swift
  - TimelineView(.animation) içinde Canvas
  - config.layerCount kadar dalga katmanı
  - Her katman: sin(x * freq + t * phaseSpeed + layerOffset) × amplitude
  - Fill: LinearGradient(waveColors)
  - Katmanlar farklı opacity ve y-offset (parallax)
  - Reduce Motion: statik LinearGradient rectangle

Stillway/Views/Main/ContextBadge.swift
  - HStack: PulsingDot (isAuto ise) + mod adı (ALL CAPS) + "OTOMATİK" etiketi
  - Capsule shape, aksan rengi fill %12, border %30
  - .transition(.scale(0.8).combined(.opacity))
  - .id(context) ile değişince yeniden render

Stillway/Views/Main/StartStopButton.swift
  - ZStack: 2 glow layer + buton gövdesi + SF Symbol
  - Glow: blur(20) + blur(40), isPlaying'de daha yoğun
  - Symbol: "waveform" (çalıyor) / "play.fill" (durdu)
  - .contentTransition(.symbolEffect(.replace))
  - Press: scaleEffect(0.92), spring(0.25, 0.65)
  - DragGesture(minimumDistance:0) ile press state

Stillway/Views/Main/TimerRing.swift
  - ZStack: track ring + progress ring + merkez metin
  - Track: stroke %8 beyaz, 2.5pt
  - Progress: trim(0, progress), aksan rengi, lineCap .round
  - Merkez: SF Mono, 22pt, contentTransition(.numericText())
  - "MM:SS" format

Stillway/Views/Main/TimerSelector.swift
  - [15, 30, 45] pill row
  - matchedGeometryEffect ile seçim geçişi
  - Seçili: aksan fill + beyaz metin
  - Seçilmemiş: beyaz %8 fill
  - HapticEngine.select() seçimde

Stillway/Views/Main/SoundMixerRow.swift
  - GlassCard içinde
  - Ses adı + bölge flag + Pro badge
  - Hacim slider (custom, aksan rengi track)
  - Pro: ikinci ses katmanı (secondarySound)
  - Ses seçince SoundPickerSheet açılır

Stillway/Views/Main/MainView.swift
  ZStack:
    MeshBackgroundView()            ← tam ekran, ignoresSafeArea
    VStack(spacing: 0):
      HStack: PlacesButton + Spacer + SettingsButton   ← üst
      Spacer()
      ContextBadge()
      Spacer()
      WaveformView()                ← yükseklik 160pt
      Spacer()
      TimerRing() (isPlaying ise)
      StartStopButton()
      TimerSelector()
      SoundMixerRow()
        .padding(.horizontal, 24)
        .padding(.bottom, 48)
  
  .sheet(isPresented: $showSettings) → SettingsSheet
  .sheet(isPresented: $showPlaces)   → PlacesSheet
  .sheet(isPresented: $showSounds)   → SoundPickerSheet
  
  Auto-start banner:
    .overlay(AutoStartBanner) ← bildirim gelince 4s göster, sonra kaybol
```

---

### AŞAMA 10 — SwiftUI Views (Sheets)

```
Stillway/Views/Sheets/SoundPickerSheet.swift
  - LazyVStack: bağlam gruplarına göre sesler
  - Her ses: GlassCard + ses adı (yerelleştirilmiş) + flag + Pro lock ikonu
  - Seçili ses: aksan rengi border
  - Pro değilse: lock göster, tap'te Pro sheet aç
  - HapticEngine.select() seçimde

Stillway/Views/Sheets/PlacesSheet.swift
  - ScrollView > LazyVStack: UserPlace listesi
  - Boş durum: places_empty metni + animasyonlu ikon
  - Her yer: GlassCard
      SF Symbol (place.label.sfSymbol) + isim + visitCount
      Toggle (autoStartEnabled) + ses seçici
  - Tap: PlaceLabelSheet aç
  - SwiftData @Query ile canlı liste

Stillway/Views/Sheets/PlaceLabelSheet.swift
  - Başlık: String(format: lm.string("label_title"), visitCount)
  - Alt metin: label_body
  - LazyVGrid(2 sütun): PlaceLabel.allCases
      Her seçenek: GlassCard + büyük SF Symbol + yerelleştirilmiş isim
  - Seçim → checkmark animasyon + "label_done" toast + sheet kapan
  - HapticEngine.success() seçimde

Stillway/Views/Sheets/SettingsSheet.swift
  Form veya custom ScrollView:
  
  Bölüm 1 — GENEL:
    Toggle: settings_context / settings_context_desc
    Toggle: settings_sleep / settings_sleep_desc
    DatePicker (saat): settings_sleep_start
    Toggle: settings_haptic / settings_haptic_desc
  
  Bölüm 2 — DİL:
    Picker: settings_language
      Her dil: flag emoji + displayName
    Text: settings_language_note (caption)
  
  Bölüm 3 — PRO:
    Pro aktifse: "pro_active" + yeşil checkmark
    Aktif değilse:
      - 6 feature row (ikon + metin)
      - PillButton: settings_pro_btn
      - Button: settings_restore
    isLoading: ProgressView overlay
  
  Bölüm 4 — HAKKINDA:
    Text: settings_version + Bundle version
    Link: settings_privacy → gizlilik URL'i
```

---

### AŞAMA 11 — Onboarding

```
Stillway/Views/Onboarding/OnboardingView.swift
  - @State currentPage: Int (0, 1, 2)
  - TabView veya manual page geçişi (kaydırma KAPALI)
  - Her sayfada alt buton tap ile currentPage++
  - Sayfa 2'den 3'e: lokasyon izni iste
  - Sayfa 3'ten çıkış: UserPreferences.onboardingCompleted = true

Stillway/Views/Onboarding/OnboardPage1.swift
  Arkaplan: COMMUTE gradient (MeshBackgroundView)
  İçerik (VStack, merkez):
    - "waveform" SF Symbol animasyonlu (96pt, aksan rengi)
    - Başlık: onboard_1_title (34pt Display Light)
    - Body: onboard_1_body (17pt, %80 beyaz)
    - PillButton: onboard_1_btn → CLLocationManager.requestAlways

Stillway/Views/Onboarding/OnboardPage2.swift
  Arkaplan: FOCUS gradient
  İçerik:
    - "airpodspro" + "arrow.right" + "waveform" ikon row
    - Başlık: onboard_2_title
    - Body: onboard_2_body
    - PillButton: onboard_2_btn → iOS Shortcuts URL aç
    - Button (link tarzı): onboard_2_skip → nextPage

Stillway/Views/Onboarding/OnboardPage3.swift
  Arkaplan: Tüm bağlam renkleri → animated mesh
  İçerik:
    - WaveformView (büyük, ekranın %50'si)
    - Başlık: onboard_3_title (büyük, gradient text)
    - Body: onboard_3_body
    - PillButton: onboard_3_btn → oboardingCompleted = true → MainView

Stillway/Views/ContentRootView.swift
  @Query var prefs: [UserPreferences]
  var body:
    if prefs.first?.onboardingCompleted == true:
      MainView()
    else:
      OnboardingView()
```

---

### AŞAMA 12 — App Entry Point

```
Stillway/App/StillwayApp.swift
  @main struct StillwayApp: App
  
  @UIApplicationDelegateAdaptor AppDelegate.self
  
  ModelContainer:
    Schema: [UserPlace, CommutSession, UserPreferences]
    ModelConfiguration: isStoredInMemoryOnly: false
  
  Environment objects:
    @State private var contextEngine = ContextEngine()
    @State private var purchaseManager = PurchaseManager()
    @State private var lm = LocalizationManager()
    @State private var themeEngine = ThemeEngine()
  
  body:
    WindowGroup:
      ContentRootView()
        .modelContainer(sharedModelContainer)
        .environment(contextEngine)
        .environment(contextEngine.themeEngine)
        .environment(contextEngine.audioEngine)
        .environment(purchaseManager)
        .environment(\.lm, lm)
        .preferredColorScheme(.dark)
        .onAppear { contextEngine.configure(modelContext: ...) }

Stillway/App/AppDelegate.swift
  func application didFinishLaunching:
    AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers, .allowAirPlay, .allowBluetooth])
    AVAudioSession.sharedInstance().setActive(true)
```

---

### AŞAMA 13 — Widget Extension

```
StillwayWidgets/StillwayWidgetBundle.swift
  @main struct StillwayWidgetBundle: WidgetBundle
    → HomeScreenWidget + StillwayLiveActivity

StillwayWidgets/HomeScreenWidget.swift
  struct HomeScreenWidget: Widget
    kind: "HomeScreenWidget"
    body: StaticConfiguration
    
  struct HomeWidgetEntryView: View
    - Aktif ses adı + bağlam ikonu + "Başlat" butonu
    - Dark background, aksan rengi minimal

StillwayWidgets/StillwayLiveActivity.swift (Dynamic Island)
  struct StillwayLiveActivity: Widget
    kind: "StillwayLiveActivity"
    body: ActivityConfiguration<StillwayActivityAttributes>
    
  Compact leading: "waveform" SF Symbol (aksan rengi)
  Compact trailing: kalan süre "24:17"
  Minimal: animasyonlu waveform pulse
  Expanded:
    VStack:
      HStack: bağlam adı + ses adı
      Progress ring veya linear progress
      Kalan süre (büyük, monospace)
```

---

### AŞAMA 14 — Python Script ve Veri

```
scripts/build_station_db.py
  Görev: 5 ülke GTFS → stations.json
  
  Her ülke için:
    1. GTFS ZIP indir (URL BUILD_PLAN.md'de)
    2. stops.txt ayrıştır
    3. stop_id, stop_name, stop_lat, stop_lon al
    4. location_type=0 (sadece duraklar, istasyonlar değil)
    5. Büyük şehir bbox'larıyla kırp (kırsal hariç)
    6. transit_type tahmini (routes.txt'ten)
    7. JSON array çıktısı
  
  Çıktı formatı:
    [{"id":"...","name":"...","name_en":"...","lat":0.0,"lon":0.0,
      "country":"JP","city":"Tokyo","type":"METRO","lines":["..."]}]
  
  Bağımlılıklar: requests, pandas, zipfile (stdlib)

scripts/download_gtfs.sh
  Bash: Her ülke için GTFS dosyasını /tmp/gtfs/ altına indir
  JP: ODPT API (key gerekli, .env'den al)
  US: MTA (ücretsiz)
  FR: IDFM API (ücretsiz kayıt)
  GB: BODS (ücretsiz)
  TR: İBB açık veri
```

---

### AŞAMA 15 — README

```
README.md (proje kökünde)
  İçerik:
  - Ne bu uygulama? (1 paragraf)
  - Özellikler listesi
  - Gereksinimler: Xcode 16+, iOS 17+, macOS 14+
  - Kurulum adımları
  - stations.json nasıl üretilir (script açıklaması)
  - Ses dosyaları nereye konur
  - App Store yayın öncesi checklist
  - Katkıda bulunma kuralları
```

---

## Öncelik Sırası (Mac Cursor Agent İçin)

```
1. Aşama 0  → Xcode projesi (bunlarsız hiçbir şey çalışmaz)
2. Aşama 1  → Modeller (her şeyin temeli)
3. Aşama 2  → Theme (UI'dan önce gerekli)
4. Aşama 3  → Localization (UI'dan önce gerekli)
5. Aşama 9  → Ana ekran views (görsel doğrulama için)
6. Aşama 4  → Audio (ses çalması için)
7. Aşama 8  → Components (views'ın ihtiyacı)
8. Aşama 10 → Sheets
9. Aşama 11 → Onboarding
10. Aşama 12 → App entry
11. Aşama 5  → Location
12. Aşama 6  → Context
13. Aşama 7  → Haptics + Store + DynamicIsland
14. Aşama 13 → Widgets
15. Aşama 14 → GTFS script
16. Aşama 15 → README
```

---

## Mac Cursor Agent'a Verilecek Komut

```
Bu dört dökümanı oku:
• PRODUCT_SPEC.md
• DESIGN_SYSTEM.md
• BUILD_PLAN.md
• MISSING_AND_TODOS.md

Stillway iOS uygulamasını Swift/SwiftUI ile geliştir.

MISSING_AND_TODOS.md'deki öncelik sırasını takip et.
Aşama 0'dan başla: Xcode projesi oluştur.
Her aşama bittikten sonra simülatör ekran görüntüsü veya
"✅ Aşama X tamamlandı" bildirimi paylaş.
Hata çıkarsa devam et, sonraki aşamaya geç ve rapor et.
```

---

*Bu dosya tüm eksiklikleri kapsar. Güncellenme gerekmez.*  
*Versiyon: 1.0 | Ağustos 2026*
