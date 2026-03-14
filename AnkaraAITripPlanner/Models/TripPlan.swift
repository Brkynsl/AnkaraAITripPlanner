// MARK: - TripPlan.swift
// Amaç: AI motorunun ürettiği tek bir seyahat planını temsil eder.
// Açıklama: Her Trip 2-3 alternatif plan içerir. Her plan; ulaşım yöntemi,
//           otel bilgisi, günlük gezi programı, bütçe dağılımı ve genel
//           bir açıklama içerir. Kullanıcı bu planlardan birini seçer.
//           Bu model Aşama 2'de AI motoruyla doldurulacaktır.

import Foundation
import CoreLocation

// MARK: - Bütçe Dağılımı
// Toplam bütçenin kategorilere göre dağılımını tutar.
// AI motoru bu dağılımı optimize ederek alternatif planlar üretir.
struct BudgetBreakdown: Codable {
    var transportation: Double    // Şehirler arası ulaşım (uçak/otobüs/tren)
    var accommodation: Double     // Konaklama (otel)
    var food: Double              // Yeme-içme
    var localTransport: Double    // Şehir içi ulaşım (metro, otobüs, taksi)
    var activities: Double        // Müze giriş, etkinlik, bilet vb.
    var miscellaneous: Double     // Diğer giderler (hediyelik, acil vb.)
    
    // Toplam harcama
    var total: Double {
        return transportation + accommodation + food + localTransport + activities + miscellaneous
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "transportation": transportation,
            "accommodation": accommodation,
            "food": food,
            "localTransport": localTransport,
            "activities": activities,
            "miscellaneous": miscellaneous
        ]
    }
}

// MARK: - Günlük Gezi Planı
// Bir günün detaylı programını tutar.
// Sabah, öğlen, akşam ve opsiyonel gece aktivitelerini içerir.
struct DayPlan: Codable {
    let dayNumber: Int                // Gün numarası (1, 2, 3...)
    let title: String                 // Gün başlığı (Örn: "Tarihi Ankara Turu")
    var activities: [PlannedActivity] // O gün yapılacak aktiviteler
    var estimatedCost: Double         // O günün tahmini maliyeti
    
    func toDictionary() -> [String: Any] {
        return [
            "dayNumber": dayNumber,
            "title": title,
            "activities": activities.map { $0.toDictionary() },
            "estimatedCost": estimatedCost
        ]
    }
}

// MARK: - Planlanan Aktivite
// Bir gün içindeki tek bir aktiviteyi temsil eder.
// Müze ziyareti, restoran, gezi noktası vb. olabilir.
struct PlannedActivity: Codable {
    let name: String                  // Aktivite adı
    let description: String           // Kısa açıklama
    let category: ActivityCategory    // Kategori (müze, restoran, park vb.)
    let startTime: String             // Başlangıç saati (Örn: "09:00")
    let endTime: String               // Bitiş saati (Örn: "11:00")
    let estimatedCost: Double         // Tahmini maliyet
    let latitude: Double              // Konum enlem
    let longitude: Double             // Konum boylam
    let address: String               // Adres
    let transportToNext: String?      // Bir sonraki noktaya ulaşım bilgisi
    let transportCost: Double?        // Ulaşım maliyeti
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "description": description,
            "category": category.rawValue,
            "startTime": startTime,
            "endTime": endTime,
            "estimatedCost": estimatedCost,
            "latitude": latitude,
            "longitude": longitude,
            "address": address
        ]
        if let transportToNext = transportToNext {
            dict["transportToNext"] = transportToNext
        }
        if let transportCost = transportCost {
            dict["transportCost"] = transportCost
        }
        return dict
    }
    
    // CLLocationCoordinate2D — MapKit ile kullanım için
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Aktivite Kategorisi
// Gezi noktalarını sınıflandırmak için kullanılır.
// Haritada farklı pin renkleri, filtreleme ve istatistik için.
enum ActivityCategory: String, Codable, CaseIterable {
    case museum = "museum"           // Müze
    case restaurant = "restaurant"   // Restoran
    case park = "park"               // Park / doğa
    case landmark = "landmark"       // Tarihi yer / simge
    case shopping = "shopping"       // Alışveriş
    case nightlife = "nightlife"     // Gece hayatı
    case transport = "transport"     // Ulaşım noktası
    case hotel = "hotel"             // Otel
    case other = "other"             // Diğer
    
    // Her kategori için Türkçe başlık
    var displayName: String {
        switch self {
        case .museum: return "Müze"
        case .restaurant: return "Restoran"
        case .park: return "Park / Doğa"
        case .landmark: return "Tarihi Yer"
        case .shopping: return "Alışveriş"
        case .nightlife: return "Gece Hayatı"
        case .transport: return "Ulaşım"
        case .hotel: return "Otel"
        case .other: return "Diğer"
        }
    }
    
    // Her kategori için SF Symbol ikon adı
    var iconName: String {
        switch self {
        case .museum: return "building.columns.fill"
        case .restaurant: return "fork.knife"
        case .park: return "leaf.fill"
        case .landmark: return "mappin.and.ellipse"
        case .shopping: return "bag.fill"
        case .nightlife: return "moon.stars.fill"
        case .transport: return "bus.fill"
        case .hotel: return "bed.double.fill"
        case .other: return "star.fill"
        }
    }
}

// MARK: - Seyahat Planı Modeli
struct TripPlan: Codable {
    
    // Plan başlığı (Örn: "Ekonomik & Yoğun Gezi Planı")
    let title: String
    
    // Planın kısa açıklaması — neden bu plan önerildi
    let description: String
    
    // Plan tipi etiketi
    let planType: PlanType
    
    // Ulaşım bilgisi
    var transportation: Transportation
    
    // Otel bilgisi
    var hotel: Hotel
    
    // Günlük programlar
    var dailyPlans: [DayPlan]
    
    // Bütçe dağılımı
    var budgetBreakdown: BudgetBreakdown
    
    // Toplam tahmini maliyet
    var totalEstimatedCost: Double
    
    // AI'ın bu planı neden önerdiğine dair açıklama
    let recommendation: String
    
    // Uygunluk skoru (0-100 arası, AI motoru tarafından hesaplanır)
    var fitScore: Int
    
    func toDictionary() -> [String: Any] {
        return [
            "title": title,
            "description": description,
            "planType": planType.rawValue,
            "transportation": transportation.toDictionary(),
            "hotel": hotel.toDictionary(),
            "dailyPlans": dailyPlans.map { $0.toDictionary() },
            "budgetBreakdown": budgetBreakdown.toDictionary(),
            "totalEstimatedCost": totalEstimatedCost,
            "recommendation": recommendation,
            "fitScore": fitScore
        ]
    }
}

// MARK: - Plan Tipi
// AI motorunun ürettiği farklı plan stratejilerini temsil eder.
enum PlanType: String, Codable {
    case economic = "economic"     // Ekonomik — düşük bütçe, otobüs, ekonomik otel
    case balanced = "balanced"     // Dengeli — orta bütçe, karma ulaşım
    case comfort = "comfort"       // Konforlu — yüksek bütçe, uçak, iyi otel
    
    var displayName: String {
        switch self {
        case .economic: return "Ekonomik Plan"
        case .balanced: return "Dengeli Plan"
        case .comfort: return "Konfor Planı"
        }
    }
    
    var iconName: String {
        switch self {
        case .economic: return "wallet.pass.fill"
        case .balanced: return "scalemass.fill"
        case .comfort: return "crown.fill"
        }
    }
}
