// MARK: - APIEndpoint.swift
// Amaç: API uç noktalarını (endpoint) merkezi bir enum ile tanımlar.
// Açıklama: Tüm API URL'lerini ve yapılandırmalarını bu dosyada tutarak
//           URL string'lerinin kod içinde dağılmasını önler.
//           Her endpoint kendi HTTP metodu, URL'i ve header'larını bilir.
//           Aşama 2'de gerçek API'ler bağlandığında sadece bu dosya güncellenir.

import Foundation

// MARK: - HTTP Metotları
enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
    case PATCH
}

// MARK: - API Endpoint Tanımları
// Her API çağrısı bir endpoint ile temsil edilir.
// URL, metot ve header bilgilerini içerir.
enum APIEndpoint {
    
    // Ulaşım API'leri
    case searchFlights(from: String, to: String, date: String)
    case searchBuses(from: String, to: String, date: String)
    case searchTrains(from: String, to: String, date: String)
    
    // Otel API'leri
    case searchHotels(city: String, checkIn: String, checkOut: String)
    case hotelDetails(hotelId: String)
    
    // Gezi Noktası API'leri
    case getAttractions(city: String)
    case attractionDetails(attractionId: String)
    
    // Restoran API'leri
    case searchRestaurants(city: String, cuisine: String?)
    
    // Hava Durumu API'si (seyahat planlamasına katkı)
    case getWeather(city: String, date: String)
    
    // MARK: - Base URL
    // Gerçek API entegrasyonunda bu URL değiştirilecek.
    // Şu an için placeholder — mock servis kullanılacak.
    private var baseURL: String {
        return "https://api.ankaraaitripplanner.com/v1"
    }
    
    // MARK: - Endpoint Yolu
    var path: String {
        switch self {
        case .searchFlights:
            return "/transportation/flights"
        case .searchBuses:
            return "/transportation/buses"
        case .searchTrains:
            return "/transportation/trains"
        case .searchHotels:
            return "/hotels/search"
        case .hotelDetails(let id):
            return "/hotels/\(id)"
        case .getAttractions:
            return "/attractions"
        case .attractionDetails(let id):
            return "/attractions/\(id)"
        case .searchRestaurants:
            return "/restaurants/search"
        case .getWeather:
            return "/weather"
        }
    }
    
    // MARK: - HTTP Metodu
    var method: HTTPMethod {
        switch self {
        case .searchFlights, .searchBuses, .searchTrains,
             .searchHotels, .searchRestaurants:
            return .GET
        default:
            return .GET
        }
    }
    
    // MARK: - Query Parametreleri
    var queryParameters: [String: String] {
        switch self {
        case .searchFlights(let from, let to, let date),
             .searchBuses(let from, let to, let date),
             .searchTrains(let from, let to, let date):
            return ["from": from, "to": to, "date": date]
        case .searchHotels(let city, let checkIn, let checkOut):
            return ["city": city, "checkIn": checkIn, "checkOut": checkOut]
        case .getAttractions(let city):
            return ["city": city]
        case .searchRestaurants(let city, let cuisine):
            var params = ["city": city]
            if let cuisine = cuisine { params["cuisine"] = cuisine }
            return params
        case .getWeather(let city, let date):
            return ["city": city, "date": date]
        default:
            return [:]
        }
    }
    
    // MARK: - Tam URL Oluşturma
    // baseURL + path + query parametreleri birleştirilerek URLRequest oluşturulur.
    func asURLRequest() -> URLRequest? {
        guard var components = URLComponents(string: baseURL + path) else { return nil }
        
        if !queryParameters.isEmpty {
            components.queryItems = queryParameters.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        
        guard let url = components.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        return request
    }
}
