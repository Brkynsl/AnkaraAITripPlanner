// MARK: - Attraction.swift
// Amaç: Gezi noktaları, müzeler ve turistik mekanları temsil eden veri modeli.
// Açıklama: Bir şehirdeki ziyaret edilebilecek tüm noktaları kapsar.
//           Müze, park, tarihi yer, alışveriş merkezi vb. gibi kategorilere
//           ayrılır. Giriş ücreti, çalışma saatleri ve ziyaret süresi bilgisi
//           AI motorunun rota optimizasyonunda kritik rol oynar.

import Foundation
import CoreLocation

// MARK: - Gezi Noktası Modeli
struct Attraction: Codable {
    let name: String                      // Mekan adı
    let category: ActivityCategory        // Kategori (müze, park, tarihi yer vb.)
    let description: String               // Detaylı açıklama
    let latitude: Double
    let longitude: Double
    let address: String
    let entranceFee: Double               // Giriş ücreti (0 = ücretsiz)
    let estimatedVisitDuration: String    // Tahmini ziyaret süresi (Örn: "2 saat")
    let openingHours: String              // Çalışma saatleri
    let closedDays: [String]?             // Kapalı olduğu günler
    let rating: Double                    // Kullanıcı puanı (0-5)
    let reviewCount: Int
    let imageURL: String?
    let website: String?                  // Resmi web sitesi
    let phoneNumber: String?              // İletişim telefonu
    let tips: [String]?                   // Ziyaretçi ipuçları
    let isPopular: Bool                   // Popüler mekan mı (önceliklendirme için)
    
    // MapKit koordinatı
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // Ücretsiz mi kontrolü
    var isFree: Bool {
        return entranceFee == 0
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "category": category.rawValue,
            "description": description,
            "latitude": latitude,
            "longitude": longitude,
            "address": address,
            "entranceFee": entranceFee,
            "estimatedVisitDuration": estimatedVisitDuration,
            "openingHours": openingHours,
            "rating": rating,
            "reviewCount": reviewCount,
            "isPopular": isPopular
        ]
        if let closedDays = closedDays { dict["closedDays"] = closedDays }
        if let imageURL = imageURL { dict["imageURL"] = imageURL }
        if let website = website { dict["website"] = website }
        if let phoneNumber = phoneNumber { dict["phoneNumber"] = phoneNumber }
        if let tips = tips { dict["tips"] = tips }
        return dict
    }
}
