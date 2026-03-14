// MARK: - AppUser.swift
// Amaç: Uygulamadaki kullanıcıyı temsil eden veri modeli.
// Açıklama: Firebase Authentication'dan gelen kullanıcı bilgilerini ve
//           Firestore'da saklanan profil verilerini birleştirir.
//           Codable protokolü sayesinde Firestore'a yazılıp okunabilir.
//           Bu model uygulama genelinde kullanıcı kimliğini taşır.

import Foundation

// MARK: - Giriş Sağlayıcı Tipi
// Kullanıcının hangi yöntemle giriş yaptığını belirtir.
// Firestore'da string olarak saklanır, uygulama içinde enum olarak kullanılır.
enum AuthProvider: String, Codable {
    case email = "email"
    case apple = "apple"
    case google = "google"
}

// MARK: - Kullanıcı Modeli
struct AppUser: Codable {
    
    // Firebase Auth UID — kullanıcının benzersiz kimliği
    let uid: String
    
    // Kullanıcının görünen adı
    var displayName: String
    
    // E-posta adresi
    var email: String
    
    // Profil fotoğrafı URL'i (opsiyonel — Google/Apple'dan gelebilir)
    var photoURL: String?
    
    // Hangi yöntemle giriş yapıldığı
    var authProvider: AuthProvider
    
    // Onboarding ekranlarını tamamlamış mı?
    // Bu değer false ise kullanıcı onboarding'e yönlendirilir.
    var hasCompletedOnboarding: Bool
    
    // Hesap oluşturulma tarihi
    var createdAt: Date
    
    // Son güncelleme tarihi
    var updatedAt: Date?
    
    // MARK: - Firestore Dictionary'ye Çevirme
    // Firestore'a yazmak için kullanıcı verilerini [String: Any] formatına çevirir.
    // Firestore'un kendi Timestamp tipini kullanıyoruz tarih alanları için.
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "uid": uid,
            "displayName": displayName,
            "email": email,
            "authProvider": authProvider.rawValue,
            "hasCompletedOnboarding": hasCompletedOnboarding,
            "createdAt": createdAt
        ]
        if let photoURL = photoURL {
            dict["photoURL"] = photoURL
        }
        if let updatedAt = updatedAt {
            dict["updatedAt"] = updatedAt
        }
        return dict
    }
    
    // MARK: - Firestore Dictionary'den Oluşturma
    // Firestore'dan okunan veriyi AppUser objesine çevirir.
    // guard let ile zorunlu alanları kontrol eder, eksikse nil döner.
    static func fromDictionary(_ dict: [String: Any], uid: String) -> AppUser? {
        guard let displayName = dict["displayName"] as? String,
              let email = dict["email"] as? String,
              let authProviderRaw = dict["authProvider"] as? String,
              let authProvider = AuthProvider(rawValue: authProviderRaw),
              let hasCompletedOnboarding = dict["hasCompletedOnboarding"] as? Bool else {
            return nil
        }
        
        // Firestore Timestamp'ı Date'e çevirme
        let createdAt: Date
        if let timestamp = dict["createdAt"] as? Date {
            createdAt = timestamp
        } else {
            createdAt = Date()
        }
        
        return AppUser(
            uid: uid,
            displayName: displayName,
            email: email,
            photoURL: dict["photoURL"] as? String,
            authProvider: authProvider,
            hasCompletedOnboarding: hasCompletedOnboarding,
            createdAt: createdAt,
            updatedAt: dict["updatedAt"] as? Date
        )
    }
}
