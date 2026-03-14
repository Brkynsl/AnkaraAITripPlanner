// MARK: - UIColor+Theme.swift
// Amaç: UIColor sınıfına tema ile ilgili yardımcı metotlar ekler.
// Açıklama: Gradient oluşturma, renk aydınlatma/koyulaştırma ve
// hex string'den renk oluşturma gibi sık kullanılan renk işlemlerini
// extension olarak sunarak kod tekrarını önler.

import UIKit

extension UIColor {
    
    // MARK: - Hex String'den Renk Oluşturma
    // Tasarımcıdan gelen hex kodlarını doğrudan UIColor'a çevirmek için kullanılır.
    // Örnek kullanım: UIColor(hex: "#FF5733") veya UIColor(hex: "FF5733")
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    // MARK: - Rengi Aydınlatma
    // Bir rengin daha açık tonunu elde etmek için kullanılır.
    // percentage: 0.0 (değişim yok) ile 1.0 (tamamen beyaz) arasında
    func lighter(by percentage: CGFloat = 0.2) -> UIColor {
        return self.adjust(by: abs(percentage))
    }
    
    // MARK: - Rengi Koyulaştırma
    // Bir rengin daha koyu tonunu elde etmek için kullanılır.
    // Hover state, pressed state gibi durumlarda kullanışlıdır.
    func darker(by percentage: CGFloat = 0.2) -> UIColor {
        return self.adjust(by: -abs(percentage))
    }
    
    // MARK: - Renk Ayarlama Yardımcısı (Private)
    // Rengin HSB (Hue, Saturation, Brightness) değerlerini değiştirerek
    // daha açık veya koyu tonlar üretir.
    private func adjust(by percentage: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            let newBrightness = max(min(brightness + percentage, 1.0), 0.0)
            return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
        }
        return self
    }
    
    // MARK: - Belirli Alpha ile Renk Kopyalama
    // Mevcut rengi farklı bir saydamlık değeriyle kullanmak için.
    // Örneğin: AppColors.primary.withAlpha(0.5) — yarı saydam
    func withAlpha(_ alpha: CGFloat) -> UIColor {
        return self.withAlphaComponent(alpha)
    }
}
