# Stillway — Product Specification v2.0

> *"Sen sadece yaşa. Geri kalanı biz anlıyoruz."*

---

## 1. Ürün Kimliği

**Uygulama adı:** Stillway  
**Platform:** iOS 17+  
**Hedef pazarlar:** Japonya · ABD · Fransa · İngiltere · Türkiye  
**Kategori:** Lifestyle / Focus / Ambient Intelligence  
**Çekirdek felsefe:** Eyes-Free · Offline-First · Invisible Intelligence

---

## 2. Sorun Tanımı

Mevcut ambient ses uygulamaları bir şey söyler: "Aç, seç, başlat."  
Stillway'in söylediği: **hiçbir şey.** Çünkü söylemesine gerek yok.

Gerçek sorun şu: Gün içinde onlarca bağlam değişikliği yaşanıyor.  
Evden çıkıyorsun, metroya biniyorsun, ofise giriyorsun, öğle molası veriyorsun,  
kütüphaneye geçiyorsun, eve dönüyorsun, uyumaya yatıyorsun.

Her geçişte telefonu açıp bir ses seçmek — kimse yapmıyor.  
Yapmayacak da.

**Stillway bu geçişleri senin için yönetir.**

---

## 3. Temel Değer Önerisi (UVP)

```
Diğer uygulamalar:     Stillway:
Telefonunu aç      →   Hayatına devam et
Bir ses seç        →   Sistem senin yerini ve ne yaptığını öğrenir
Başlat'a bas       →   Otomatik tetiklenir
İzle ve yönet      →   Unut
```

**Tek cümle:** Nerede olduğunu ve ne yaptığını anlayan, doğru ortamı  
kendiliğinden yaratan sessiz bir arkadaş.

---

## 4. Bağlam Zekası Mimarisi

Stillway beş iOS API katmanını birleştirir:

### Katman 1 — CLVisit (Ziyaret Hafızası)
iOS, kullanıcının gittiği yerleri, ne zaman gelip gittiğini zaten takip ediyor.  
`startMonitoringVisits()` ile bu veri uygulamaya akar.  
App tamamen kapalıyken bile iOS onu uyandırır ve ziyaret bilgisini iletir.

```
Tekrar eden ziyaretlerden öğrenilen kalıp:
• Salı-Perşembe, 14:00–16:30 → Koordinat A → Kütüphane (kullanıcı etiketledi)
• Her sabah 08:45 → Koordinat B → İstasyon (geofence ile teyit edildi)
• Her gece 23:00+ → Koordinat C → Ev
```

### Katman 2 — CMMotionActivityManager (Ne Yapıyorsun?)
```
stationary  → oturuyor / duruyor
walking     → yürüyor
automotive  → araçta
cycling     → bisiklette
```

### Katman 3 — Geofencing (Transit Tespiti)
~56.000 metro/tren/tramvay/vapur durağı — 5 ülke, offline SQLite  
Dinamik 18-geofence sistemi: en yakın duraklar aktif, diğerleri uyuyor

### Katman 4 — Core ML Motion Classifier (Tren mi?)
Accelerometer + gyroscope → tren titreşim imzası  
Yer altında GPS yokken bile "trende mi" sorusuna cevap verir

### Katman 5 — AVAudioSession Route (Kulaklık Takıldı mı?)
Kulaklık + yakın istasyon/bilinen yer → otomatik başlatma kombinasyonu

---

## 5. Bağlam Haritası ve Otomatik Tetikleyiciler

```
┌─────────────────────────────────────────────────────────────┐
│  BAĞLAM          TETIKLEYICI                    SES MODU    │
├─────────────────────────────────────────────────────────────┤
│  Metro/Tren      Geofence + CoreML tren         COMMUTE     │
│  Araçla yolculuk CMMotion: automotive           COMMUTE     │
│  Yürüyüş         CMMotion: walking + kulaklık   RESET       │
├─────────────────────────────────────────────────────────────┤
│  Ofis/Çalışma    CLVisit: haftalık yer + 9-18   FOCUS       │
│  Ev ofisi        Ev koordinatı + gündüz          FOCUS       │
│  Kütüphane/Kafe  CLVisit: etik + 2+ saat dur.   FOCUS       │
├─────────────────────────────────────────────────────────────┤
│  Uyku            Ev + 22:00+ + telefon düz       SLEEP       │
│  Kısa mola       <15 dk, hareket → dur. geçiş   RESET       │
└─────────────────────────────────────────────────────────────┘
```

### Öğrenme Zaman Çizelgesi

```
Gün 1:    Komüt modu aktif. Anlık değer.
Hafta 1:  Sistem gözlemliyor. Sessiz.
Hafta 2:  "Bu yere 4 kez geldiniz. Burası ne?"
           → Kullanıcı seçer: Kütüphane / Kafe / Ofis / Diğer
Hafta 3:  O yer için otomatik mod devreye giriyor.
Ay 2+:    Stillway hayatını biliyor. Açmana gerek yok.
```

---

## 6. Hedef Pazarlar ve Transit Veri Kapsamı

### 5 Ülke, Tüm Büyük Şehirler

| Ülke | Kapsam | Transit Türleri | Tahmini Durak |
|------|--------|----------------|---------------|
| 🇯🇵 Japonya | Tokyo, Osaka, Kyoto, Nagoya, Fukuoka | Metro, JR, Shinkansen, Tram | ~30.000 |
| 🇺🇸 ABD | NYC, LA, Chicago, SF, Boston, DC, Seattle | Subway, Light Rail, BART, WMATA | ~15.000 |
| 🇫🇷 Fransa | Paris, Lyon, Marseille, Bordeaux, Nice | Metro, RER, Tram | ~5.000 |
| 🇬🇧 İngiltere | Londra, Manchester, Birmingham, Edinburgh | Underground, Overground, Tram | ~4.000 |
| 🇹🇷 Türkiye | İstanbul, Ankara, İzmir, Bursa | Metro, Metrobüs, Tramvay, Vapur | ~2.000 |
| **Toplam** | | | **~56.000** |

**Veritabanı boyutu:** ~20–30 MB (SQLite, sıkıştırılmış)  
**Veri kaynakları:** ODPT · MTA Open Data · IDFM/PRIM · TfL Open Data · İBB Açık Veri  
**Lisans:** CC BY 4.0 veya muadili

### V2: Otobüs/Metrobüs Paketleri
Şehir bazında indirme (~5–10 MB/şehir, arka planda)

---

## 7. Ses Kütüphanesi

### Felsefe: 12 Olağanüstü > 100 Ortalama

| Mod | Ses | Bağlam |
|-----|-----|--------|
| **COMMUTE** | Tokyo Metro | Komüt, araç |
| | Shinkansen | Uzun yolculuk |
| | Paris Metro | Avrupa komütü |
| | Istanbul Ferry | Su üstü yolculuk |
| **FOCUS** | Tokyo Rain | Ofis, ev ofisi |
| | Deep Train | Derin çalışma, kütüphane |
| | Night Café | Kafe çalışma |
| | Minka Library | Sessiz, ahşap mekan |
| **RESET** | Kyoto Bamboo | Kısa mola |
| | Temple Bell | Geçiş anı |
| | Rain Window | Ev, dinlenme |
| | Night Forest | Uyku |

**Teknik:** Gerçek saha kaydı · 24-bit/48kHz · Seamless loop · AVAudioEngine çok kanallı miksleme  
**Çoklu miksleme:** Sadece Pro (2 ses eş zamanlı, bağımsız hacimler)

---

## 8. Kulaklık Otomatik Başlatma

```
Durum 1 — App arka planda:
    Kulaklık takıldı + bilinen yer/yakın istasyon → TAM OTOMATİK ✅

Durum 2 — App kapalı:
    Geofence tetiklenir → iOS app'i arka planda uyandırır
    → Kulaklık kontrolü → Bağlıysa başlatır (~%90 güvenilirlik) ✅

Durum 3 — iOS Shortcuts (onboarding'de kurulum):
    "AirPods bağlandığında → Stillway başlat"
    → App kapalıyken bile çalışır → %100 güvenilirlik ✅
```

---

## 9. Arayüz Tasarımı

### Tasarım Dili
- **Tema:** Dark-only. Tek karar, taviz yok.
- **Renk:** Siyah zemin · %10 opaklık mat kartlar · Mod'a göre aksan rengi
- **Animasyon:** Tek fluid dalga · 60fps · SwiftUI Canvas
- **Tipografi:** SF Pro Display — system font

### Ekranlar (MVP)
```
Ana Ekran (tek ekran)
├── Mod rozeti: otomatik tespit edilmişse "Auto" etiketi
├── Ses kartı + dalga animasyonu
├── Başlat / Durdur
├── Zamanlayıcı: 15 · 30 · 45 dk veya "Rota bitene kadar"
└── Ses seviyesi (gömülü)

Yerlerim (sheet)
├── Öğrenilen yerler listesi
├── Etiket düzenleme
└── Her yer için varsayılan mod

Ayarlar (sheet)
├── Bağlam Tespiti: Açık/Kapalı
├── Uyku Modu: Açık/Kapalı + saat aralığı
├── Haptik Nefes: Açık/Kapalı
└── Pro Satın Al
```

---

## 10. Core Haptics — Nefes Rehberi

Box Breathing (4-4-4-4), telefon cepte, ekran kapalı:
```
3 kısa titreşim → Nefes al (4 sn)
Sessizlik       → Tut (4 sn)
1 uzun titreşim → Nefes ver (4 sn)
Sessizlik       → Bekle (4 sn)
```
iPhone Pro Taptic Engine gerektirir. Eski cihazlarda özellik gizlenir.

---

## 11. Teknik Stack

```
Dil:             Swift 5.10 / SwiftUI
Min iOS:         iOS 17.0
Ses:             AVAudioEngine + AVAudioMixerNode
Lokasyon:        Core Location (CLVisit + CLCircularRegion + CLMonitor)
Motion:          Core Motion (CMMotionActivityManager)
Tren Tespiti:    Create ML → Core ML (activity classifier, ~500 KB)
Haptik:          Core Haptics (CHHapticEngine)
Veritabanı:      GRDB.swift (SQLite — istasyonlar + ziyaret geçmişi)
Yerel Depo:      SwiftData (kullanıcı tercihleri, alışkanlıklar, yerler)
Satın Alma:      StoreKit 2
Background:      Audio + Location Updates background modes
```

**Backend:** YOK  
**Hesap:** YOK  
**Analytics:** YOK  
**Reklam:** YOK

---

## 12. Gelir Modeli

```
FREE (reklamsız, hesapsız)
├── 3 ses: Tokyo Rain · Deep Train · Rain Window
├── COMMUTE · FOCUS · RESET · SLEEP modları
├── 15 / 30 / 45 dk zamanlayıcı
├── Bağlam tespiti (bildirimle, otomatik başlatma olmadan)
└── Offline

PRO — $4.99 tek seferlik
├── Tüm 12 ses
├── Çoklu miksleme
├── Otomatik başlatma (kulaklık + yer)
├── Yer öğrenimi ve etiketleme
├── Journey Arc otomasyonu
├── Core Haptics nefes rehberi
└── Uyku modu otomasyonu

LIFETIME — $19.99 (60–90 gün sonra test)
└── Pro + gelecek ses paketleri
```

---

## 13. MVP Kapsamı

### V1'e Giren
- [ ] 12 ses (post-prodüksiyon tamamlanmış)
- [ ] 4 mod: COMMUTE · FOCUS · RESET · SLEEP
- [ ] Journey Arc (3 fazlı otomatik geçiş)
- [ ] Zamanlayıcı + fade-out
- [ ] Transit geofencing (56.000 durak, 5 ülke)
- [ ] Core ML tren sınıflandırıcı
- [ ] CLVisit tabanlı yer öğrenimi
- [ ] Uyku tespiti (ev + saat + pozisyon)
- [ ] Kulaklık otomatik başlatma
- [ ] Core Haptics nefes
- [ ] StoreKit 2 ($4.99 Pro)
- [ ] Dark UI · Fluid dalga animasyonu

### V2'ye Bırakılan
- Action Button · Dynamic Island · Live Activities
- Otobüs/metrobüs şehir paketleri · Apple Watch

---

## 14. Başarı Kriterleri (Kill / Scale)

```
SCALE:
├── D7 Retention ≥ %18
├── Haftalık aktif / toplam ≥ %35
├── Pro dönüşüm ≥ %8
└── Yer öğrenimi kullananların D30 retention ≥ %35

KILL:
├── D7 Retention < %12 (ilk 200 kullanıcı)
├── Pro dönüşüm < %4 (60 gün)
└── Otomatik tetikleme opt-in < %25
```

---

*Versiyon: 2.0 | Ağustos 2026 | Ambient Life Companion genişlemesi işlendi*
