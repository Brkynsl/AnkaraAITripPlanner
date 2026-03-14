// MARK: - UserPreferences.swift
// Amaç: Kullanıcının seyahat tercihlerini temsil eden veri modeli.
// Açıklama: Profil ekranında düzenlenen tercihler burada saklanır.
//           Favori ulaşım türleri, yemek tercihleri, ilgi alanları ve
//           bütçe davranışı gibi kişiselleştirme öğeleri içerir.
//           AI motoru bu tercihleri plan üretirken dikkate alır.

import Foundation

// MARK: - Bütçe Davranışı
// Kullanıcının bütçeyi nasıl kullanmak istediğini belirtir.
enum BudgetBehavior: String, Codable, CaseIterable {
    case saver = "saver"           // Tasarrufçu — mümkün olduğunca az harca
    case balanced = "balanced"     // Dengeli — arada kal
    case spender = "spender"       // Harcamacı — kaliteden taviz verme
    
    var displayName: String {
        switch self {
        case .saver: return "Tasarrufçu"
        case .balanced: return "Dengeli"
        case .spender: return "Kalite Odaklı"
        }
    }
    
    var description: String {
        switch self {
        case .saver: return "Bütçemi mümkün olduğunca az harcamak istiyorum"
        case .balanced: return "Kalite ve fiyat arasında denge kurulsun"
        case .spender: return "Kaliteden taviz vermek istemiyorum"
        }
    }
}

// MARK: - İlgi Alanı Kategorisi
enum InterestCategory: String, Codable, CaseIterable {
    case culture = "culture"         // Kültür / Tarih
    case nature = "nature"           // Doğa / Park
    case food = "food"               // Yeme-İçme / Lezzet
    case museum = "museum"           // Müze
    case shopping = "shopping"       // Alışveriş
    case nightlife = "nightlife"     // Gece Hayatı
    case adventure = "adventure"     // Macera / Spor
    case photography = "photography" // Fotoğrafçılık
    case religious = "religious"     // Dini / Manevi
    case art = "art"                 // Sanat
    
    var displayName: String {
        switch self {
        case .culture: return "Kültür & Tarih"
        case .nature: return "Doğa & Park"
        case .food: return "Yeme & İçme"
        case .museum: return "Müze"
        case .shopping: return "Alışveriş"
        case .nightlife: return "Gece Hayatı"
        case .adventure: return "Macera & Spor"
        case .photography: return "Fotoğrafçılık"
        case .religious: return "Dini Mekanlar"
        case .art: return "Sanat"
        }
    }
    
    var iconName: String {
        switch self {
        case .culture: return "building.columns"
        case .nature: return "leaf.fill"
        case .food: return "fork.knife"
        case .museum: return "paintpalette.fill"
        case .shopping: return "bag.fill"
        case .nightlife: return "moon.stars.fill"
        case .adventure: return "figure.hiking"
        case .photography: return "camera.fill"
        case .religious: return "star.fill"
        case .art: return "theatermasks.fill"
        }
    }
}

// MARK: - Yemek Tercihi
enum FoodPreference: String, Codable, CaseIterable {
    case traditional = "traditional"   // Geleneksel Türk mutfağı
    case international = "international" // Uluslararası
    case vegetarian = "vegetarian"     // Vejetaryen
    case vegan = "vegan"               // Vegan
    case fastFood = "fastFood"         // Fast food
    case seafood = "seafood"           // Deniz ürünleri
    case streetFood = "streetFood"     // Sokak lezzetleri
    
    var displayName: String {
        switch self {
        case .traditional: return "Geleneksel Türk"
        case .international: return "Uluslararası"
        case .vegetarian: return "Vejetaryen"
        case .vegan: return "Vegan"
        case .fastFood: return "Fast Food"
        case .seafood: return "Deniz Ürünleri"
        case .streetFood: return "Sokak Lezzetleri"
        }
    }
}

// MARK: - Kullanıcı Tercihleri Modeli
struct UserPreferences: Codable {
    
    // Favori ulaşım türleri (birden fazla seçilebilir)
    var transportPreferences: [TransportType]
    
    // Yemek tercihleri
    var foodPreferences: [FoodPreference]
    
    // İlgi alanları
    var interestCategories: [InterestCategory]
    
    // Bütçe davranışı
    var budgetBehavior: BudgetBehavior
    
    // Karanlık mod tercihi
    var isDarkModeEnabled: Bool
    
    // Dil tercihi
    var language: String
    
    // MARK: - Varsayılan Tercihler
    // İlk kayıt olan kullanıcılar için mantıklı varsayılan değerler.
    static var defaultPreferences: UserPreferences {
        return UserPreferences(
            transportPreferences: [.bus, .train],
            foodPreferences: [.traditional],
            interestCategories: [.culture, .food, .museum],
            budgetBehavior: .balanced,
            isDarkModeEnabled: false,
            language: "tr"
        )
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "transportPreferences": transportPreferences.map { $0.rawValue },
            "foodPreferences": foodPreferences.map { $0.rawValue },
            "interestCategories": interestCategories.map { $0.rawValue },
            "budgetBehavior": budgetBehavior.rawValue,
            "isDarkModeEnabled": isDarkModeEnabled,
            "language": language
        ]
    }
    
    static func fromDictionary(_ dict: [String: Any]) -> UserPreferences {
        let transportRaw = dict["transportPreferences"] as? [String] ?? []
        let foodRaw = dict["foodPreferences"] as? [String] ?? []
        let interestRaw = dict["interestCategories"] as? [String] ?? []
        
        return UserPreferences(
            transportPreferences: transportRaw.compactMap { TransportType(rawValue: $0) },
            foodPreferences: foodRaw.compactMap { FoodPreference(rawValue: $0) },
            interestCategories: interestRaw.compactMap { InterestCategory(rawValue: $0) },
            budgetBehavior: BudgetBehavior(rawValue: dict["budgetBehavior"] as? String ?? "") ?? .balanced,
            isDarkModeEnabled: dict["isDarkModeEnabled"] as? Bool ?? false,
            language: dict["language"] as? String ?? "tr"
        )
    }
}
