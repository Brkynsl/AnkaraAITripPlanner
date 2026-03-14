// MARK: - OnboardingViewModel.swift
// Amaç: Onboarding (tanıtım) ekranlarının veri ve iş mantığını yönetir.
// Açıklama: Onboarding sayfalarının içeriklerini (başlık, açıklama, ikon) sağlar.
//           Kullanıcının onboarding'i tamamladığını Firestore'a kaydeder.
//           ViewController sadece bu ViewModel'den gelen verileri gösterir.

import Foundation

// MARK: - Onboarding Sayfa Modeli
// Her bir onboarding sayfasının içeriğini tutar.
struct OnboardingPage {
    let title: String           // Sayfa başlığı
    let description: String     // Açıklama metni
    let iconName: String        // SF Symbol ikon adı
    let accentColor: String     // Vurgu rengi (hex)
}

final class OnboardingViewModel {
    
    // MARK: - Servisler
    private let firestoreService: FirestoreService
    private let authService: AuthService
    
    // MARK: - Onboarding Sayfaları
    // 4 sayfalık kaydırmalı onboarding içeriği.
    // Her sayfa uygulamanın bir özelliğini tanıtır.
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Bütçene Uygun Plan",
            description: "Toplam bütçeni gir, yapay zeka senin için en uygun tatil planını oluştursun. Ulaşım, konaklama ve aktivitelerin bütçene göre optimize edilir.",
            iconName: "wallet.pass.fill",
            accentColor: "#00C7BF"
        ),
        OnboardingPage(
            title: "Ulaşım + Otel + Gezi",
            description: "Uçak, otobüs veya tren seçeneklerini karşılaştır. Bütçene uygun oteller bul. Müze, park ve restoran önerileri al — hepsi tek ekranda.",
            iconName: "airplane.departure",
            accentColor: "#FF9500"
        ),
        OnboardingPage(
            title: "Alternatif Rotalar",
            description: "Tek plan yerine 2-3 farklı alternatif sunulur: ekonomik, dengeli ve konforlu. Aynı bütçeyle farklı tatil deneyimlerini keşfet.",
            iconName: "arrow.triangle.branch",
            accentColor: "#AF52DE"
        ),
        OnboardingPage(
            title: "Haritada Tüm Tatilini Gör",
            description: "Otelden müzeye, restorana kadar tüm gezi noktalarını harita üzerinde gör. Mesafeleri, ulaşım seçeneklerini ve rotanı tek bakışta anla.",
            iconName: "map.fill",
            accentColor: "#34C759"
        )
    ]
    
    // MARK: - Toplam Sayfa Sayısı
    var totalPages: Int {
        return pages.count
    }
    
    // MARK: - Son Sayfa mı Kontrolü
    func isLastPage(_ index: Int) -> Bool {
        return index == pages.count - 1
    }
    
    // MARK: - Başlatma
    init(firestoreService: FirestoreService = .shared, authService: AuthService = .shared) {
        self.firestoreService = firestoreService
        self.authService = authService
    }
    
    // MARK: - Onboarding Tamamlandı
    // Kullanıcı "Başla" butonuna bastığında çağrılır.
    // Firestore'da onboarding durumunu günceller ve UserDefaults'a yazar.
    // İki farklı yere yazma sebebi:
    //   - Firestore: Cihaz değişikliğinde bile durumu korur
    //   - UserDefaults: Offline erişim ve hızlı kontrol için
    func completeOnboarding(completion: @escaping (Bool) -> Void) {
        // UserDefaults'a kaydet (hızlı erişim için)
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasCompletedOnboarding)
        
        // Firestore'a kaydet (kalıcılık için)
        guard let uid = authService.currentUserId else {
            completion(true) // Auth yoksa bile devam et
            return
        }
        
        firestoreService.updateOnboardingStatus(uid: uid, completed: true) { result in
            switch result {
            case .success:
                completion(true)
            case .failure(let error):
                print("⚠️ Onboarding durumu Firestore'a kaydedilemedi: \(error)")
                completion(true) // Hata olsa bile devam et (UserDefaults'a kayıt yapıldı)
            }
        }
    }
    
    // MARK: - Onboarding Tamamlanmış mı Kontrolü
    // Önce UserDefaults'tan kontrol eder (hızlı).
    // UserDefaults'ta yoksa Firestore'dan kontrol eder.
    static func hasCompletedOnboarding(completion: @escaping (Bool) -> Void) {
        // Önce yerel kontrol
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding) {
            completion(true)
            return
        }
        
        // Firestore kontrolü
        guard let uid = AuthService.shared.currentUserId else {
            completion(false)
            return
        }
        
        FirestoreService.shared.getUser(uid: uid) { result in
            switch result {
            case .success(let user):
                if user.hasCompletedOnboarding {
                    // UserDefaults'ı da güncelle (cache)
                    UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasCompletedOnboarding)
                }
                completion(user.hasCompletedOnboarding)
            case .failure:
                completion(false)
            }
        }
    }
}
