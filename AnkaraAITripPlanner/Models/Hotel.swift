// MARK: - Hotel.swift
// Amaç: Konaklama seçeneklerini temsil eden veri modeli.
// Açıklama: Otel adı, konumu, fiyatı, yıldız sayısı, imkanları gibi bilgileri tutar.
//           AI motoru bütçeye uygun otelleri sıralayıp en iyi eşleşmeyi seçer.
//           Otelin konumu rota optimizasyonu için kritik önem taşır.

import Foundation
import CoreLocation

// MARK: - Otel Yıldız Kategorisi
enum HotelStarRating: Int, Codable, CaseIterable {
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    
    var displayName: String {
        return "\(rawValue) Yıldız"
    }
}

// MARK: - Otel Modeli
struct Hotel: Codable {
    let name: String                  // Otel adı
    let starRating: Int               // Yıldız sayısı (2-5)
    let pricePerNight: Double         // Gecelik fiyat (TL)
    let totalPrice: Double            // Toplam konaklama fiyatı
    let latitude: Double              // Enlem
    let longitude: Double             // Boylam
    let address: String               // Adres
    let distanceToCenter: String      // Merkeze uzaklık
    let amenities: [String]           // Otel imkanları (Wi-Fi, kahvaltı, havuz vb.)
    let imageURL: String?             // Otel görseli URL'i
    let rating: Double                // Kullanıcı puanı (0-10)
    let reviewCount: Int              // Değerlendirme sayısı
    let checkIn: String               // Giriş saati
    let checkOut: String              // Çıkış saati
    let notes: String?                // Ek notlar
    
    // MapKit ile kullanmak için CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "starRating": starRating,
            "pricePerNight": pricePerNight,
            "totalPrice": totalPrice,
            "latitude": latitude,
            "longitude": longitude,
            "address": address,
            "distanceToCenter": distanceToCenter,
            "amenities": amenities,
            "rating": rating,
            "reviewCount": reviewCount,
            "checkIn": checkIn,
            "checkOut": checkOut
        ]
        if let imageURL = imageURL { dict["imageURL"] = imageURL }
        if let notes = notes { dict["notes"] = notes }
        return dict
    }
}
