// MARK: - Trip.swift
// Amaç: Kullanıcının oluşturduğu seyahat kaydını temsil eden ana veri modeli.
// Açıklama: Bir seyahat; hedef şehir, gün sayısı, toplam bütçe ve
//           oluşturulan alternatif planları içerir. Firestore'da "trips"
//           koleksiyonunda saklanır. Bu model Tatilim sayfasının temel veri kaynağıdır.

import Foundation

// MARK: - Seyahat Durumu
// Bir seyahatin mevcut durumunu belirtir.
// Planlama aşamasından tamamlanmaya kadar yaşam döngüsünü takip eder.
enum TripStatus: String, Codable {
    case planning = "planning"       // Henüz plan oluşturuluyor
    case planned = "planned"         // Plan tamamlandı, onay bekleniyor
    case active = "active"           // Aktif seyahat — kullanıcı seyahatte
    case completed = "completed"     // Seyahat tamamlandı
    case cancelled = "cancelled"     // İptal edildi
}

// MARK: - Seyahat Modeli
struct Trip: Codable {
    
    // Firestore belge ID'si
    var id: String?
    
    // Bu seyahati oluşturan kullanıcının UID'si
    let userId: String
    
    // Hedef şehir adı (Örn: "Ankara", "İstanbul")
    let city: String
    
    // Kaç gün kalınacağı
    let days: Int
    
    // Kullanıcının belirlediği toplam bütçe (TL)
    let totalBudget: Double
    
    // AI motorunun ürettiği alternatif planlar (genellikle 2-3 adet)
    var plans: [TripPlan]
    
    // Kullanıcının seçtiği planın index'i (plans dizisindeki sıra)
    var selectedPlanIndex: Int
    
    // Seyahat durumu
    var status: TripStatus
    
    // Oluşturulma tarihi
    let createdAt: Date
    
    // Son güncelleme tarihi
    var updatedAt: Date?
    
    // MARK: - Seçili Plan
    // Kullanıcının aktif olarak seçtiği planı döndürür.
    // Tatilim sayfasında gösterilen plan budur.
    var selectedPlan: TripPlan? {
        guard selectedPlanIndex >= 0 && selectedPlanIndex < plans.count else { return nil }
        return plans[selectedPlanIndex]
    }
    
    // MARK: - Firestore Dictionary'ye Çevirme
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "userId": userId,
            "city": city,
            "days": days,
            "totalBudget": totalBudget,
            "selectedPlanIndex": selectedPlanIndex,
            "status": status.rawValue,
            "createdAt": createdAt,
            "plans": plans.map { $0.toDictionary() }
        ]
        if let updatedAt = updatedAt {
            dict["updatedAt"] = updatedAt
        }
        return dict
    }
}
