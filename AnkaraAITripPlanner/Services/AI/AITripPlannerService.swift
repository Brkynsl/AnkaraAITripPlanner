//
//  AITripPlannerService.swift
//  AnkaraAITripPlanner
//
//  Amaç: Kullanıcının girdiği şehir, gün ve bütçe verilerine göre mantıklı tatil planları üretmek.
//  Gerçek Ankara mekanları, doğru GPS koordinatları ve rota optimizasyonu ile çalışır.

import Foundation
import CoreLocation

final class AITripPlannerService {

    static let shared = AITripPlannerService()
    private init() {}
    
    // MARK: - Ana Fonksiyon
    func generateTripPlans(city: String, days: Int, budget: Double, completion: @escaping (Result<[TripPlan], Error>) -> Void) {
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            let cityData = self.getCityData(for: city)
            
            // 1. Ekonomik Plan
            let ecoPlan = self.buildOptimizedPlan(
                title: "Ekonomik & Optimize Rota",
                description: "\(city) için bütçe dostu, ulaşım ve konaklamada maksimum tasarruf sağlayan rota.",
                type: .economic,
                city: city,
                days: days,
                budget: budget,
                cityData: cityData,
                hotelTier: .budget,
                transportType: .bus,
                fitScore: 85
            )
            
            // 2. Dengeli Plan
            let balancedPlan = self.buildOptimizedPlan(
                title: "Dengeli Konfor",
                description: "Konfor ve bütçe arasında mükemmel denge. \(city) merkezine yakın konaklama.",
                type: .balanced,
                city: city,
                days: days,
                budget: budget,
                cityData: cityData,
                hotelTier: .mid,
                transportType: .train,
                fitScore: 95
            )
            
            // 3. Konfor Planı
            let comfortPlan = self.buildOptimizedPlan(
                title: "Premium Deneyim",
                description: "\(city) seyahatinizi unutulmaz kılacak ultra konforlu otel ve VIP ulaşım.",
                type: .comfort,
                city: city,
                days: days,
                budget: budget,
                cityData: cityData,
                hotelTier: .luxury,
                transportType: .flight,
                fitScore: 88
            )
            
            DispatchQueue.main.async {
                completion(.success([ecoPlan, balancedPlan, comfortPlan]))
            }
        }
    }
    
    // MARK: - Otel Katmanı
    private enum HotelTier { case budget, mid, luxury }
    
    // MARK: - Plan Oluşturma (Rota Optimizasyonlu)
    private func buildOptimizedPlan(
        title: String, description: String, type: PlanType,
        city: String, days: Int, budget: Double,
        cityData: CityData, hotelTier: HotelTier,
        transportType: TransportType, fitScore: Int
    ) -> TripPlan {
        
        // Oteli seç
        let hotel: Hotel = {
            switch hotelTier {
            case .budget: return cityData.hotels.last ?? cityData.hotels[0]
            case .mid: return cityData.hotels.count > 1 ? cityData.hotels[1] : cityData.hotels[0]
            case .luxury: return cityData.hotels[0]
            }
        }()
        
        // Ulaşım maliyeti
        let transportCost: Double = {
            switch transportType {
            case .flight: return Double.random(in: 1800...3500)
            case .bus: return Double.random(in: 450...950)
            case .train: return Double.random(in: 300...700)
            case .car: return Double.random(in: 1200...2500)
            }
        }()
        
        let hotelTotalCost = hotel.pricePerNight * Double(max(1, days - 1))
        
        // Aktiviteleri rota optimize ederek günlere dağıt
        var allActivities = cityData.activities.shuffled()
        var dailyPlans: [DayPlan] = []
        
        let hotelLocation = CLLocation(latitude: hotel.latitude, longitude: hotel.longitude)
        
        for i in 1...days {
            // Her gün için 3-4 aktivite seç
            let activitiesPerDay = min(i == 1 ? 3 : 4, allActivities.count)
            guard activitiesPerDay > 0 else { break }
            
            // Nearest-neighbor ile rota optimize et
            var dayActivities: [PlannedActivity] = []
            var currentLocation = hotelLocation
            
            for j in 0..<activitiesPerDay {
                // En yakın aktiviteyi bul
                let nearest = allActivities.enumerated().min(by: { a, b in
                    let locA = CLLocation(latitude: a.element.latitude, longitude: a.element.longitude)
                    let locB = CLLocation(latitude: b.element.latitude, longitude: b.element.longitude)
                    return currentLocation.distance(from: locA) < currentLocation.distance(from: locB)
                })
                
                guard let nearestIdx = nearest?.offset else { break }
                var activity = allActivities.remove(at: nearestIdx)
                
                // Saatleri düzenle
                let startHour = 9 + j * 3
                activity = PlannedActivity(
                    name: activity.name,
                    description: activity.description,
                    category: activity.category,
                    startTime: String(format: "%02d:00", startHour),
                    endTime: String(format: "%02d:00", startHour + 2),
                    estimatedCost: activity.estimatedCost,
                    latitude: activity.latitude,
                    longitude: activity.longitude,
                    address: activity.address,
                    transportToNext: activity.transportToNext,
                    transportCost: activity.transportCost,
                    entryFee: activity.entryFee,
                    openingHours: activity.openingHours,
                    transportInfo: activity.transportInfo,
                    tips: activity.tips
                )
                
                dayActivities.append(activity)
                currentLocation = CLLocation(latitude: activity.latitude, longitude: activity.longitude)
            }
            
            let dailyCost = dayActivities.reduce(0) { $0 + $1.estimatedCost + ($1.transportCost ?? 0) + ($1.entryFee ?? 0) }
            
            // Toplam mesafeyi hesapla
            var totalDist: Double = 0
            var prevLoc = hotelLocation
            for act in dayActivities {
                let loc = CLLocation(latitude: act.latitude, longitude: act.longitude)
                totalDist += prevLoc.distance(from: loc)
                prevLoc = loc
            }
            let distKm = totalDist / 1000.0
            
            let dayTitles = ["Tarihi Keşif", "Kültür & Sanat", "Doğa & Park", "Alışveriş & Lezzet", "Panoramik Gezi"]
            let dayTitle = dayTitles[min(i - 1, dayTitles.count - 1)]
            
            let dayPlan = DayPlan(
                dayNumber: i,
                title: "Gün \(i): \(dayTitle)",
                activities: dayActivities,
                estimatedCost: dailyCost,
                totalDistance: String(format: "~%.1f km", distKm)
            )
            dailyPlans.append(dayPlan)
        }
        
        let totalActivitiesCost = dailyPlans.reduce(0) { $0 + $1.estimatedCost }
        let totalEstimatedCost = transportCost + hotelTotalCost + totalActivitiesCost
        
        let breakdown = BudgetBreakdown(
            transportation: transportCost,
            accommodation: hotelTotalCost,
            food: totalActivitiesCost * 0.35,
            localTransport: totalActivitiesCost * 0.1,
            activities: totalActivitiesCost * 0.45,
            miscellaneous: totalActivitiesCost * 0.1
        )
        
        let recommendation = "Bütçeniz (\(Int(budget)) ₺) için toplam \(Int(totalEstimatedCost)) ₺ tahmini harcama. \(type.displayName) tercihlerinize uygun optimize edildi."
        
        return TripPlan(
            title: title,
            description: description,
            planType: type,
            transportation: Transportation(
                type: transportType,
                provider: cityData.transportProviders[transportType] ?? "Standart",
                departureCity: "İstanbul",
                arrivalCity: city,
                departureTime: "08:30",
                arrivalTime: transportType == .flight ? "09:45" : "12:00",
                duration: transportType == .flight ? "1s 15dk" : "4s 30dk",
                price: transportCost,
                returnPrice: transportCost * 0.95,
                classType: type == .comfort ? "Business" : "Standart",
                notes: nil
            ),
            hotel: hotel,
            dailyPlans: dailyPlans,
            budgetBreakdown: breakdown,
            totalEstimatedCost: totalEstimatedCost,
            recommendation: recommendation,
            fitScore: fitScore
        )
    }
    
    // ============================================================
    // GERÇEK ŞEHİR VERİLERİ
    // ============================================================
    
    private struct CityData {
        let hotels: [Hotel]
        let activities: [PlannedActivity]
        let transportProviders: [TransportType: String]
    }
    
    private func getCityData(for city: String) -> CityData {
        if city.contains("Ankara") { return ankaraData() }
        if city.contains("İstanbul") { return istanbulData() }
        if city.contains("İzmir") { return izmirData() }
        if city.contains("Antalya") { return antalyaData() }
        if city.contains("Kapadokya") || city.contains("Nevşehir") { return kapadokyaData() }
        if city.contains("Bodrum") || city.contains("Muğla") { return bodrumData() }
        return ankaraData() // Varsayılan
    }
    
    // ============================================================
    // ANKARA — GERÇEK VERİLER
    // ============================================================
    private func ankaraData() -> CityData {
        let hotels = [
            Hotel(name: "JW Marriott Ankara", starRating: 5, pricePerNight: 4200, totalPrice: 8400,
                  latitude: 39.9075, longitude: 32.8630, address: "Kavaklıdere Mah., Çankaya",
                  distanceToCenter: "3 km", amenities: ["WiFi", "Havuz", "Spa", "Fitness", "Restoran"],
                  imageURL: nil, rating: 9.3, reviewCount: 1850, checkIn: "15:00", checkOut: "12:00", notes: nil),
            Hotel(name: "Divan Çukurhan", starRating: 5, pricePerNight: 3200, totalPrice: 6400,
                  latitude: 39.9395, longitude: 32.8630, address: "Necatibey Cad., Ulus, Altındağ",
                  distanceToCenter: "0.3 km", amenities: ["WiFi", "Tarihi Bina", "Restoran", "Bar"],
                  imageURL: nil, rating: 9.5, reviewCount: 920, checkIn: "14:00", checkOut: "12:00", notes: "Tarihi han binasında butik otel"),
            Hotel(name: "Ibis Ankara Kızılay", starRating: 3, pricePerNight: 1200, totalPrice: 2400,
                  latitude: 39.9208, longitude: 32.8543, address: "Kızılay, Çankaya",
                  distanceToCenter: "1 km", amenities: ["WiFi", "Kahvaltı", "Klima"],
                  imageURL: nil, rating: 8.1, reviewCount: 2300, checkIn: "14:00", checkOut: "12:00", notes: nil),
            Hotel(name: "Otel Mithat", starRating: 2, pricePerNight: 650, totalPrice: 1300,
                  latitude: 39.9178, longitude: 32.8610, address: "Kızılay, Çankaya",
                  distanceToCenter: "0.8 km", amenities: ["WiFi", "Kahvaltı"],
                  imageURL: nil, rating: 7.2, reviewCount: 480, checkIn: "14:00", checkOut: "11:00", notes: nil)
        ]
        
        let activities = [
            // Anıtkabir
            PlannedActivity(name: "Anıtkabir", description: "Mustafa Kemal Atatürk'ün anıt mezarı. Türkiye Cumhuriyeti'nin kurucusunun ebedi istirahatgahı ve müze kompleksi.",
                category: .landmark, startTime: "09:00", endTime: "11:30", estimatedCost: 0,
                latitude: 39.9254, longitude: 32.8369, address: "Anıt Cad., Tandoğan, Çankaya",
                transportToNext: "Metro ile Tandoğan → Ulus (5 dk)", transportCost: 17,
                entryFee: 0, openingHours: "09:00-17:00 (Kış), 09:00-16:30 (Müze)", transportInfo: "M1 Metro - Tandoğan durağı, yürüyerek 5 dk", tips: "Fotoğraf çekmek serbesttir. Resmi kıyafet önerilir."),
            
            // Ankara Kalesi
            PlannedActivity(name: "Ankara Kalesi", description: "Roma döneminden kalma tarihi kale. Şehrin panoramik manzarasını sunar. İç kale ve dış kale olmak üzere iki bölümden oluşur.",
                category: .landmark, startTime: "10:00", endTime: "12:00", estimatedCost: 0,
                latitude: 39.9408, longitude: 32.8642, address: "Kale Mah., Altındağ",
                transportToNext: "Yürüyerek Hamamönü'ne (8 dk)", transportCost: 0,
                entryFee: 0, openingHours: "24 saat açık (dış alan)", transportInfo: "Ulus'tan yürüyerek 15 dk, yokuş yukarı", tips: "Gün batımında muhteşem fotoğraflar çekilebilir."),
            
            // Anadolu Medeniyetleri Müzesi
            PlannedActivity(name: "Anadolu Medeniyetleri Müzesi", description: "Dünya'nın en zengin arkeoloji müzelerinden biri. Paleolitik dönemden Osmanlı'ya kadar Anadolu tarihi.",
                category: .museum, startTime: "13:00", endTime: "15:00", estimatedCost: 0,
                latitude: 39.9380, longitude: 32.8590, address: "Gözcü Sok. No:2, Ulus, Altındağ",
                transportToNext: "Yürüyerek Hamamönü'ne (10 dk)", transportCost: 0,
                entryFee: 120, openingHours: "08:30-17:30 (Kapalı: Pazartesi)", transportInfo: "Ulus'tan yürüyerek 10 dk", tips: "Müzekart geçerlidir. En az 2 saat ayırın."),
            
            // Hamamönü
            PlannedActivity(name: "Hamamönü Tarihi Bölge", description: "Restore edilmiş Osmanlı evleri, kafeler, el sanatları dükkanları. Ankara'nın en otantik bölgesi.",
                category: .shopping, startTime: "15:00", endTime: "17:00", estimatedCost: 200,
                latitude: 39.9366, longitude: 32.8674, address: "Hamamönü Sok., Altındağ",
                transportToNext: "Taksi ile Tunalı Hilmi'ye (10 dk)", transportCost: 100,
                entryFee: 0, openingHours: "Dükkanlar: 10:00-20:00", transportInfo: "Ulus'tan yürüyerek 12 dk", tips: "Türk kahvesi ve lokal yemekleri denemeyi unutmayın."),
            
            // Kocatepe Camii
            PlannedActivity(name: "Kocatepe Camii", description: "Ankara'nın en büyük camii. Modern Osmanlı mimarisi ile inşa edilmiş, 24.000 kişi kapasiteli.",
                category: .landmark, startTime: "11:00", endTime: "12:00", estimatedCost: 0,
                latitude: 39.9190, longitude: 32.8583, address: "Kocatepe Mah., Çankaya",
                transportToNext: "Yürüyerek Kızılay'a (5 dk)", transportCost: 0,
                entryFee: 0, openingHours: "Namaz saatlerinde açık (her zaman ziyaret edilebilir)", transportInfo: "Kızılay'dan yürüyerek 5 dk", tips: "İç mekanı görmek için namaz vakti dışında gidin."),
            
            // Tunalı Hilmi Caddesi
            PlannedActivity(name: "Tunalı Hilmi Caddesi", description: "Ankara'nın en popüler alışveriş ve eğlence caddesi. Kafeler, restoranlar ve butik mağazalar.",
                category: .shopping, startTime: "16:00", endTime: "18:00", estimatedCost: 300,
                latitude: 39.9072, longitude: 32.8612, address: "Tunalı Hilmi Cad., Kavaklıdere, Çankaya",
                transportToNext: "Yürüyerek Kuğulu Park'a (3 dk)", transportCost: 0,
                entryFee: 0, openingHours: "Mağazalar: 10:00-22:00", transportInfo: "Metro Kızılay'dan yürüyerek 15 dk", tips: "Akşam yemeği için cadde üzerindeki restoranları deneyin."),
            
            // Kuğulu Park
            PlannedActivity(name: "Kuğulu Park", description: "Ankara'nın simgesi olan kuğuların yaşadığı şehir parkı. Kavaklıdere'nin kalbinde huzurlu bir mola noktası.",
                category: .park, startTime: "14:00", endTime: "15:30", estimatedCost: 0,
                latitude: 39.9046, longitude: 32.8606, address: "Kuğulu Park, Kavaklıdere, Çankaya",
                transportToNext: "Yürüyerek Atakule'ye (20 dk)", transportCost: 0,
                entryFee: 0, openingHours: "24 saat açık", transportInfo: "Tunalı Hilmi üzerinde, yürüyerek erişilebilir", tips: "Kuğuları beslemek yasaktır. Piknik yapılabilir."),
            
            // Atakule
            PlannedActivity(name: "Atakule", description: "125 metre yüksekliğinde kule. Döner restoran ve seyir terası ile Ankara manzarası.",
                category: .landmark, startTime: "19:00", endTime: "21:00", estimatedCost: 1200,
                latitude: 39.8866, longitude: 32.8600, address: "Çankaya Cad., Çankaya",
                transportToNext: "Taksi ile otele (15 dk)", transportCost: 120,
                entryFee: 110, openingHours: "10:00-22:00", transportInfo: "Tunalı Hilmi'den dolmuş veya taksi", tips: "Gün batımında seyir terası muhteşemdir."),
            
            // Gençlik Parkı
            PlannedActivity(name: "Gençlik Parkı", description: "Ankara'nın en büyük şehir parkı. Göl, lunapark, çay bahçeleri ve yürüyüş yolları.",
                category: .park, startTime: "10:00", endTime: "12:00", estimatedCost: 50,
                latitude: 39.9360, longitude: 32.8490, address: "Opera, Ulus, Altındağ",
                transportToNext: "Yürüyerek Ulus meydanına (5 dk)", transportCost: 0,
                entryFee: 0, openingHours: "06:00-23:00", transportInfo: "M1 Metro - Ulus durağı", tips: "Göl kenarında çay içmeyi unutmayın."),
            
            // Etnografya Müzesi
            PlannedActivity(name: "Etnografya Müzesi", description: "Türk-İslam sanatları ve Anadolu folkloru. Selçuklu ve Osmanlı dönemi eserleri.",
                category: .museum, startTime: "13:00", endTime: "14:30", estimatedCost: 0,
                latitude: 39.9302, longitude: 32.8541, address: "Talat Paşa Blv., Opera, Altındağ",
                transportToNext: "Yürüyerek Resim Heykel Müzesi'ne (3 dk)", transportCost: 0,
                entryFee: 60, openingHours: "09:00-17:00 (Kapalı: Pazartesi)", transportInfo: "Sıhhiye Metro durağından yürüyerek 5 dk", tips: "Müzekart geçerlidir."),
            
            // Eymir Gölü
            PlannedActivity(name: "Eymir Gölü", description: "ODTÜ kampüsü yanındaki doğal göl. Bisiklet, yürüyüş ve piknik imkanları.",
                category: .park, startTime: "09:00", endTime: "12:00", estimatedCost: 100,
                latitude: 39.8636, longitude: 32.7979, address: "ODTÜ Yanı, Çankaya",
                transportToNext: "Taksi ile şehir merkezine (25 dk)", transportCost: 200,
                entryFee: 10, openingHours: "07:00-20:00", transportInfo: "Özel araç veya taksi gerekli", tips: "Bisiklet kiralama mevcut. Güneş kremi alın."),
            
            // CerModern Sanat Galerisi
            PlannedActivity(name: "CerModern", description: "Ankara'nın çağdaş sanat merkezi. Eski tren deposu dönüştürülmüş modern galeri.",
                category: .museum, startTime: "14:00", endTime: "16:00", estimatedCost: 0,
                latitude: 39.9298, longitude: 32.8496, address: "Altınsoy Cad. No:3, Sıhhiye",
                transportToNext: "Yürüyerek Kocatepe'ye (10 dk)", transportCost: 0,
                entryFee: 40, openingHours: "10:00-18:00 (Kapalı: Pazartesi)", transportInfo: "Sıhhiye Metro durağından yürüyerek 8 dk", tips: "Sergi programını web sitesinden kontrol edin."),
            
            // Beypazarı
            PlannedActivity(name: "Beypazarı Tarihi Çarşı", description: "Osmanlı dönemi konak mimarisi, yerel lezzetler ve el sanatları. Ankara'ya 100 km.",
                category: .landmark, startTime: "09:00", endTime: "17:00", estimatedCost: 500,
                latitude: 40.1683, longitude: 31.9213, address: "Beypazarı İlçesi, Ankara",
                transportToNext: "Otobüs ile Ankara merkeze (2 saat)", transportCost: 120,
                entryFee: 0, openingHours: "Çarşı: 09:00-19:00", transportInfo: "AŞTİ'den düzenli otobüs seferleri", tips: "Beypazarı kurusu ve havuç lokumu almayı unutmayın.")
        ]
        
        let transportProviders: [TransportType: String] = [
            .flight: "THY / Pegasus",
            .bus: "Metro Turizm / Kamil Koç",
            .train: "TCDD YHT",
            .car: "Kendi Aracınız"
        ]
        
        return CityData(hotels: hotels, activities: activities, transportProviders: transportProviders)
    }
    
    // ============================================================
    // İSTANBUL — GERÇEK VERİLER
    // ============================================================
    private func istanbulData() -> CityData {
        let hotels = [
            Hotel(name: "Four Seasons Sultanahmet", starRating: 5, pricePerNight: 9500, totalPrice: 19000,
                  latitude: 41.0062, longitude: 28.9780, address: "Sultanahmet, Fatih",
                  distanceToCenter: "0.1 km", amenities: ["WiFi", "Spa", "Restoran", "Tarihi"],
                  imageURL: nil, rating: 9.6, reviewCount: 2100, checkIn: "15:00", checkOut: "12:00", notes: nil),
            Hotel(name: "Divan İstanbul", starRating: 5, pricePerNight: 4500, totalPrice: 9000,
                  latitude: 41.0470, longitude: 28.9930, address: "Elmadağ, Şişli",
                  distanceToCenter: "5 km", amenities: ["WiFi", "Havuz", "Fitness", "Restoran"],
                  imageURL: nil, rating: 9.0, reviewCount: 1500, checkIn: "14:00", checkOut: "12:00", notes: nil),
            Hotel(name: "Grand Star Hotel", starRating: 3, pricePerNight: 1500, totalPrice: 3000,
                  latitude: 41.0095, longitude: 28.9710, address: "Sultanahmet, Fatih",
                  distanceToCenter: "0.5 km", amenities: ["WiFi", "Kahvaltı"],
                  imageURL: nil, rating: 8.2, reviewCount: 1800, checkIn: "14:00", checkOut: "12:00", notes: nil),
            Hotel(name: "Hostel Le Banc", starRating: 2, pricePerNight: 600, totalPrice: 1200,
                  latitude: 41.0100, longitude: 28.9680, address: "Sultanahmet, Fatih",
                  distanceToCenter: "0.3 km", amenities: ["WiFi", "Ortak Alan"],
                  imageURL: nil, rating: 7.8, reviewCount: 650, checkIn: "14:00", checkOut: "11:00", notes: nil)
        ]
        
        let activities = [
            PlannedActivity(name: "Ayasofya Camii", description: "537 yılında inşa edilmiş, dünya mirası yapı. Bizans mozaikleri ve Osmanlı hat sanatı bir arada.",
                category: .landmark, startTime: "09:00", endTime: "11:00", estimatedCost: 0,
                latitude: 41.0086, longitude: 28.9802, address: "Sultanahmet Meydanı, Fatih",
                transportToNext: "Yürüyerek (3 dk)", transportCost: 0,
                entryFee: 0, openingHours: "Namaz saatleri dışında", transportInfo: "T1 Tramvay - Sultanahmet durağı", tips: "Başörtüsü girişte temin edilebilir."),
            PlannedActivity(name: "Topkapı Sarayı", description: "Osmanlı İmparatorluğu'nun 400 yıllık yönetim merkezi. Hazine, Harem ve kutsal emanetler.",
                category: .museum, startTime: "10:00", endTime: "13:00", estimatedCost: 0,
                latitude: 41.0115, longitude: 28.9833, address: "Cankurtaran, Fatih",
                transportToNext: "Yürüyerek (10 dk)", transportCost: 0,
                entryFee: 320, openingHours: "09:00-18:00 (Kapalı: Salı)", transportInfo: "T1 Tramvay - Gülhane durağı", tips: "Harem bölümü ayrı biletlidir (+150₺)."),
            PlannedActivity(name: "Kapalıçarşı", description: "Dünyanın en eski ve büyük kapalı çarşılarından biri. 4000+ dükkan.",
                category: .shopping, startTime: "14:00", endTime: "16:00", estimatedCost: 500,
                latitude: 41.0108, longitude: 28.9680, address: "Beyazıt, Fatih",
                transportToNext: "Yürüyerek (15 dk)", transportCost: 0,
                entryFee: 0, openingHours: "08:30-19:00 (Kapalı: Pazar)", transportInfo: "T1 Tramvay - Beyazıt durağı", tips: "Pazarlık yapmayı unutmayın!"),
            PlannedActivity(name: "Galata Kulesi", description: "Beyoğlu'ndaki 67 metre yüksekliğinde tarihi kule. 360° İstanbul panoraması.",
                category: .landmark, startTime: "16:00", endTime: "17:30", estimatedCost: 0,
                latitude: 41.0256, longitude: 28.9741, address: "Bereketzade Mah., Beyoğlu",
                transportToNext: "Yürüyerek İstiklal'e (5 dk)", transportCost: 0,
                entryFee: 650, openingHours: "09:00-20:00", transportInfo: "M2 Metro - Şişhane ya da Karaköy'den yürüyüş", tips: "Gün batımı saatine denk getirin."),
            PlannedActivity(name: "İstiklal Caddesi", description: "Beyoğlu'nun kalbi. Mağazalar, kafeler, tarihi pasajlar ve nostaljik tramvay.",
                category: .shopping, startTime: "17:30", endTime: "19:30", estimatedCost: 300,
                latitude: 41.0337, longitude: 28.9770, address: "İstiklal Cad., Beyoğlu",
                transportToNext: "Taksi (15 dk)", transportCost: 100,
                entryFee: 0, openingHours: "24 saat", transportInfo: "M2 Metro - Taksim durağı", tips: "Çiçek Pasajı ve Balık Pazarı mutlaka görün."),
            PlannedActivity(name: "Boğaz Turu", description: "İstanbul Boğazı'nda tekne ile gezi. Avrupa ve Asya yakası manzaraları.",
                category: .other, startTime: "10:00", endTime: "12:00", estimatedCost: 0,
                latitude: 41.0170, longitude: 28.9770, address: "Eminönü İskelesi, Fatih",
                transportToNext: "Yürüyerek (5 dk)", transportCost: 0,
                entryFee: 150, openingHours: "10:00-18:00 (Seferler saatlik)", transportInfo: "T1 Tramvay - Eminönü durağı", tips: "Kısa tur (~2 saat) veya uzun tur (~6 saat) seçilebilir."),
            PlannedActivity(name: "Sultanahmet Camii", description: "Mavi Camii olarak bilinen, 6 minareli tarihi cami. İç mekanı çini süslemeleriyle ünlü.",
                category: .landmark, startTime: "11:00", endTime: "12:00", estimatedCost: 0,
                latitude: 41.0054, longitude: 28.9768, address: "Sultanahmet, Fatih",
                transportToNext: "Yürüyerek (5 dk)", transportCost: 0,
                entryFee: 0, openingHours: "Namaz saatleri dışında", transportInfo: "T1 Tramvay - Sultanahmet", tips: "Giriş için uygun kıyafet gerekli."),
            PlannedActivity(name: "Yerebatan Sarnıcı", description: "Bizans döneminden kalma yeraltı su sarnıcı. 336 sütunlu gizemli atmosfer.",
                category: .museum, startTime: "13:00", endTime: "14:00", estimatedCost: 0,
                latitude: 41.0084, longitude: 28.9779, address: "Alemdar Mah., Fatih",
                transportToNext: "Yürüyerek (5 dk)", transportCost: 0,
                entryFee: 350, openingHours: "09:00-19:00", transportInfo: "T1 Tramvay - Sultanahmet", tips: "Medusa başlı sütunları kaçırmayın.")
        ]
        
        let transportProviders: [TransportType: String] = [
            .flight: "THY / Pegasus / AnadoluJet",
            .bus: "Metro Turizm / Pamukkale",
            .train: "TCDD YHT (Ankara-İstanbul)",
            .car: "Kendi Aracınız"
        ]
        
        return CityData(hotels: hotels, activities: activities, transportProviders: transportProviders)
    }
    
    // ============================================================
    // DİĞER ŞEHİRLER (Kısa versiyonlar)
    // ============================================================
    private func izmirData() -> CityData {
        let hotels = [
            Hotel(name: "Swissôtel Büyük Efes", starRating: 5, pricePerNight: 5000, totalPrice: 10000,
                  latitude: 38.4237, longitude: 27.1428, address: "Cumhuriyet Blv., Konak",
                  distanceToCenter: "0.5 km", amenities: ["WiFi", "Havuz", "Spa", "Restoran"],
                  imageURL: nil, rating: 9.2, reviewCount: 1600, checkIn: "15:00", checkOut: "12:00", notes: nil),
            Hotel(name: "Hilton Garden Inn İzmir", starRating: 4, pricePerNight: 2200, totalPrice: 4400,
                  latitude: 38.4190, longitude: 27.1285, address: "Alsancak, Konak",
                  distanceToCenter: "2 km", amenities: ["WiFi", "Fitness", "Kahvaltı"],
                  imageURL: nil, rating: 8.6, reviewCount: 1200, checkIn: "14:00", checkOut: "12:00", notes: nil),
            Hotel(name: "Key Hotel", starRating: 3, pricePerNight: 1100, totalPrice: 2200,
                  latitude: 38.4310, longitude: 27.1390, address: "Kordon, Konak",
                  distanceToCenter: "1 km", amenities: ["WiFi", "Kahvaltı"],
                  imageURL: nil, rating: 8.0, reviewCount: 900, checkIn: "14:00", checkOut: "12:00", notes: nil)
        ]
        let activities = [
            PlannedActivity(name: "Saat Kulesi", description: "İzmir'in simgesi, Konak Meydanı'ndaki tarihi saat kulesi.",
                category: .landmark, startTime: "09:00", endTime: "10:00", estimatedCost: 0,
                latitude: 38.4189, longitude: 27.1286, address: "Konak Meydanı, İzmir",
                transportToNext: "Yürüyerek (5 dk)", transportCost: 0,
                entryFee: 0, openingHours: "24 saat (dış)", transportInfo: "İZBAN - Konak durağı", tips: "Fotoğraf için güzel bir köşe."),
            PlannedActivity(name: "Kemeraltı Çarşısı", description: "Osmanlı dönemi çarşısı, yerel lezzetler ve el sanatları.",
                category: .shopping, startTime: "10:00", endTime: "12:00", estimatedCost: 300,
                latitude: 38.4196, longitude: 27.1310, address: "Kemeraltı, Konak",
                transportToNext: "Yürüyerek (10 dk)", transportCost: 0,
                entryFee: 0, openingHours: "09:00-20:00", transportInfo: "Konak'tan yürüyerek 3 dk", tips: "Boyoz ve gevrek mutlaka tadın."),
            PlannedActivity(name: "Kordon Boyu", description: "İzmir'in ünlü sahil yürüyüş yolu. Deniz manzarası eşliğinde yürüyüş.",
                category: .park, startTime: "17:00", endTime: "19:00", estimatedCost: 100,
                latitude: 38.4322, longitude: 27.1398, address: "Kordon, Alsancak",
                transportToNext: "Yürüyerek (5 dk)", transportCost: 0,
                entryFee: 0, openingHours: "24 saat", transportInfo: "Alsancak'tan yürüyerek", tips: "Gün batımı saatinde gidin."),
            PlannedActivity(name: "Efes Antik Kenti", description: "Dünyanın en iyi korunmuş antik kentlerinden biri. Artemis Tapınağı, Celsus Kütüphanesi.",
                category: .landmark, startTime: "09:00", endTime: "14:00", estimatedCost: 500,
                latitude: 37.9395, longitude: 27.3420, address: "Efes Yolu, Selçuk",
                transportToNext: "Minibüs ile İzmir'e (1.5 saat)", transportCost: 60,
                entryFee: 400, openingHours: "08:00-18:30", transportInfo: "İzmir Otogarı'ndan Selçuk minibüsü", tips: "Sabah erken gidin, sıcaktan korunun.")
        ]
        return CityData(hotels: hotels, activities: activities, transportProviders: [.flight: "THY / SunExpress", .bus: "Kamil Koç", .train: "TCDD", .car: "Kendi Aracınız"])
    }
    
    private func antalyaData() -> CityData {
        let hotels = [
            Hotel(name: "Rixos Downtown Antalya", starRating: 5, pricePerNight: 6000, totalPrice: 12000,
                  latitude: 36.8861, longitude: 30.7055, address: "Lara, Muratpaşa",
                  distanceToCenter: "10 km", amenities: ["WiFi", "Ultra Her Şey Dahil", "Havuz", "Spa"],
                  imageURL: nil, rating: 9.4, reviewCount: 2200, checkIn: "14:00", checkOut: "12:00", notes: nil),
            Hotel(name: "Akra Hotel", starRating: 5, pricePerNight: 3500, totalPrice: 7000,
                  latitude: 36.8758, longitude: 30.6954, address: "Şirinyalı Mah., Muratpaşa",
                  distanceToCenter: "3 km", amenities: ["WiFi", "Havuz", "Deniz Manzarası"],
                  imageURL: nil, rating: 9.1, reviewCount: 1800, checkIn: "14:00", checkOut: "12:00", notes: nil),
            Hotel(name: "La Boutique Hotel", starRating: 3, pricePerNight: 1300, totalPrice: 2600,
                  latitude: 36.8853, longitude: 30.7028, address: "Kaleiçi, Muratpaşa",
                  distanceToCenter: "0.5 km", amenities: ["WiFi", "Kahvaltı", "Tarihi"],
                  imageURL: nil, rating: 8.3, reviewCount: 800, checkIn: "14:00", checkOut: "11:00", notes: nil)
        ]
        let activities = [
            PlannedActivity(name: "Kaleiçi", description: "Antalya'nın tarihi kalbi. Dar sokaklar, Osmanlı evleri, deniz manzarası.",
                category: .landmark, startTime: "10:00", endTime: "12:00", estimatedCost: 200,
                latitude: 36.8844, longitude: 30.7044, address: "Kaleiçi, Muratpaşa",
                transportToNext: "Yürüyerek (5 dk)", transportCost: 0,
                entryFee: 0, openingHours: "24 saat", transportInfo: "AntRay - İsmetpaşa durağı", tips: "Yivli Minare ve Kesik Minare'yi görün."),
            PlannedActivity(name: "Düden Şelalesi", description: "Şehir içindeki etkileyici şelale. Piknik alanları ve manzara seyir noktaları.",
                category: .park, startTime: "14:00", endTime: "16:00", estimatedCost: 50,
                latitude: 36.9124, longitude: 30.7394, address: "Varsak, Kepez",
                transportToNext: "Otobüs ile (30 dk)", transportCost: 20,
                entryFee: 8, openingHours: "08:00-19:00", transportInfo: "Merkezden otobüs seferleri var", tips: "Fotoğraf makinesi mutlaka alın."),
            PlannedActivity(name: "Antalya Müzesi", description: "Bölgenin en kapsamlı arkeoloji müzesi. Antik dönem heykeller ve eserler.",
                category: .museum, startTime: "10:00", endTime: "12:30", estimatedCost: 0,
                latitude: 36.8842, longitude: 30.6785, address: "Konyaaltı, Muratpaşa",
                transportToNext: "Tramvay (10 dk)", transportCost: 10,
                entryFee: 200, openingHours: "08:30-17:30", transportInfo: "AntRay - Müze durağı", tips: "Müzekart geçerlidir.")
        ]
        return CityData(hotels: hotels, activities: activities, transportProviders: [.flight: "THY / Pegasus / SunExpress", .bus: "Pamukkale", .train: "YHT yok, otobüs önerilir", .car: "Kendi Aracınız"])
    }
    
    private func kapadokyaData() -> CityData {
        let hotels = [
            Hotel(name: "Museum Hotel", starRating: 5, pricePerNight: 8000, totalPrice: 16000,
                  latitude: 38.6386, longitude: 34.8298, address: "Tekelli Mah., Uçhisar",
                  distanceToCenter: "5 km (Göreme)", amenities: ["WiFi", "Havuz", "Mağara Oda", "Restoran"],
                  imageURL: nil, rating: 9.7, reviewCount: 1200, checkIn: "15:00", checkOut: "12:00", notes: "Dünyanın en iyi mağara oteli"),
            Hotel(name: "Kelebek Cave Hotel", starRating: 4, pricePerNight: 2500, totalPrice: 5000,
                  latitude: 38.6420, longitude: 34.8310, address: "Göreme, Nevşehir",
                  distanceToCenter: "0.2 km", amenities: ["WiFi", "Teras", "Mağara Oda"],
                  imageURL: nil, rating: 9.0, reviewCount: 950, checkIn: "14:00", checkOut: "11:00", notes: nil),
            Hotel(name: "Göreme House", starRating: 2, pricePerNight: 800, totalPrice: 1600,
                  latitude: 38.6438, longitude: 34.8285, address: "Göreme, Nevşehir",
                  distanceToCenter: "0.1 km", amenities: ["WiFi", "Kahvaltı"],
                  imageURL: nil, rating: 7.8, reviewCount: 600, checkIn: "14:00", checkOut: "11:00", notes: nil)
        ]
        let activities = [
            PlannedActivity(name: "Sıcak Hava Balonu", description: "Kapadokya'nın en ikonik deneyimi. Peri bacaları üzerinde balon turu.",
                category: .other, startTime: "05:30", endTime: "07:30", estimatedCost: 0,
                latitude: 38.6425, longitude: 34.8305, address: "Göreme, Nevşehir",
                transportToNext: "Transfer (10 dk)", transportCost: 0,
                entryFee: 4500, openingHours: "Gün doğumu (hava koşullarına bağlı)", transportInfo: "Otelden transfer dahil", tips: "En az 1 hafta önceden rezervasyon yapın."),
            PlannedActivity(name: "Göreme Açık Hava Müzesi", description: "UNESCO Dünya Mirası. Bizans dönemi kaya kiliseleri ve freskleri.",
                category: .museum, startTime: "09:00", endTime: "11:00", estimatedCost: 0,
                latitude: 38.6432, longitude: 34.8385, address: "Göreme, Nevşehir",
                transportToNext: "Yürüyerek (15 dk)", transportCost: 0,
                entryFee: 250, openingHours: "08:00-18:00", transportInfo: "Göreme'den yürüyerek 15 dk", tips: "Karanlık Kilise ayrı biletli (+50₺)."),
            PlannedActivity(name: "Derinkuyu Yeraltı Şehri", description: "8 kat derinliğinde antik yeraltı şehri. 20.000+ kişi kapasiteli.",
                category: .landmark, startTime: "13:00", endTime: "15:00", estimatedCost: 0,
                latitude: 38.3733, longitude: 34.7340, address: "Derinkuyu, Nevşehir",
                transportToNext: "Minibüs ile Göreme'ye (45 dk)", transportCost: 40,
                entryFee: 150, openingHours: "08:00-17:00", transportInfo: "Göreme'den tur veya minibüs", tips: "Klostrofobik kişiler için uygun olmayabilir.")
        ]
        return CityData(hotels: hotels, activities: activities, transportProviders: [.flight: "THY (Nevşehir/Kayseri)", .bus: "Metro Turizm / Nevtur", .train: "YHT - Kayseri + transfer", .car: "Kendi Aracınız"])
    }
    
    private func bodrumData() -> CityData {
        let hotels = [
            Hotel(name: "Mandarin Oriental Bodrum", starRating: 5, pricePerNight: 15000, totalPrice: 30000,
                  latitude: 37.0505, longitude: 27.4258, address: "Cennet Koyu, Göltürkbükü",
                  distanceToCenter: "15 km", amenities: ["WiFi", "Özel Plaj", "Spa", "2 Havuz"],
                  imageURL: nil, rating: 9.8, reviewCount: 800, checkIn: "15:00", checkOut: "12:00", notes: nil),
            Hotel(name: "Karia Princess Hotel", starRating: 4, pricePerNight: 3000, totalPrice: 6000,
                  latitude: 37.0382, longitude: 27.4300, address: "Bodrum Merkez",
                  distanceToCenter: "0.5 km", amenities: ["WiFi", "Havuz", "Deniz Manzarası"],
                  imageURL: nil, rating: 8.8, reviewCount: 1100, checkIn: "14:00", checkOut: "12:00", notes: nil),
            Hotel(name: "Costa Sarıyaz Hotel", starRating: 3, pricePerNight: 1200, totalPrice: 2400,
                  latitude: 37.0380, longitude: 27.4280, address: "Bodrum Merkez",
                  distanceToCenter: "0.3 km", amenities: ["WiFi", "Kahvaltı", "Havuz"],
                  imageURL: nil, rating: 7.9, reviewCount: 750, checkIn: "14:00", checkOut: "11:00", notes: nil)
        ]
        let activities = [
            PlannedActivity(name: "Bodrum Kalesi & Sualtı Müzesi", description: "Haçlılar döneminden kalma kale. İçinde Sualtı Arkeoloji Müzesi bulunur.",
                category: .museum, startTime: "09:00", endTime: "11:00", estimatedCost: 0,
                latitude: 37.0325, longitude: 27.4308, address: "Kale Cad., Bodrum",
                transportToNext: "Yürüyerek (5 dk)", transportCost: 0,
                entryFee: 250, openingHours: "09:00-19:00", transportInfo: "Bodrum merkez, yürüyerek erişilebilir", tips: "Kale tepesinden muhteşem manzara var."),
            PlannedActivity(name: "Bodrum Marina & Barlar Sokağı", description: "Lüks yatlar, restoranlar ve gece hayatı.",
                category: .nightlife, startTime: "20:00", endTime: "23:00", estimatedCost: 800,
                latitude: 37.0335, longitude: 27.4292, address: "Neyzen Tevfik Cad., Bodrum",
                transportToNext: "Yürüyerek (5 dk)", transportCost: 0,
                entryFee: 0, openingHours: "Restoranlar: 12:00-02:00", transportInfo: "Merkez, yürüyerek erişilebilir", tips: "Hafta sonu çok kalabalık olabilir.")
        ]
        return CityData(hotels: hotels, activities: activities, transportProviders: [.flight: "THY / SunExpress (Milas Havalimanı)", .bus: "Pamukkale / Kamil Koç", .train: "YHT yok", .car: "Kendi Aracınız"])
    }
}
