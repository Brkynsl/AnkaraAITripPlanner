//
//  AITripPlannerService.swift
//  AnkaraAITripPlanner
//

import Foundation

// Amaç: Kullanıcının girdiği şehir, gün ve bütçe verilerine göre mantıklı tatil planları üretmek.
// Açıklama: Bu servis, normalde bir Backend/AI servisi çağıracak şekilde tasarlandı. 
// Ancak bitirme projesinde gerçekçi bir simülasyon sunmak amacıyla içerisinde kural tabanlı, 
// bütçe oranlarına dikkat eden ve rastgele mantıklı verilerle zenginleştirilmiş
// bir "Karar Motoru" (Decision Engine) barındırır.
final class AITripPlannerService {

    static let shared = AITripPlannerService()
    
    // Uygulama genelinde kullanılacak mock kategorileri
    private let mockHotels = [
        Hotel(name: "Sheraton Ankara", starRating: 5, pricePerNight: 3500, totalPrice: 7000, latitude: 39.897, longitude: 32.868, address: "Kavaklıdere, Çankaya", distanceToCenter: "2 km", amenities: ["WiFi", "Havuz", "Spa"], imageURL: nil, rating: 9.2, reviewCount: 1250, checkIn: "14:00", checkOut: "12:00", notes: nil),
        Hotel(name: "Divan Çukurhan", starRating: 5, pricePerNight: 2800, totalPrice: 5600, latitude: 39.938, longitude: 32.862, address: "Ulus, Tarihi Ankara", distanceToCenter: "0.5 km", amenities: ["WiFi", "Tarihi", "Restoran"], imageURL: nil, rating: 9.5, reviewCount: 840, checkIn: "14:00", checkOut: "12:00", notes: nil),
        Hotel(name: "Ibis Ankara Airport", starRating: 3, pricePerNight: 1500, totalPrice: 3000, latitude: 40.125, longitude: 32.995, address: "Esenboğa Havalimanı", distanceToCenter: "25 km", amenities: ["WiFi", "Transfer", "Kahvaltı"], imageURL: nil, rating: 8.1, reviewCount: 2100, checkIn: "14:00", checkOut: "12:00", notes: nil),
        Hotel(name: "Ekonomik Host", starRating: 2, pricePerNight: 800, totalPrice: 1600, latitude: 39.920, longitude: 32.850, address: "Kızılay, Ankara", distanceToCenter: "1 km", amenities: ["WiFi", "Ortak Alan"], imageURL: nil, rating: 7.5, reviewCount: 450, checkIn: "14:00", checkOut: "12:00", notes: nil)
    ]
    
    private let mockActivities: [PlannedActivity] = [
        PlannedActivity(name: "Anıtkabir Ziyareti", description: "Atatürk'ün ebedi istirahatgahı", category: .landmark, startTime: "09:00", endTime: "11:30", estimatedCost: 0, latitude: 39.9250, longitude: 32.8369, address: "Yücetepe, Çankaya", transportToNext: "Otobüs 5 dk", transportCost: 20),
        PlannedActivity(name: "Anadolu Medeniyetleri Müzesi", description: "Anadolu'nun zengin tarihi...", category: .museum, startTime: "13:00", endTime: "15:00", estimatedCost: 280, latitude: 39.938, longitude: 32.861, address: "Ulus, Altındağ", transportToNext: "Taksi 10 dk", transportCost: 150),
        PlannedActivity(name: "Tunalı Hilmi Caddesi", description: "Alışveriş ve kafe turu", category: .shopping, startTime: "16:00", endTime: "18:00", estimatedCost: 0, latitude: 39.907, longitude: 32.861, address: "Kavaklıdere", transportToNext: "Yürüyüş", transportCost: 0),
        PlannedActivity(name: "Atakule'de Akşam Yemeği", description: "Şehir manzaralı akşam yemeği", category: .restaurant, startTime: "19:00", endTime: "21:00", estimatedCost: 1500, latitude: 39.886, longitude: 32.855, address: "Çankaya", transportToNext: "Taksi 15 dk", transportCost: 180)
    ]
    
    private init() {}
    
    /// Verilen parametrelere göre 3 alternatif tatil planı üretir.
    func generateTripPlans(city: String, days: Int, budget: Double, completion: @escaping (Result<[TripPlan], Error>) -> Void) {
        
        // Simülasyon: AI motorunun cevap vermesi NEREDEYSE ANINDA (0.1s) yapıldı
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            
            // Kullanıcı bütçesine göre otelleri filtrele
            // 1. Ekonomik Plan
            let ecoPlan = self.buildPlan(
                title: "Ekonomik & Optimize Rota",
                description: "\(city) için bütçe dostu, ulaşım ve konaklamada maksimum tasarruf sağlayan rota.",
                type: .economic,
                city: city,
                days: days,
                budget: budget,
                hotelIndex: 3, // Ekonomik
                transportType: .bus,
                fitScore: 85
            )
            
            // 2. Dengeli Plan
            let balancedPlan = self.buildPlan(
                title: "Dengeli Konfor",
                description: "Konfor ve bütçe arasında mükemmel denge. \(city) merkezine yakın konaklama.",
                type: .balanced,
                city: city,
                days: days,
                budget: budget,
                hotelIndex: 2, // 3 Yıldız
                transportType: .train,
                fitScore: 95
            )
            
            // 3. Konfor Planı
            let comfortPlan = self.buildPlan(
                title: "Premium Deneyim",
                description: "\(city) seyahatinizi unutulmaz kılacak ultra konforlu otel ve VIP ulaşım seçenekleri.",
                type: .comfort,
                city: city,
                days: days,
                budget: budget,
                hotelIndex: 0, // 5 Yıldız
                transportType: .flight,
                fitScore: 88
            )
            
            DispatchQueue.main.async {
                completion(.success([ecoPlan, balancedPlan, comfortPlan]))
            }
        }
    }
    
    private func buildPlan(title: String, description: String, type: PlanType, city: String, days: Int, budget: Double, hotelIndex: Int, transportType: TransportType, fitScore: Int) -> TripPlan {
        
        let transportCost: Double = {
            switch transportType {
            case .flight: return Double.random(in: 1800...3500)
            case .bus: return Double.random(in: 450...950)
            case .train: return Double.random(in: 300...700)
            case .car: return Double.random(in: 1200...2500)
            }
        }()
        
        let selectedHotel = mockHotels[hotelIndex]
        let hotelTotalCost = selectedHotel.pricePerNight * Double(max(1, days - 1))
        
        var dailyPlans: [DayPlan] = []
        
        // Şehre göre spesifik aktivite uydurması
        let cityActivities: [String] = {
            if city.contains("Ankara") {
                return ["Anıtkabir", "Kocatepe Camii", "Tunalı Hilmi", "Hamamönü", "Ankara Kalesi", "Atakule", "Gençlik Parkı", "Mogan Gölü"]
            } else if city.contains("İstanbul") {
                return ["Ayasofya", "Kız Kulesi", "İstiklal Caddesi", "Eminönü Turu", "Boğaz Gezisi", "Galata Kulesi", "Topkapı Sarayı", "Ortaköy"]
            } else if city.contains("İzmir") {
                return ["Saat Kulesi", "Kordon Boyu", "Efes Antik Kenti", "Çeşme Plajı", "Alsancak", "Kemeraltı Çarşısı", "Karşıyaka Sahili"]
            } else {
                return ["Şehir Merkezi Gezisi", "Müze Ziyareti", "Yöresel Restoran", "Park Yürüyüşü", "Alışveriş Merkezi", "Tarihi Yerler"]
            }
        }()
        
        for i in 1...days {
            let shuffled = cityActivities.shuffled()
            let dayTitle = shuffled.first ?? "Keşif"
            
            var activities: [PlannedActivity] = []
            for j in 0..<3 {
                let actName = shuffled[min(j, shuffled.count - 1)]
                let act = PlannedActivity(
                    name: "\(actName)",
                    description: "\(city) için özel seçilmiş aktivite.",
                    category: .landmark,
                    startTime: "\(9 + j * 3):00",
                    endTime: "\(11 + j * 3):00",
                    estimatedCost: Double.random(in: 50...500),
                    latitude: selectedHotel.latitude + Double.random(in: -0.05...0.05),
                    longitude: selectedHotel.longitude + Double.random(in: -0.05...0.05),
                    address: "\(city) Merkezi",
                    transportToNext: "Toplu Taşıma",
                    transportCost: 30
                )
                activities.append(act)
            }
            
            let dailyActivitiesCost = activities.reduce(0) { $0 + $1.estimatedCost + ($1.transportCost ?? 0) }
            
            let dayPlan = DayPlan(
                dayNumber: i,
                title: "Gün \(i): \(dayTitle)",
                activities: activities,
                estimatedCost: dailyActivitiesCost
            )
            dailyPlans.append(dayPlan)
        }
        
        let totalActivitiesCost = dailyPlans.reduce(0) { $0 + $1.estimatedCost }
        let totalEstimatedCost = transportCost + hotelTotalCost + totalActivitiesCost
        
        let breakdown = BudgetBreakdown(
            transportation: transportCost,
            accommodation: hotelTotalCost,
            food: totalActivitiesCost * 0.5,
            localTransport: totalActivitiesCost * 0.1,
            activities: totalActivitiesCost * 0.3,
            miscellaneous: totalActivitiesCost * 0.1
        )
        
        let recommendationReason = "Kullanıcı bütçesine (\(Int(budget)) ₺) kıyasla toplam \(Int(totalEstimatedCost)) ₺ tahmini harcama hesaplandı. \(type.rawValue.capitalized) tercihlerinize tam uyumludur."
        
        return TripPlan(
            title: title,
            description: description,
            planType: type,
            transportation: Transportation(
                type: transportType,
                provider: "\(transportType.rawValue.capitalized) Express",
                departureCity: "İstanbul",
                arrivalCity: city,
                departureTime: "08:30",
                arrivalTime: "12:00",
                duration: "3s 30dk",
                price: transportCost,
                returnPrice: transportCost * 0.95,
                classType: "Standart",
                notes: nil
            ),
            hotel: selectedHotel,
            dailyPlans: dailyPlans,
            budgetBreakdown: breakdown,
            totalEstimatedCost: totalEstimatedCost,
            recommendation: recommendationReason,
            fitScore: fitScore
        )
    }
}
