// MARK: - String+Validation.swift
// Amaç: String tipine doğrulama (validation) yardımcı metotları ekler.
// Açıklama: E-posta formatı kontrolü, şifre güç kontrolü, boşluk kontrolü gibi
//           form doğrulama işlemlerini String üzerinden doğrudan çağırılabilir hale getirir.
//           Bu sayede ViewModel katmanında validasyon mantığı çok temiz kalır.

import Foundation

extension String {
    
    // MARK: - E-posta Geçerlilik Kontrolü
    // RFC 5322 standardına uygun basitleştirilmiş regex ile kontrol eder.
    // Örnek: "kullanici@example.com".isValidEmail → true
    //        "kullanici@".isValidEmail → false
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    // MARK: - Şifre Güç Kontrolü
    // En az 6 karakter olmalı. Production'da daha güçlü kurallar eklenebilir.
    // Minimum uzunluk Firebase Auth'un varsayılan gereksinimidir.
    var isValidPassword: Bool {
        return self.count >= 6
    }
    
    // MARK: - Güçlü Şifre Kontrolü
    // En az 8 karakter, en az 1 büyük harf, 1 küçük harf ve 1 rakam içermeli.
    // Bitirme projesinde güvenlik farkındalığını göstermek için eklendi.
    var isStrongPassword: Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d).{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: self)
    }
    
    // MARK: - Boşluk Kontrolü (Trim sonrası)
    // Kullanıcının sadece boşluk girip girmediğini kontrol eder.
    // Whitespace trim edildikten sonra boş mu diye bakar.
    var isBlank: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - İsim Geçerlilik Kontrolü
    // En az 2 karakter ve sadece harf + boşluk içermeli.
    var isValidName: Bool {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { return false }
        let nameRegex = "^[a-zA-ZğüşıöçĞÜŞİÖÇ\\s]+$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return namePredicate.evaluate(with: trimmed)
    }
    
    // MARK: - Trimlenmiş Hali
    // Başındaki ve sonundaki boşlukları temizlenmiş halini döndürür.
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Para Formatı
    // Sayısal string'i Türk Lirası formatına çevirir.
    // Örnek: "1500" → "₺1.500"
    var asCurrency: String {
        guard let number = Double(self) else { return self }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₺"
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: number)) ?? self
    }
}
