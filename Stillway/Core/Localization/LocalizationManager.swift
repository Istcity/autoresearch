import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
final class LocalizationManager {
    var selectedLanguage: String {
        didSet {
            UserDefaults.standard.set(selectedLanguage, forKey: Self.storageKey)
        }
    }

    var current: LanguageCode {
        LanguageCode(rawValue: selectedLanguage) ?? .en
    }

    var locale: Locale { current.locale }

    init() {
        if let stored = UserDefaults.standard.string(forKey: Self.storageKey) {
            selectedLanguage = stored
        } else {
            selectedLanguage = LocalizationManager.autoDetect()
        }
    }

    func string(_ key: String) -> String {
        if let value = Self.table[key]?[current] {
            return value
        }
        if let english = Self.table[key]?[.en] {
            return english
        }
        return key
    }

    func setLanguage(_ code: LanguageCode) {
        selectedLanguage = code.rawValue
    }

    static func autoDetect() -> String {
        LanguageCode.autoDetect().rawValue
    }

    private static let storageKey = "selectedLanguage"
}

extension LocalizationManager {
    static let table: [String: [LanguageCode: String]] = [
        "app_name": [.tr: "Stillway", .ja: "Stillway", .en: "Stillway", .fr: "Stillway"],
        "ctx_commute": [.tr: "Yolculuk", .ja: "通勤", .en: "Commute", .fr: "Trajet"],
        "ctx_focus": [.tr: "Odak", .ja: "集中", .en: "Focus", .fr: "Concentration"],
        "ctx_sleep": [.tr: "Uyku", .ja: "睡眠", .en: "Sleep", .fr: "Sommeil"],
        "ctx_reset": [.tr: "Dinlenme", .ja: "リセット", .en: "Reset", .fr: "Pause"],
        "ctx_walking": [.tr: "Yürüyüş", .ja: "散歩", .en: "Walking", .fr: "Marche"],
        "ctx_deepwork": [.tr: "Sıkı Odak", .ja: "集中作業", .en: "Deep Work", .fr: "Travail profond"],
        "ctx_unknown": [.tr: "Stillway", .ja: "Stillway", .en: "Stillway", .fr: "Stillway"],
        "btn_start": [.tr: "Başlat", .ja: "開始", .en: "Start", .fr: "Démarrer"],
        "btn_stop": [.tr: "Durdur", .ja: "停止", .en: "Stop", .fr: "Arrêter"],
        "btn_begin": [.tr: "Başla", .ja: "始める", .en: "Begin", .fr: "Commencer"],
        "btn_not_now": [.tr: "Şimdi değil", .ja: "今はしない", .en: "Not now", .fr: "Pas maintenant"],
        "btn_allow_location": [.tr: "Konuma İzin Ver", .ja: "位置情報を許可", .en: "Allow Location", .fr: "Autoriser la localisation"],
        "btn_setup_shortcut": [.tr: "Kısayolu Ayarla", .ja: "ショートカットを設定", .en: "Set Up Shortcut", .fr: "Configurer le raccourci"],
        "btn_go_pro": [.tr: "Pro'ya Geç", .ja: "Proにアップグレード", .en: "Go Pro", .fr: "Passer à Pro"],
        "btn_restore": [.tr: "Satın Alımı Geri Yükle", .ja: "購入を復元", .en: "Restore Purchase", .fr: "Restaurer l’achat"],
        "btn_done": [.tr: "Tamam", .ja: "完了", .en: "Done", .fr: "OK"],
        "btn_save": [.tr: "Kaydet", .ja: "保存", .en: "Save", .fr: "Enregistrer"],
        "auto_badge": [.tr: "Otomatik", .ja: "自動", .en: "Auto", .fr: "Auto"],
        "manual_badge": [.tr: "Manuel", .ja: "手動", .en: "Manual", .fr: "Manuel"],
        "place_home": [.tr: "Ev", .ja: "家", .en: "Home", .fr: "Maison"],
        "place_work": [.tr: "İş", .ja: "職場", .en: "Work", .fr: "Bureau"],
        "place_library": [.tr: "Kütüphane", .ja: "図書館", .en: "Library", .fr: "Bibliothèque"],
        "place_cafe": [.tr: "Kafe", .ja: "カフェ", .en: "Café", .fr: "Café"],
        "place_gym": [.tr: "Spor Salonu", .ja: "ジム", .en: "Gym", .fr: "Salle de sport"],
        "place_other": [.tr: "Diğer", .ja: "その他", .en: "Other", .fr: "Autre"],
        "places_title": [.tr: "Yerlerim", .ja: "場所", .en: "My Places", .fr: "Mes lieux"],
        "places_empty": [.tr: "Henüz öğrenilen yer yok. Stillway sizi birkaç gün izleyecek.", .ja: "まだ学習した場所はありません。Stillwayが数日かけて学びます。", .en: "No learned places yet. Stillway will watch for a few days.", .fr: "Aucun lieu appris pour l’instant. Stillway observera quelques jours."],
        "place_label_title": [.tr: "Buraya 3 kez geldiniz.", .ja: "ここに3回訪れました。", .en: "You’ve been here 3 times.", .fr: "Vous êtes venu ici 3 fois."],
        "place_label_subtitle": [.tr: "Bu yeri tanımlarsanız Stillway otomatik mod açabilir.", .ja: "この場所を指定すると、Stillwayが自動モードを使えます。", .en: "If you label this place, Stillway can turn on auto mode.", .fr: "Si vous nommez ce lieu, Stillway pourra activer le mode auto."],
        "place_configured": [.tr: "Ayarlandı!", .ja: "設定しました", .en: "All set!", .fr: "C’est noté !"],
        "place_visits": [.tr: "ziyaret", .ja: "回", .en: "visits", .fr: "visites"],
        "notif_commute": [.tr: "Yolculuk başlatılsın mı?", .ja: "通勤を開始しますか？", .en: "Start commute?", .fr: "Démarrer le trajet?"],
        "notif_sleep": [.tr: "Uyku modu başlatılsın mı?", .ja: "睡眠モードを開始しますか？", .en: "Start sleep mode?", .fr: "Démarrer le mode sommeil?"],
        "onboard_title1": [.tr: "Seni Tanımak İstiyoruz", .ja: "あなたを知りたい", .en: "Getting to Know You", .fr: "Apprenons à vous connaître"],
        "onboard_headline1": [.tr: "Stillway seni öğreniyor.", .ja: "Stillwayはあなたを学びます。", .en: "Stillway is learning you.", .fr: "Stillway apprend à vous connaître."],
        "onboard_body1": [.tr: "Nerede olduğunu, ne yaptığını anlıyor. Sen hiçbir şey seçmeden doğru müziği açıyor.", .ja: "どこにいて、何をしているかを理解します。選ばなくても、正しい音が始まります。", .en: "It understands where you are and what you’re doing. The right sound starts without you choosing.", .fr: "Il comprend où vous êtes et ce que vous faites. Le bon son démarre sans que vous choisissiez."],
        "onboard_title2": [.tr: "Kulaklık Tak, Gerisi Bize Kalır", .ja: "イヤホンをつければ、あとは任せて", .en: "Put on Headphones. We’ll Handle the Rest", .fr: "Mettez vos écouteurs. On s’occupe du reste"],
        "onboard_headline2": [.tr: "Telefonu kaldır.", .ja: "スマホをしまって。", .en: "Put the phone down.", .fr: "Rangez le téléphone."],
        "onboard_body2": [.tr: "AirPods'unu taktığında ve bir durağa yaklaştığında Stillway otomatik olarak başlar.", .ja: "AirPodsをつけて駅に近づくと、Stillwayが自動で始まります。", .en: "When you put in AirPods and approach a station, Stillway starts on its own.", .fr: "Quand vous mettez vos AirPods et approchez d’une station, Stillway démarre tout seul."],
        "onboard_title3": [.tr: "Hazırsın", .ja: "準備完了", .en: "You’re Ready", .fr: "Vous êtes prêt"],
        "onboard_headline3": [.tr: "İyi yolculuklar.", .ja: "よい旅を。", .en: "Safe travels.", .fr: "Bon voyage."],
        "onboard_body3": [.tr: "Sen sadece yaşa. Geri kalanı biz anlıyoruz.", .ja: "ただ生きてください。あとは私たちが理解します。", .en: "Just live. We’ll understand the rest.", .fr: "Vivez simplement. Nous comprenons le reste."],
        "pro_cta": [.tr: "Pro'ya Geç", .ja: "Proにアップグレード", .en: "Go Pro", .fr: "Passer à Pro"],
        "settings_title": [.tr: "Ayarlar", .ja: "設定", .en: "Settings", .fr: "Réglages"],
        "settings_general": [.tr: "Genel", .ja: "一般", .en: "General", .fr: "Général"],
        "settings_language": [.tr: "Dil", .ja: "言語", .en: "Language", .fr: "Langue"],
        "settings_pro": [.tr: "Pro", .ja: "Pro", .en: "Pro", .fr: "Pro"],
        "settings_about": [.tr: "Hakkında", .ja: "情報", .en: "About", .fr: "À propos"],
        "settings_context_detection": [.tr: "Bağlam Tespiti", .ja: "コンテキスト検出", .en: "Context Detection", .fr: "Détection de contexte"],
        "settings_sleep_mode": [.tr: "Uyku Modu", .ja: "スリープモード", .en: "Sleep Mode", .fr: "Mode sommeil"],
        "settings_sleep_start": [.tr: "Uyku Başlangıcı", .ja: "就寝時刻", .en: "Sleep Start", .fr: "Début du sommeil"],
        "settings_haptic_breath": [.tr: "Haptik Nefes Rehberi", .ja: "触覚ブレスガイド", .en: "Haptic Breath Guide", .fr: "Guide respiratoire haptique"],
        "settings_language_note": [.tr: "Dil değişikliği anında geçerli olur.", .ja: "言語の変更はすぐに反映されます。", .en: "Language changes apply instantly.", .fr: "Le changement de langue s’applique immédiatement."],
        "settings_privacy": [.tr: "Gizlilik Politikası", .ja: "プライバシーポリシー", .en: "Privacy Policy", .fr: "Politique de confidentialité"],
        "settings_version": [.tr: "Sürüm", .ja: "バージョン", .en: "Version", .fr: "Version"],
        "pro_feature_sounds": [.tr: "12 sesin tamamı", .ja: "全12サウンド", .en: "All 12 sounds", .fr: "Les 12 sons"],
        "pro_feature_mix": [.tr: "Çoklu miksleme", .ja: "マルチミックス", .en: "Multi-track mixing", .fr: "Mixage multi-pistes"],
        "pro_feature_autostart": [.tr: "Otomatik başlatma", .ja: "自動スタート", .en: "Auto-start", .fr: "Démarrage automatique"],
        "pro_feature_places": [.tr: "Yer öğrenimi", .ja: "場所の学習", .en: "Place learning", .fr: "Apprentissage des lieux"],
        "pro_feature_journey": [.tr: "Journey Arc", .ja: "ジャーニーアーク", .en: "Journey Arc", .fr: "Arc du trajet"],
        "pro_feature_haptics": [.tr: "Nefes rehberi", .ja: "ブレスガイド", .en: "Breathing guide", .fr: "Guide respiratoire"],
        "pro_feature_sleep": [.tr: "Uyku otomasyonu", .ja: "睡眠オートメーション", .en: "Sleep automation", .fr: "Automatisation du sommeil"],
        "pro_price": [.tr: "$4.99", .ja: "$4.99", .en: "$4.99", .fr: "4,99 $"],
        "sound_tokyo_metro": [.tr: "Tokyo Metrosu", .ja: "東京メトロ", .en: "Tokyo Metro", .fr: "Métro de Tokyo"],
        "sound_shinkansen": [.tr: "Shinkansen", .ja: "新幹線", .en: "Shinkansen", .fr: "Shinkansen"],
        "sound_paris_metro": [.tr: "Paris Metrosu", .ja: "パリのメトロ", .en: "Paris Métro", .fr: "Métro Parisien"],
        "sound_istanbul_ferry": [.tr: "İstanbul Vapuru", .ja: "イスタンブールのフェリー", .en: "Istanbul Ferry", .fr: "Ferry d’Istanbul"],
        "sound_tokyo_rain": [.tr: "Tokyo Yağmuru", .ja: "東京の雨", .en: "Tokyo Rain", .fr: "Pluie de Tokyo"],
        "sound_deep_train": [.tr: "Derin Tren", .ja: "深い列車", .en: "Deep Train", .fr: "Train Profond"],
        "sound_night_cafe": [.tr: "Gece Kafesi", .ja: "夜のカフェ", .en: "Night Café", .fr: "Café Nocturne"],
        "sound_minka_library": [.tr: "Minka Kütüphanesi", .ja: "民家の書斎", .en: "Minka Library", .fr: "Bibliothèque Minka"],
        "sound_kyoto_bamboo": [.tr: "Kyoto Bambusu", .ja: "京都の竹林", .en: "Kyoto Bamboo", .fr: "Bambous de Kyoto"],
        "sound_temple_bell": [.tr: "Tapınak Çanı", .ja: "寺の鐘", .en: "Temple Bell", .fr: "Cloche du Temple"],
        "sound_rain_window": [.tr: "Yağmurlu Pencere", .ja: "窓の雨", .en: "Rain Window", .fr: "Pluie sur Vitre"],
        "sound_night_forest": [.tr: "Gece Ormanı", .ja: "夜の森", .en: "Night Forest", .fr: "Forêt Nocturne"],
        "mixer_volume": [.tr: "Ses", .ja: "音量", .en: "Volume", .fr: "Volume"],
        "mixer_secondary": [.tr: "İkinci katman", .ja: "セカンダリ", .en: "Secondary layer", .fr: "Couche secondaire"],
        "mixer_locked": [.tr: "Pro ile açılır", .ja: "Proで解除", .en: "Unlock with Pro", .fr: "Débloquer avec Pro"],
        "sounds_title": [.tr: "Sesler", .ja: "サウンド", .en: "Sounds", .fr: "Sons"],
        "timer_until": [.tr: "Rota bitene kadar", .ja: "到着まで", .en: "Until arrival", .fr: "Jusqu’à l’arrivée"],
        "privacy_body": [.tr: "Stillway tamamen cihaz üzerindedir. Hesap yok, analitik yok, reklam yok.", .ja: "Stillwayは完全に端末内で動作します。アカウント、分析、広告はありません。", .en: "Stillway is fully on-device. No accounts, no analytics, no ads.", .fr: "Stillway fonctionne entièrement sur l’appareil. Pas de compte, pas d’analyse, pas de pub."],
        "toast_started": [.tr: "Başladı", .ja: "開始しました", .en: "Started", .fr: "Démarré"],
        "toast_stopped": [.tr: "Durdu", .ja: "停止しました", .en: "Stopped", .fr: "Arrêté"]
    ]
}
