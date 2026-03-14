// MARK: - FirestoreService.swift
// Amaç: Firebase Firestore veritabanı işlemlerini merkezi olarak yönetir.
// Açıklama: Kullanıcı profilleri, seyahat planları, tercihler ve onboarding
//           durumları gibi tüm veritabanı işlemlerini bu servis üzerinden yaparız.
//           FirestoreServiceProtocol'ü uygular, test edilebilir yapıyı korur.
//           Her metot completion handler ile sonuç döndürür.
//
// ÖNEMLİ: Firebase SDK eklenmeden bu dosya derlenmez.
// SPM ile FirebaseFirestore paketini eklemeyi unutmayın.

import Foundation
import FirebaseFirestore

final class FirestoreService: FirestoreServiceProtocol {
    
    // MARK: - Singleton
    static let shared = FirestoreService()
    
    // Firestore veritabanı referansı
    private let db = Firestore.firestore()
    
    private init() {}
    
    // ============================================================
    // KULLANICI İŞLEMLERİ
    // ============================================================
    
    // MARK: - Kullanıcı Profili Kaydetme
    // Yeni kullanıcı kaydında veya profil güncellemesinde çağrılır.
    // merge: true — var olan alanları korur, sadece gönderilenleri günceller.
    func saveUser(_ user: AppUser, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(FirestoreKeys.Collections.users)
            .document(user.uid)
            .setData(user.toDictionary(), merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    // MARK: - Kullanıcı Profili Çekme
    // UID ile Firestore'dan kullanıcı profilini okur.
    // Belge yoksa hata döner (ilk giriş durumunda AuthService yeni profil oluşturur).
    func getUser(uid: String, completion: @escaping (Result<AppUser, Error>) -> Void) {
        db.collection(FirestoreKeys.Collections.users)
            .document(uid)
            .getDocument { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = snapshot?.data(),
                      let user = AppUser.fromDictionary(data, uid: uid) else {
                    let notFoundError = NSError(domain: "FirestoreService", code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "Kullanıcı profili bulunamadı."])
                    completion(.failure(notFoundError))
                    return
                }
                
                completion(.success(user))
            }
    }
    
    // MARK: - Kullanıcı Profili Güncelleme (Kısmi)
    // Sadece belirtilen alanları günceller. Tüm profili tekrar yazmaz.
    // Örnek: updateUser(uid: "abc", data: ["displayName": "Yeni İsim"])
    func updateUser(uid: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        var updateData = data
        updateData["updatedAt"] = FieldValue.serverTimestamp()
        
        db.collection(FirestoreKeys.Collections.users)
            .document(uid)
            .updateData(updateData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    // ============================================================
    // ONBOARDING DURUMU
    // ============================================================
    
    // MARK: - Onboarding Durumunu Güncelleme
    // Kullanıcı onboarding'i tamamladığında çağrılır.
    // Ana ekrana yönlendirme kararı bu değere göre verilir.
    func updateOnboardingStatus(
        uid: String,
        completed: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        updateUser(uid: uid, data: [
            FirestoreKeys.UserFields.hasCompletedOnboarding: completed
        ], completion: completion)
    }
    
    // ============================================================
    // SEYAHAT PLANI İŞLEMLERİ
    // ============================================================
    
    // MARK: - Seyahat Planı Kaydetme
    // Yeni oluşturulan trip'i Firestore'a kaydeder.
    // Otomatik ID atanır ve bu ID completion ile döndürülür.
    func saveTrip(_ trip: Trip, completion: @escaping (Result<String, Error>) -> Void) {
        let docRef = db.collection(FirestoreKeys.Collections.trips).document()
        var tripData = trip.toDictionary()
        tripData["id"] = docRef.documentID
        
        docRef.setData(tripData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(docRef.documentID))
            }
        }
    }
    
    // MARK: - Kullanıcının Seyahat Planlarını Çekme
    // Belirli bir kullanıcının tüm trip'lerini tarihe göre sıralı getirir.
    // Tatilim sayfasında listelenmek üzere kullanılır.
    func getTrips(userId: String, completion: @escaping (Result<[Trip], Error>) -> Void) {
        db.collection(FirestoreKeys.Collections.trips)
            .whereField(FirestoreKeys.TripFields.userId, isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                // Her belgeyi Trip modeline decode et
                let trips: [Trip] = documents.compactMap { doc in
                    let data = doc.data()
                    return Trip.fromDictionary(data, id: doc.documentID)
                }
                
                completion(.success(trips))
            }
    }
    
    // MARK: - Seyahat Planını Güncelleme
    func updateTrip(tripId: String, data: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
        var updateData = data
        updateData["updatedAt"] = FieldValue.serverTimestamp()
        
        db.collection(FirestoreKeys.Collections.trips)
            .document(tripId)
            .updateData(updateData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    // MARK: - Seyahat Planı Silme
    func deleteTrip(tripId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(FirestoreKeys.Collections.trips)
            .document(tripId)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    // ============================================================
    // KULLANICI TERCİHLERİ
    // ============================================================
    
    // MARK: - Tercih Kaydetme
    // Kullanıcının seyahat tercihlerini users/{uid}/preferences alt koleksiyonuna yazar.
    func savePreferences(
        uid: String,
        preferences: UserPreferences,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection(FirestoreKeys.Collections.users)
            .document(uid)
            .collection(FirestoreKeys.Collections.preferences)
            .document("userPreferences")
            .setData(preferences.toDictionary(), merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
    
    // MARK: - Tercih Okuma
    func getPreferences(uid: String, completion: @escaping (Result<UserPreferences, Error>) -> Void) {
        db.collection(FirestoreKeys.Collections.users)
            .document(uid)
            .collection(FirestoreKeys.Collections.preferences)
            .document("userPreferences")
            .getDocument { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let data = snapshot?.data() {
                    let preferences = UserPreferences.fromDictionary(data)
                    completion(.success(preferences))
                } else {
                    // Tercih bulunamadı — varsayılan değerler döndür
                    completion(.success(UserPreferences.defaultPreferences))
                }
            }
    }
}

// MARK: - Data Decode Yardımcısı
// JSON verisini belirtilen Codable tipe decode eder.
private extension Data {
    func decoded<T: Decodable>(as type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: self)
    }
}
