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
    
    static func fromDictionary(_ dict: [String: Any]) -> BudgetBreakdown? {
        return BudgetBreakdown(
            transportation: dict["transportation"] as? Double ?? 0,
            accommodation: dict["accommodation"] as? Double ?? 0,
            food: dict["food"] as? Double ?? 0,
            localTransport: dict["localTransport"] as? Double ?? 0,
            activities: dict["activities"] as? Double ?? 0,
            miscellaneous: dict["miscellaneous"] as? Double ?? 0
        )
    }
}

// MARK: - Günlük Gezi Planı
struct DayPlan: Codable {
    let dayNumber: Int
    let title: String
    var activities: [PlannedActivity]
    var estimatedCost: Double
    var totalDistance: String?          // Günlük toplam mesafe ("~8 km yürüyüş")
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "dayNumber": dayNumber,
            "title": title,
            "activities": activities.map { $0.toDictionary() },
            "estimatedCost": estimatedCost
        ]
        if let totalDistance = totalDistance { dict["totalDistance"] = totalDistance }
        return dict
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> DayPlan? {
        guard let dayNumber = dict["dayNumber"] as? Int,
              let title = dict["title"] as? String,
              let activitiesData = dict["activities"] as? [[String: Any]] else {
            return nil
        }
        
        let activities = activitiesData.compactMap { PlannedActivity.fromDictionary($0) }
        let estimatedCost = dict["estimatedCost"] as? Double ?? 0
        
        return DayPlan(dayNumber: dayNumber, title: title, activities: activities, estimatedCost: estimatedCost, totalDistance: dict["totalDistance"] as? String)
    }
}

// MARK: - Planlanan Aktivite
struct PlannedActivity: Codable {
    let name: String
    let description: String
    let category: ActivityCategory
    let startTime: String
    let endTime: String
    let estimatedCost: Double
    let latitude: Double
    let longitude: Double
    let address: String
    let transportToNext: String?
    let transportCost: Double?
    // Yeni alanlar
    let entryFee: Double?             // Giriş ücreti (0 = ücretsiz)
    let openingHours: String?         // Açılış saatleri ("09:00-17:00")
    let transportInfo: String?        // Nasıl gidilir detayı
    let tips: String?                 // Ziyaretçi ipucu
    
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
        if let transportToNext = transportToNext { dict["transportToNext"] = transportToNext }
        if let transportCost = transportCost { dict["transportCost"] = transportCost }
        if let entryFee = entryFee { dict["entryFee"] = entryFee }
        if let openingHours = openingHours { dict["openingHours"] = openingHours }
        if let transportInfo = transportInfo { dict["transportInfo"] = transportInfo }
        if let tips = tips { dict["tips"] = tips }
        return dict
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> PlannedActivity? {
        guard let name = dict["name"] as? String,
              let description = dict["description"] as? String,
              let categoryRaw = dict["category"] as? String,
              let category = ActivityCategory(rawValue: categoryRaw),
              let startTime = dict["startTime"] as? String,
              let endTime = dict["endTime"] as? String,
              let latitude = dict["latitude"] as? Double,
              let longitude = dict["longitude"] as? Double,
              let address = dict["address"] as? String else {
            return nil
        }
        
        return PlannedActivity(
            name: name,
            description: description,
            category: category,
            startTime: startTime,
            endTime: endTime,
            estimatedCost: dict["estimatedCost"] as? Double ?? 0,
            latitude: latitude,
            longitude: longitude,
            address: address,
            transportToNext: dict["transportToNext"] as? String,
            transportCost: dict["transportCost"] as? Double,
            entryFee: dict["entryFee"] as? Double,
            openingHours: dict["openingHours"] as? String,
            transportInfo: dict["transportInfo"] as? String,
            tips: dict["tips"] as? String
        )
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
    
    static func fromDictionary(_ dict: [String: Any]) -> TripPlan? {
        guard let title = dict["title"] as? String,
              let description = dict["description"] as? String,
              let planTypeRaw = dict["planType"] as? String,
              let planType = PlanType(rawValue: planTypeRaw),
              let transportData = dict["transportation"] as? [String: Any],
              let transportation = Transportation.fromDictionary(transportData),
              let hotelData = dict["hotel"] as? [String: Any],
              let hotel = Hotel.fromDictionary(hotelData),
              let dailyPlansData = dict["dailyPlans"] as? [[String: Any]],
              let breakdownData = dict["budgetBreakdown"] as? [String: Any],
              let budgetBreakdown = BudgetBreakdown.fromDictionary(breakdownData) else {
            return nil
        }
        
        let dailyPlans = dailyPlansData.compactMap { DayPlan.fromDictionary($0) }
        let totalEstimatedCost = dict["totalEstimatedCost"] as? Double ?? 0
        let recommendation = dict["recommendation"] as? String ?? ""
        let fitScore = dict["fitScore"] as? Int ?? 0
        
        return TripPlan(
            title: title,
            description: description,
            planType: planType,
            transportation: transportation,
            hotel: hotel,
            dailyPlans: dailyPlans,
            budgetBreakdown: budgetBreakdown,
            totalEstimatedCost: totalEstimatedCost,
            recommendation: recommendation,
            fitScore: fitScore
        )
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
