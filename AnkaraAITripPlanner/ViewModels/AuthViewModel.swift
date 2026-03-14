// MARK: - AuthViewModel.swift
// Amaç: Giriş, kayıt ve şifre sıfırlama ekranlarının iş mantığını yönetir.
// Açıklama: MVVM mimarisinde ViewModel katmanı, View (ViewController) ile
//           Service (AuthService) arasında köprü görevi görür.
//           Validasyon, loading state yönetimi ve hata işleme bu katmanda yapılır.
//           ViewController sadece UI güncellemelerine odaklanır.
//           Closure tabanlı binding ile VC'ye state değişikliklerini bildirir.

import Foundation

// MARK: - Auth Durumu
// ViewModel'in mevcut durumunu temsil eder.
// ViewController bu duruma göre UI'ı günceller.
enum AuthState {
    case idle                    // Başlangıç — hiçbir işlem yok
    case loading                 // İşlem devam ediyor — loading göster
    case success(AppUser)        // Giriş/kayıt başarılı
    case error(String)           // Hata oluştu — mesajı göster
    case passwordResetSent       // Şifre sıfırlama maili gönderildi
}

final class AuthViewModel {
    
    // MARK: - Servisler
    private let authService: AuthService
    private let firestoreService: FirestoreService
    
    // MARK: - State Binding
    // State değiştiğinde ViewController'a haber verir.
    // VC, viewDidLoad'da bu closure'ı set eder.
    // Örnek: viewModel.onStateChanged = { [weak self] state in ... }
    var onStateChanged: ((AuthState) -> Void)?
    
    // Mevcut durum — değiştiğinde otomatik olarak binding closure'ı çağırır
    private(set) var state: AuthState = .idle {
        didSet {
            onStateChanged?(state)
        }
    }
    
    // MARK: - Başlatma
    init(authService: AuthService = .shared, firestoreService: FirestoreService = .shared) {
        self.authService = authService
        self.firestoreService = firestoreService
    }
    
    // ============================================================
    // E-POSTA İLE GİRİŞ
    // ============================================================
    // Önce form alanlarını doğrular, sonra AuthService'i çağırır.
    // Hata durumunda kullanıcı dostu Türkçe mesaj döner.
    func signInWithEmail(email: String, password: String) {
        // Validasyon
        let emailResult = FormValidator.validateEmail(email)
        guard emailResult.isValid else {
            state = .error(emailResult.errorMessage ?? "Geçersiz e-posta.")
            return
        }
        
        let passwordResult = FormValidator.validatePassword(password)
        guard passwordResult.isValid else {
            state = .error(passwordResult.errorMessage ?? "Geçersiz şifre.")
            return
        }
        
        // Loading başlat
        state = .loading
        
        // Firebase Auth çağrısı
        authService.signInWithEmail(email: email.trimmed, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.state = .success(user)
                case .failure(let error):
                    self?.state = .error(self?.friendlyErrorMessage(error) ?? "Giriş başarısız.")
                }
            }
        }
    }
    
    // ============================================================
    // E-POSTA İLE KAYIT OL
    // ============================================================
    func signUpWithEmail(name: String, email: String, password: String, confirmPassword: String) {
        // Tüm alanları doğrula
        let nameResult = FormValidator.validateName(name)
        guard nameResult.isValid else {
            state = .error(nameResult.errorMessage ?? "Geçersiz isim.")
            return
        }
        
        let emailResult = FormValidator.validateEmail(email)
        guard emailResult.isValid else {
            state = .error(emailResult.errorMessage ?? "Geçersiz e-posta.")
            return
        }
        
        let passwordResult = FormValidator.validatePassword(password)
        guard passwordResult.isValid else {
            state = .error(passwordResult.errorMessage ?? "Geçersiz şifre.")
            return
        }
        
        let matchResult = FormValidator.validatePasswordMatch(password, confirmPassword)
        guard matchResult.isValid else {
            state = .error(matchResult.errorMessage ?? "Şifreler eşleşmiyor.")
            return
        }
        
        state = .loading
        
        authService.signUpWithEmail(
            email: email.trimmed,
            password: password,
            displayName: name.trimmed
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.state = .success(user)
                case .failure(let error):
                    self?.state = .error(self?.friendlyErrorMessage(error) ?? "Kayıt başarısız.")
                }
            }
        }
    }
    
    // ============================================================
    // ŞİFREMİ UNUTTUM
    // ============================================================
    func resetPassword(email: String) {
        let emailResult = FormValidator.validateEmail(email)
        guard emailResult.isValid else {
            state = .error(emailResult.errorMessage ?? "Geçersiz e-posta.")
            return
        }
        
        state = .loading
        
        authService.resetPassword(email: email.trimmed) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.state = .passwordResetSent
                case .failure(let error):
                    self?.state = .error(self?.friendlyErrorMessage(error) ?? "İşlem başarısız.")
                }
            }
        }
    }
    
    // ============================================================
    // APPLE İLE GİRİŞ
    // ============================================================
    func signInWithApple(idToken: String, nonce: String) {
        state = .loading
        
        authService.signInWithApple(idToken: idToken, nonce: nonce) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.state = .success(user)
                case .failure(let error):
                    self?.state = .error(self?.friendlyErrorMessage(error) ?? "Apple ile giriş başarısız.")
                }
            }
        }
    }
    
    // ============================================================
    // GOOGLE İLE GİRİŞ
    // ============================================================
    func signInWithGoogle(idToken: String, accessToken: String) {
        state = .loading
        
        authService.signInWithGoogle(idToken: idToken, accessToken: accessToken) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.state = .success(user)
                case .failure(let error):
                    self?.state = .error(self?.friendlyErrorMessage(error) ?? "Google ile giriş başarısız.")
                }
            }
        }
    }
    
    // ============================================================
    // NONCE YARDIMCILARI (Apple Sign-In)
    // ============================================================
    func generateAppleNonce() -> String {
        return authService.generateNonce()
    }
    
    func sha256ForNonce(_ nonce: String) -> String {
        return authService.sha256(nonce)
    }
    
    var activeNonce: String? {
        return authService.activeNonce
    }
    
    // ============================================================
    // KULLANICI DOSTU HATA MESAJLARI
    // ============================================================
    // Firebase Auth hatalarını Türkçe ve anlaşılır mesajlara çevirir.
    // Teknik hata kodlarını kullanıcıya göstermek doğru olmaz.
    private func friendlyErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError
        
        // Firebase Auth hata kodları
        switch nsError.code {
        case 17005: // ERROR_USER_DISABLED
            return "Bu hesap devre dışı bırakılmış."
        case 17008: // ERROR_INVALID_EMAIL
            return "Geçersiz e-posta formatı."
        case 17009: // ERROR_WRONG_PASSWORD
            return "E-posta veya şifre hatalı."
        case 17011: // ERROR_USER_NOT_FOUND
            return "Bu e-posta ile kayıtlı bir hesap bulunamadı."
        case 17007: // ERROR_EMAIL_ALREADY_IN_USE
            return "Bu e-posta adresi zaten kullanılıyor."
        case 17026: // ERROR_WEAK_PASSWORD
            return "Şifre çok zayıf. En az 6 karakter kullanın."
        case 17010: // ERROR_CREDENTIAL_ALREADY_IN_USE
            return "Bu hesap bilgileri zaten başka bir kullanıcı tarafından kullanılıyor."
        case 17020: // ERROR_NETWORK_REQUEST_FAILED
            return "İnternet bağlantınızı kontrol edin."
        case 17999: // ERROR_INTERNAL_ERROR
            return "Sunucu hatası oluştu. Lütfen tekrar deneyin."
        default:
            return error.localizedDescription
        }
    }
}
