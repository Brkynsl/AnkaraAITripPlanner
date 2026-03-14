// MARK: - Restaurant.swift
// Amaç: Restoran ve yeme-içme mekanlarını temsil eden veri modeli.
// Açıklama: Şehirdeki restoran önerilerini tutar. Fiyat aralığı, mutfak türü,
//           konum bilgisi ve kullanıcı puanı içerir. AI motoru bütçeye ve
//           konuma göre en uygun restoranları seçer.

import Foundation
import CoreLocation

// MARK: - Fiyat Aralığı
enum PriceRange: String, Codable, CaseIterable {
    case budget = "budget"         // Uygun fiyatlı (₺)
    case moderate = "moderate"     // Orta segment (₺₺)
    case expensive = "expensive"   // Pahalı (₺₺₺)
    case luxury = "luxury"         // Lüks (₺₺₺₺)
    
    var displayName: String {
        switch self {
        case .budget: return "Uygun Fiyatlı"
        case .moderate: return "Orta Segment"
        case .expensive: return "Pahalı"
        case .luxury: return "Lüks"
        }
    }
    
    var symbol: String {
        switch self {
        case .budget: return "₺"
        case .moderate: return "₺₺"
        case .expensive: return "₺₺₺"
        case .luxury: return "₺₺₺₺"
        }
    }
}

// MARK: - Restoran Modeli
struct Restaurant: Codable {
    let name: String                  // Restoran adı
    let cuisineType: String           // Mutfak türü (Türk, İtalyan, Fast Food vb.)
    let priceRange: PriceRange        // Fiyat aralığı
    let averageCostPerPerson: Double  // Kişi başı ortalama maliyet
    let latitude: Double
    let longitude: Double
    let address: String
    let rating: Double                // Kullanıcı puanı (0-5)
    let reviewCount: Int
    let imageURL: String?
    let isOpenNow: Bool?              // Şu an açık mı
    let openingHours: String?         // Çalışma saatleri
    let specialties: [String]         // Öne çıkan yemekler
    let notes: String?
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "cuisineType": cuisineType,
            "priceRange": priceRange.rawValue,
            "averageCostPerPerson": averageCostPerPerson,
            "latitude": latitude,
            "longitude": longitude,
            "address": address,
            "rating": rating,
            "reviewCount": reviewCount,
            "specialties": specialties
        ]
        if let imageURL = imageURL { dict["imageURL"] = imageURL }
        if let isOpenNow = isOpenNow { dict["isOpenNow"] = isOpenNow }
        if let openingHours = openingHours { dict["openingHours"] = openingHours }
        if let notes = notes { dict["notes"] = notes }
        return dict
    }
}
