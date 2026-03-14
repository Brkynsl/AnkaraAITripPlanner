// MARK: - Transportation.swift
// Amaç: Şehirler arası ulaşım seçeneklerini temsil eden veri modeli.
// Açıklama: Uçak, otobüs, tren gibi ulaşım türlerinin bilgilerini tutar.
//           Fiyat, süre, kalkış/varış saatleri ve firma bilgisi içerir.
//           AI motoru bu modeli kullanarak en uygun ulaşım kombinasyonunu seçer.

import Foundation

// MARK: - Ulaşım Türü
enum TransportType: String, Codable, CaseIterable {
    case flight = "flight"     // Uçak
    case bus = "bus"           // Otobüs
    case train = "train"       // Tren (YHT dahil)
    case car = "car"           // Araç (kendi aracınız veya kiralık)
    
    var displayName: String {
        switch self {
        case .flight: return "Uçak"
        case .bus: return "Otobüs"
        case .train: return "Tren / YHT"
        case .car: return "Araç"
        }
    }
    
    var iconName: String {
        switch self {
        case .flight: return "airplane"
        case .bus: return "bus.fill"
        case .train: return "tram.fill"
        case .car: return "car.fill"
        }
    }
}

// MARK: - Ulaşım Modeli
struct Transportation: Codable {
    let type: TransportType           // Ulaşım türü
    let provider: String              // Firma adı (THY, Metro Turizm, TCDD vb.)
    let departureCity: String         // Kalkış şehri
    let arrivalCity: String           // Varış şehri
    let departureTime: String         // Kalkış saati
    let arrivalTime: String           // Varış saati
    let duration: String              // Seyahat süresi (Örn: "1s 15dk")
    let price: Double                 // Fiyat (TL)
    let returnPrice: Double?          // Dönüş bileti fiyatı (opsiyonel)
    let classType: String             // Sınıf (Ekonomi, Business vb.)
    let notes: String?                // Ek notlar
    
    // Toplam ulaşım maliyeti (gidiş + dönüş)
    var totalCost: Double {
        return price + (returnPrice ?? price)
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "type": type.rawValue,
            "provider": provider,
            "departureCity": departureCity,
            "arrivalCity": arrivalCity,
            "departureTime": departureTime,
            "arrivalTime": arrivalTime,
            "duration": duration,
            "price": price,
            "classType": classType
        ]
        if let returnPrice = returnPrice { dict["returnPrice"] = returnPrice }
        if let notes = notes { dict["notes"] = notes }
        return dict
    }
}
