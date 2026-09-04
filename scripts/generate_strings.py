#!/usr/bin/env python3
"""Write tr/ja/en/fr Localizable.strings from the MISSING_AND_TODOS key list."""

from __future__ import annotations

import pathlib

ROOT = pathlib.Path("/workspace/Stillway/Resources")

# key: (tr, ja, en, fr)
STRINGS: dict[str, tuple[str, str, str, str]] = {
    "app_name": ("Stillway", "Stillway", "Stillway", "Stillway"),
    "ctx_commute": ("Yolculuk", "通勤", "Commute", "Trajet"),
    "ctx_focus": ("Odak", "集中", "Focus", "Concentration"),
    "ctx_sleep": ("Uyku", "睡眠", "Sleep", "Sommeil"),
    "ctx_reset": ("Dinlenme", "リセット", "Reset", "Pause"),
    "ctx_walking": ("Yürüyüş", "散歩", "Walking", "Marche"),
    "ctx_deepwork": ("Sıkı Odak", "集中作業", "Deep Work", "Travail profond"),
    "ctx_unknown": ("Stillway", "Stillway", "Stillway", "Stillway"),
    "ctx_auto": ("Otomatik", "自動", "Auto", "Auto"),
    "snd_tokyo_metro": ("Tokyo Metrosu", "東京メトロ", "Tokyo Metro", "Métro de Tokyo"),
    "snd_shinkansen": ("Shinkansen", "新幹線", "Shinkansen", "Shinkansen"),
    "snd_paris_metro": ("Paris Metrosu", "パリのメトロ", "Paris Métro", "Métro Parisien"),
    "snd_istanbul_ferry": ("İstanbul Vapuru", "イスタンブールのフェリー", "Istanbul Ferry", "Ferry d'Istanbul"),
    "snd_tokyo_rain": ("Tokyo Yağmuru", "東京の雨", "Tokyo Rain", "Pluie de Tokyo"),
    "snd_deep_train": ("Derin Tren", "深い列車", "Deep Train", "Train Profond"),
    "snd_night_cafe": ("Gece Kafesi", "夜のカフェ", "Night Café", "Café Nocturne"),
    "snd_minka_library": ("Minka Kütüphanesi", "民家の書斎", "Minka Library", "Bibliothèque Minka"),
    "snd_kyoto_bamboo": ("Kyoto Bambusu", "京都の竹林", "Kyoto Bamboo", "Bambous de Kyoto"),
    "snd_temple_bell": ("Tapınak Çanı", "寺の鐘", "Temple Bell", "Cloche du Temple"),
    "snd_rain_window": ("Yağmurlu Pencere", "窓の雨", "Rain Window", "Pluie sur Vitre"),
    "snd_night_forest": ("Gece Ormanı", "夜の森", "Night Forest", "Forêt Nocturne"),
    "place_unknown": ("Bilinmeyen", "未設定", "Unknown", "Inconnu"),
    "place_home": ("Ev", "家", "Home", "Maison"),
    "place_work": ("İş", "職場", "Work", "Bureau"),
    "place_library": ("Kütüphane", "図書館", "Library", "Bibliothèque"),
    "place_cafe": ("Kafe", "カフェ", "Café", "Café"),
    "place_gym": ("Spor Salonu", "ジム", "Gym", "Salle de sport"),
    "place_other": ("Diğer", "その他", "Other", "Autre"),
    "btn_start": ("Başlat", "開始", "Start", "Démarrer"),
    "btn_stop": ("Durdur", "停止", "Stop", "Arrêter"),
    "btn_cancel": ("Vazgeç", "キャンセル", "Cancel", "Annuler"),
    "btn_continue": ("Devam", "続ける", "Continue", "Continuer"),
    "btn_save": ("Kaydet", "保存", "Save", "Enregistrer"),
    "btn_skip": ("Şimdi değil", "今はしない", "Not now", "Pas maintenant"),
    "btn_done": ("Tamam", "完了", "Done", "OK"),
    "btn_begin": ("Başla", "始める", "Begin", "Commencer"),
    "timer_min": ("dk", "分", "min", "min"),
    "timer_until_end": ("Rota bitene kadar", "到着まで", "Until arrival", "Jusqu'à l'arrivée"),
    "volume": ("Ses", "音量", "Volume", "Volume"),
    "mix_layer": ("İkinci katman", "セカンダリ", "Secondary layer", "Couche secondaire"),
    "pro_badge": ("Pro", "Pro", "Pro", "Pro"),
    "notif_commute": ("Yolculuk başlatılsın mı?", "通勤を開始しますか？", "Start commute?", "Démarrer le trajet?"),
    "notif_sleep": ("Uyku modu başlatılsın mı?", "睡眠モードを開始しますか？", "Start sleep mode?", "Démarrer le mode sommeil?"),
    "notif_focus": ("Odak başlatılsın mı?", "集中を開始しますか？", "Start focus?", "Démarrer la concentration?"),
    "notif_place_label": ("Bu yere birkaç kez geldiniz. Burası ne?", "この場所に何度か来ています。どこですか？", "You've been here a few times. What is this place?", "Vous venez souvent ici. Quel est ce lieu?"),
    "onboard_1_title": ("Stillway seni öğreniyor.", "Stillwayはあなたを学びます。", "Stillway is learning you.", "Stillway apprend à vous connaître."),
    "onboard_1_body": (
        "Nerede olduğunu, ne yaptığını anlıyor. Sen hiçbir şey seçmeden doğru müziği açıyor.",
        "どこにいて、何をしているかを理解します。選ばなくても、正しい音が始まります。",
        "It understands where you are and what you're doing. The right sound starts without you choosing.",
        "Il comprend où vous êtes et ce que vous faites. Le bon son démarre sans que vous choisissiez.",
    ),
    "onboard_1_btn": ("Konuma İzin Ver", "位置情報を許可", "Allow Location", "Autoriser la localisation"),
    "onboard_2_title": ("Telefonu kaldır.", "スマホをしまって。", "Put the phone down.", "Rangez le téléphone."),
    "onboard_2_body": (
        "AirPods'unu taktığında ve bir durağa yaklaştığında Stillway otomatik olarak başlar.",
        "AirPodsをつけて駅に近づくと、Stillwayが自動で始まります。",
        "When you put in AirPods and approach a station, Stillway starts on its own.",
        "Quand vous mettez vos AirPods et approchez d'une station, Stillway démarre tout seul.",
    ),
    "onboard_2_btn": ("Kısayolu Ayarla", "ショートカットを設定", "Set Up Shortcut", "Configurer le raccourci"),
    "onboard_2_skip": ("Şimdi değil →", "今はしない →", "Not now →", "Pas maintenant →"),
    "onboard_3_title": ("İyi yolculuklar.", "よい旅を。", "Safe travels.", "Bon voyage."),
    "onboard_3_body": (
        "Sen sadece yaşa. Geri kalanı biz anlıyoruz.",
        "ただ生きてください。あとは私たちが理解します。",
        "Just live. We'll understand the rest.",
        "Vivez simplement. Nous comprenons le reste.",
    ),
    "onboard_3_btn": ("Başla", "始める", "Begin", "Commencer"),
    "settings_title": ("Ayarlar", "設定", "Settings", "Réglages"),
    "settings_general": ("Genel", "一般", "General", "Général"),
    "settings_context": ("Bağlam Tespiti", "コンテキスト検出", "Context Detection", "Détection de contexte"),
    "settings_context_desc": (
        "Yer, hareket ve transit duraklarından bağlamı otomatik anla.",
        "場所・動き・駅から状況を自動で理解します。",
        "Understand context from places, motion, and transit stops.",
        "Comprendre le contexte à partir des lieux, du mouvement et des stations.",
    ),
    "settings_sleep": ("Uyku Modu", "スリープモード", "Sleep Mode", "Mode sommeil"),
    "settings_sleep_desc": (
        "Evde, gece ve telefon düzken uyku sesini öner.",
        "自宅で夜間、端末が水平なときに睡眠サウンドを提案します。",
        "Suggest sleep sound at home, at night, when the phone is flat.",
        "Proposer le son sommeil à la maison, la nuit, téléphone à plat.",
    ),
    "settings_sleep_start": ("Uyku Başlangıcı", "就寝時刻", "Sleep Start", "Début du sommeil"),
    "settings_haptic": ("Haptik Nefes Rehberi", "触覚ブレスガイド", "Haptic Breath Guide", "Guide respiratoire haptique"),
    "settings_haptic_desc": (
        "Cepte, ekran kapalı kutu nefesi (4-4-4-4).",
        "ポケットの中で画面オフのボックス呼吸。",
        "Box breathing in your pocket, screen off.",
        "Respiration carrée dans la poche, écran éteint.",
    ),
    "settings_language": ("Dil", "言語", "Language", "Langue"),
    "settings_language_note": (
        "Dil değişikliği anında geçerli olur.",
        "言語の変更はすぐに反映されます。",
        "Language changes apply instantly.",
        "Le changement de langue s'applique immédiatement.",
    ),
    "settings_pro_section": ("Pro", "Pro", "Pro", "Pro"),
    "settings_pro_feature_1": ("12 sesin tamamı", "全12サウンド", "All 12 sounds", "Les 12 sons"),
    "settings_pro_feature_2": ("Çoklu miksleme", "マルチミックス", "Multi-track mixing", "Mixage multi-pistes"),
    "settings_pro_feature_3": ("Otomatik başlatma", "自動スタート", "Auto-start", "Démarrage automatique"),
    "settings_pro_feature_4": ("Yer öğrenimi", "場所の学習", "Place learning", "Apprentissage des lieux"),
    "settings_pro_feature_5": ("Journey Arc", "ジャーニーアーク", "Journey Arc", "Arc du trajet"),
    "settings_pro_feature_6": ("Nefes rehberi ve uyku otomasyonu", "ブレスガイドと睡眠オートメーション", "Breathing guide and sleep automation", "Guide respiratoire et sommeil auto"),
    "settings_pro_btn": ("Pro'ya Geç — $4.99", "Proにアップグレード — $4.99", "Go Pro — $4.99", "Passer à Pro — 4,99 $"),
    "settings_restore": ("Satın Alımı Geri Yükle", "購入を復元", "Restore Purchase", "Restaurer l'achat"),
    "settings_about": ("Hakkında", "情報", "About", "À propos"),
    "settings_version": ("Sürüm", "バージョン", "Version", "Version"),
    "settings_privacy": ("Gizlilik Politikası", "プライバシーポリシー", "Privacy Policy", "Politique de confidentialité"),
    "places_title": ("Yerlerim", "場所", "My Places", "Mes lieux"),
    "places_empty": (
        "Henüz öğrenilen yer yok. Stillway sizi birkaç gün izleyecek.",
        "まだ学習した場所はありません。Stillwayが数日かけて学びます。",
        "No learned places yet. Stillway will watch for a few days.",
        "Aucun lieu appris pour l'instant. Stillway observera quelques jours.",
    ),
    "places_visits": ("ziyaret", "回", "visits", "visites"),
    "places_last_seen": ("Son görülme", "最終訪問", "Last seen", "Dernière visite"),
    "places_auto_on": ("Otomatik açık", "自動オン", "Auto on", "Auto activé"),
    "places_auto_off": ("Otomatik kapalı", "自動オフ", "Auto off", "Auto désactivé"),
    "label_title": ("Buraya %d kez geldiniz.", "ここに%d回訪れました。", "You've been here %d times.", "Vous êtes venu ici %d fois."),
    "label_body": (
        "Bu yeri tanımlarsanız Stillway otomatik mod açabilir.",
        "この場所を指定すると、Stillwayが自動モードを使えます。",
        "If you label this place, Stillway can turn on auto mode.",
        "Si vous nommez ce lieu, Stillway pourra activer le mode auto.",
    ),
    "label_done": ("Ayarlandı!", "設定しました", "All set!", "C'est noté !"),
    "pro_title": ("Stillway Pro", "Stillway Pro", "Stillway Pro", "Stillway Pro"),
    "pro_body": (
        "Tüm sesler, otomatik başlatma, miksleme ve yer öğrenimi.",
        "全サウンド、自動スタート、ミックス、場所の学習。",
        "All sounds, auto-start, mixing, and place learning.",
        "Tous les sons, démarrage auto, mixage et apprentissage des lieux.",
    ),
    "pro_active": ("Pro aktif", "Pro有効", "Pro active", "Pro activé"),
    "pro_restored": ("Satın alım geri yüklendi.", "購入を復元しました。", "Purchase restored.", "Achat restauré."),
    "pro_error": ("Satın alma tamamlanamadı.", "購入できませんでした。", "Purchase could not be completed.", "L'achat n'a pas pu aboutir."),
    "privacy_body": (
        "Stillway tamamen cihaz üzerindedir. Hesap yok, analitik yok, reklam yok.",
        "Stillwayは完全に端末内で動作します。アカウント、分析、広告はありません。",
        "Stillway is fully on-device. No accounts, no analytics, no ads.",
        "Stillway fonctionne entièrement sur l'appareil. Pas de compte, pas d'analyse, pas de pub.",
    ),
    "sounds_title": ("Sesler", "サウンド", "Sounds", "Sons"),
    "mixer_locked": ("Pro ile açılır", "Proで解除", "Unlock with Pro", "Débloquer avec Pro"),
    "toast_started": ("Başladı", "開始しました", "Started", "Démarré"),
    "toast_stopped": ("Durdu", "停止しました", "Stopped", "Arrêté"),
    "auto_banner": ("Otomatik oturum başladı", "自動セッション開始", "Auto session started", "Session auto démarrée"),
}


def escape(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"')


def write_lang(code: str, index: int) -> None:
    folder = ROOT / f"{code}.lproj"
    folder.mkdir(parents=True, exist_ok=True)
    lines = [f'"{key}" = "{escape(vals[index])}";' for key, vals in STRINGS.items()]
    (folder / "Localizable.strings").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(code, len(lines))


def main() -> None:
    for i, code in enumerate(("tr", "ja", "en", "fr")):
        write_lang(code, i)


if __name__ == "__main__":
    main()
