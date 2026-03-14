// MARK: - AuthService.swift
// Amaç: Firebase Authentication işlemlerini yönetir.
// Açıklama: E-posta/şifre ile giriş, Apple Sign-In, Google Sign-In,
//           kayıt ol ve şifremi unuttum akışlarını uçtan uca yönetir.
//           AuthServiceProtocol'ü uygulayarak test edilebilir yapıyı korur.
//           Giriş başarılı olduğunda kullanıcı profili Firestore'a kaydedilir.
//
// ÖNEMLİ: Firebase SDK eklenmeden bu dosya derlenmez.
// SPM ile FirebaseAuth paketini eklemeyi unutmayın.

import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit

final class AuthService: AuthServiceProtocol {
    
    // MARK: - Singleton
    static let shared = AuthService()
    private let firestoreService = FirestoreService.shared
    
    // Apple Sign-In için geçerli nonce değeri (güvenlik için)
    // Her Sign-In isteğinde yeni bir nonce üretilir.
    private var currentNonce: String?
    
    private init() {}
    
    // MARK: - Mevcut Kullanıcı ID
    // Firebase Auth'daki mevcut oturum açmış kullanıcının UID'si.
    // Nil ise kullanıcı giriş yapmamış demektir.
    var currentUserId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    // MARK: - Giriş Durumu Kontrolü
    var isLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    // MARK: - Firebase Auth Kullanıcısı
    var currentFirebaseUser: User? {
        return Auth.auth().currentUser
    }
    
    // ============================================================
    // E-POSTA İLE GİRİŞ
    // ============================================================
    // Firebase Auth'un signIn(withEmail:password:) metodunu kullanır.
    // Başarılıysa Firestore'dan kullanıcı profilini çeker.
    // Profil yoksa yeni profil oluşturur (first-time login durumu).
    func signInWithEmail(
        email: String,
        password: String,
        completion: @escaping (Result<AppUser, Error>) -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let firebaseUser = result?.user else {
                completion(.failure(NSError(domain: "AuthService", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Giriş başarısız oldu."])))
                return
            }
            
            // Firestore'dan kullanıcı profilini çek
            self?.fetchOrCreateUser(firebaseUser: firebaseUser, authProvider: .email, completion: completion)
        }
    }
    
    // ============================================================
    // E-POSTA İLE KAYIT OL
    // ============================================================
    // Yeni kullanıcı oluşturur ve Firestore'a profil kaydeder.
    // displayName parametresi kullanılarak profil ismi ayarlanır.
    func signUpWithEmail(
        email: String,
        password: String,
        displayName: String,
        completion: @escaping (Result<AppUser, Error>) -> Void
    ) {
        print("DEBUG [AuthService]: Kayıt işlemi başlatıldı: \(email)")
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("DEBUG [AuthService]: Firebase Auth Kayıt Hatası: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let firebaseUser = result?.user else {
                print("DEBUG [AuthService]: Firebase Auth Kayıt Başarılı ama user objesi yok.")
                completion(.failure(NSError(domain: "AuthService", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Kayıt başarılı oldu ancak kullanıcı bilgisi alınamadı."])))
                return
            }
            
            print("DEBUG [AuthService]: Auth kaydı başarılı. UID: \(firebaseUser.uid)")
            
            // Kullanıcı modelini hazırla
            let appUser = AppUser(
                uid: firebaseUser.uid,
                displayName: displayName,
                email: email,
                photoURL: nil,
                authProvider: .email,
                hasCompletedOnboarding: false,
                createdAt: Date(),
                updatedAt: nil
            )
            
            // 1. Önce Firestore'a kaydet (Bu en kritik kısım)
            print("DEBUG [AuthService]: Firestore profil kaydı başlıyor...")
            self?.firestoreService.saveUser(appUser) { saveResult in
                switch saveResult {
                case .success:
                    print("DEBUG [AuthService]: Firestore profil kaydı başarılı.")
                    
                    // 2. Sonra profil ismini güncelle (Fire-and-forget, hata alsa da süreci bozmasın)
                    let changeRequest = firebaseUser.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges { profileError in
                        if let profileError = profileError {
                            print("DEBUG [AuthService]: Profil ismi güncellenirken hata (önemsiz): \(profileError.localizedDescription)")
                        } else {
                            print("DEBUG [AuthService]: Profil ismi başarıyla güncellendi.")
                        }
                    }
                    
                    // Firestore kaydı başarılı olduğu için sonucu dönüyoruz
                    completion(.success(appUser))
                    
                case .failure(let error):
                    print("DEBUG [AuthService]: Firestore profil kaydı HATASI: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    // ============================================================
    // APPLE İLE GİRİŞ
    // ============================================================
    // Apple Sign-In'den gelen idToken ve nonce ile Firebase'e giriş yapar.
    // ASAuthorizationController'dan gelen credential burada işlenir.
    func signInWithApple(
        idToken: String,
        nonce: String,
        completion: @escaping (Result<AppUser, Error>) -> Void
    ) {
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idToken,
            rawNonce: nonce
        )
        
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let firebaseUser = result?.user else {
                completion(.failure(NSError(domain: "AuthService", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Apple ile giriş başarısız."])))
                return
            }
            
            self?.fetchOrCreateUser(firebaseUser: firebaseUser, authProvider: .apple, completion: completion)
        }
    }
    
    // ============================================================
    // GOOGLE İLE GİRİŞ
    // ============================================================
    // Google Sign-In SDK'dan gelen idToken ve accessToken ile Firebase'e giriş yapar.
    func signInWithGoogle(
        idToken: String,
        accessToken: String,
        completion: @escaping (Result<AppUser, Error>) -> Void
    ) {
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: accessToken
        )
        
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let firebaseUser = result?.user else {
                completion(.failure(NSError(domain: "AuthService", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Google ile giriş başarısız."])))
                return
            }
            
            self?.fetchOrCreateUser(firebaseUser: firebaseUser, authProvider: .google, completion: completion)
        }
    }
    
    // ============================================================
    // ŞİFREMİ UNUTTUM
    // ============================================================
    // Firebase Auth'un sendPasswordReset(withEmail:) metodunu kullanır.
    // Kullanıcının e-posta adresine şifre sıfırlama linki gönderir.
    func resetPassword(
        email: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // ============================================================
    // ÇIKIŞ YAP
    // ============================================================
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // ============================================================
    // APPLE SIGN-IN YARDIMCI METOTLARI
    // ============================================================
    
    // MARK: - Nonce Üretme
    // Apple Sign-In güvenliği için rastgele nonce üretir.
    // Bu nonce, relay attack'ları önlemek için kullanılır.
    func generateNonce(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Nonce üretilirken hata oluştu: \(errorCode)")
        }
        
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }
        
        let nonceString = String(nonce)
        currentNonce = nonceString
        return nonceString
    }
    
    // MARK: - SHA256 Hash
    // Apple Sign-In için nonce'ın SHA256 hash'ini hesaplar.
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    // Mevcut nonce'a erişim
    var activeNonce: String? {
        return currentNonce
    }
    
    // ============================================================
    // YARDIMCI: Kullanıcı Profili Çek veya Oluştur
    // ============================================================
    // Giriş sonrası Firestore'dan kullanıcı profilini çeker.
    // İlk giriş ise yeni profil oluşturur.
    // Bu pattern tüm giriş yöntemleri için ortak kullanılır.
    private func fetchOrCreateUser(
        firebaseUser: User,
        authProvider: AuthProvider,
        completion: @escaping (Result<AppUser, Error>) -> Void
    ) {
        firestoreService.getUser(uid: firebaseUser.uid) { [weak self] result in
            switch result {
            case .success(let existingUser):
                // Kullanıcı zaten var — profilini döndür
                completion(.success(existingUser))
                
            case .failure:
                // İlk giriş — yeni profil oluştur
                let newUser = AppUser(
                    uid: firebaseUser.uid,
                    displayName: firebaseUser.displayName ?? "Kullanıcı",
                    email: firebaseUser.email ?? "",
                    photoURL: firebaseUser.photoURL?.absoluteString,
                    authProvider: authProvider,
                    hasCompletedOnboarding: false,
                    createdAt: Date(),
                    updatedAt: nil
                )
                
                self?.firestoreService.saveUser(newUser) { saveResult in
                    switch saveResult {
                    case .success:
                        completion(.success(newUser))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
