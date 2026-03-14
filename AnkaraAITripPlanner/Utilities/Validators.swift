// MARK: - Validators.swift
// Amaç: Form doğrulama mantığını merkezi bir yapıda toplar.
// Açıklama: String extension'larındaki temel kontrollerin üzerine, daha kapsamlı
//           doğrulama sonuçları döndüren bir yapı sunar. ViewModel'ler bu yapıyı
//           kullanarak form alanlarını doğrular ve kullanıcıya anlamlı hata mesajları gösterir.

import Foundation

// MARK: - Doğrulama Sonucu
// Her doğrulama işlemi bir ValidationResult döndürür.
// Başarılıysa .valid, başarısızsa .invalid(mesaj) döner.
// Bu pattern sayesinde her hata için özel Türkçe mesaj verilebilir.
enum ValidationResult {
    case valid
    case invalid(String)
    
    var isValid: Bool {
        switch self {
        case .valid: return true
        case .invalid: return false
        }
    }
    
    var errorMessage: String? {
        switch self {
        case .valid: return nil
        case .invalid(let message): return message
        }
    }
}

// MARK: - Form Doğrulayıcı
// Statik metotlarla farklı alan tiplerini doğrulayan ana yapı.
// Her metot bir ValidationResult döndürür.
struct FormValidator {
    
    // MARK: - E-posta Doğrulama
    static func validateEmail(_ email: String) -> ValidationResult {
        let trimmed = email.trimmed
        if trimmed.isEmpty {
            return .invalid("E-posta adresi boş bırakılamaz.")
        }
        if !trimmed.isValidEmail {
            return .invalid("Geçerli bir e-posta adresi giriniz.")
        }
        return .valid
    }
    
    // MARK: - Şifre Doğrulama
    static func validatePassword(_ password: String) -> ValidationResult {
        if password.isEmpty {
            return .invalid("Şifre boş bırakılamaz.")
        }
        if !password.isValidPassword {
            return .invalid("Şifre en az 6 karakter olmalıdır.")
        }
        return .valid
    }
    
    // MARK: - Şifre Eşleşme Kontrolü
    static func validatePasswordMatch(_ password: String, _ confirmPassword: String) -> ValidationResult {
        if confirmPassword.isEmpty {
            return .invalid("Şifre tekrarı boş bırakılamaz.")
        }
        if password != confirmPassword {
            return .invalid("Şifreler eşleşmiyor.")
        }
        return .valid
    }
    
    // MARK: - İsim Doğrulama
    static func validateName(_ name: String) -> ValidationResult {
        let trimmed = name.trimmed
        if trimmed.isEmpty {
            return .invalid("Ad soyad boş bırakılamaz.")
        }
        if !trimmed.isValidName {
            return .invalid("Geçerli bir ad soyad giriniz (en az 2 karakter, sadece harf).")
        }
        return .valid
    }
    
    // MARK: - Bütçe Doğrulama
    static func validateBudget(_ budgetText: String) -> ValidationResult {
        let trimmed = budgetText.trimmed
        if trimmed.isEmpty {
            return .invalid("Bütçe boş bırakılamaz.")
        }
        guard let budget = Double(trimmed) else {
            return .invalid("Geçerli bir sayı giriniz.")
        }
        if budget <= 0 {
            return .invalid("Bütçe sıfırdan büyük olmalıdır.")
        }
        if budget > 1_000_000 {
            return .invalid("Bütçe gerçekçi bir değer olmalıdır.")
        }
        return .valid
    }
    
    // MARK: - Gün Sayısı Doğrulama
    static func validateDays(_ daysText: String) -> ValidationResult {
        let trimmed = daysText.trimmed
        if trimmed.isEmpty {
            return .invalid("Gün sayısı boş bırakılamaz.")
        }
        guard let days = Int(trimmed) else {
            return .invalid("Geçerli bir sayı giriniz.")
        }
        if days < 1 {
            return .invalid("En az 1 gün seçmelisiniz.")
        }
        if days > 30 {
            return .invalid("En fazla 30 gün seçebilirsiniz.")
        }
        return .valid
    }
    
    // MARK: - Şehir Seçimi Doğrulama
    static func validateCity(_ city: String) -> ValidationResult {
        if city.trimmed.isEmpty {
            return .invalid("Lütfen bir şehir seçiniz.")
        }
        return .valid
    }
}
