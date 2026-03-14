// MARK: - HapticManager.swift
// Amaç: Uygulamadaki dokunsal geri bildirimleri (haptic feedback) merkezi olarak yönetir.
// Açıklama: iOS'un Taptic Engine özelliğini kullanarak buton tıklamaları, başarılı
//           işlemler, hatalar gibi durumlarda kullanıcıya fiziksel geri bildirim verir.
//           Haptic feedback, uygulamanın profesyonel ve polished hissi vermesini sağlar.
//           Singleton pattern ile uygulama genelinde tek bir instance üzerinden erişilir.

import UIKit

final class HapticManager {
    
    // MARK: - Singleton
    // Uygulama genelinde tek bir HapticManager instance'ı kullanılır.
    // Bu pattern gereksiz obje oluşturmayı önler ve merkezi yönetim sağlar.
    static let shared = HapticManager()
    
    // Dışarıdan yeni instance oluşturulmasını engellemek için private init
    private init() {}
    
    // MARK: - Darbe (Impact) Feedback
    // Buton tıklamaları, kart seçimleri gibi etkileşimlerde kullanılır.
    // style parametresi darbenin şiddetini belirler:
    //   .light — hafif dokunma
    //   .medium — orta şiddette (varsayılan)
    //   .heavy — güçlü darbe
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - Bildirim (Notification) Feedback
    // İşlem sonuçlarını bildirmek için kullanılır.
    //   .success — yeşil tik / başarılı giriş
    //   .warning — uyarı durumu
    //   .error — hatalı şifre / validasyon hatası
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    // MARK: - Seçim (Selection) Feedback
    // Picker, segment control, liste seçimi gibi yerlerde kullanılır.
    // En hafif feedback tipidir, sürekli tekrarlayan seçimlerde rahatsız etmez.
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    // MARK: - Kısa Yollar
    // Sık kullanılan senaryolar için tek satırlık erişim.
    
    /// Başarılı işlem feedback'i (giriş yapıldı, plan oluşturuldu vb.)
    func success() {
        notification(type: .success)
    }
    
    /// Hata feedback'i (yanlış şifre, validasyon hatası vb.)
    func error() {
        notification(type: .error)
    }
    
    /// Uyarı feedback'i
    func warning() {
        notification(type: .warning)
    }
    
    /// Hafif buton tıklama feedback'i
    func buttonTap() {
        impact(style: .light)
    }
    
    /// Hafif darbe (TripDetail gibi yerlerde kullanılır)
    func lightImpact() {
        impact(style: .light)
    }
    
    /// Seçim değişti feedback'i (Harita veya Liste seçimi)
    func selectionChanged() {
        selection()
    }
    
    /// Kart seçme feedback'i
    func cardSelect() {
        impact(style: .medium)
    }
}
