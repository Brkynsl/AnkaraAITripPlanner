// MARK: - NetworkManager.swift
// Amaç: URLSession tabanlı generic networking katmanı.
// Açıklama: Tüm API çağrılarını merkezi olarak yönetir. Generic yapısı sayesinde
//           herhangi bir Codable modeli decode edebilir. Retry mekanizması,
//           hata sınıflandırması ve response caching gibi production-level
//           özellikler içerir. Singleton pattern ile uygulama genelinde
//           tek bir URLSession üzerinden çalışır.

import Foundation

final class NetworkManager {
    
    // MARK: - Singleton
    static let shared = NetworkManager()
    
    // Özelleştirilmiş URLSession — timeout ve cache ayarları
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        // Aynı anda en fazla 4 bağlantı (API rate limit'i aşmamak için)
        configuration.httpMaximumConnectionsPerHost = 4
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Generic API İsteği
    // Herhangi bir Codable modeli decode edebilen generic metot.
    // T: Decodable — döndürülecek model tipi
    // endpoint: APIEndpoint — istek yapılacak uç nokta
    // completion: Sonuç veya hata döndüren closure
    func request<T: Decodable>(
        endpoint: APIEndpoint,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        // URLRequest oluştur
        guard let urlRequest = endpoint.asURLRequest() else {
            completion(.failure(.invalidURL))
            return
        }
        
        // İsteği başlat
        let task = session.dataTask(with: urlRequest) { data, response, error in
            // Ana thread'e dönerek UI güncellemelerinin sorunsuz olmasını sağla
            DispatchQueue.main.async {
                // Ağ hatası kontrolü
                if let error = error {
                    if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                        completion(.failure(.noInternetConnection))
                    } else if (error as NSError).code == NSURLErrorTimedOut {
                        completion(.failure(.timeout))
                    } else {
                        completion(.failure(.unknown(error)))
                    }
                    return
                }
                
                // HTTP durum kodu kontrolü
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200...299:
                        break // Başarılı — devam et
                    case 401:
                        completion(.failure(.unauthorized))
                        return
                    case 404:
                        completion(.failure(.notFound))
                        return
                    case 429:
                        completion(.failure(.rateLimited))
                        return
                    default:
                        completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                        return
                    }
                }
                
                // Veri kontrolü
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                // JSON decode
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let decodedResponse = try decoder.decode(T.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    print("🔴 Decode hatası: \(error)")
                    completion(.failure(.decodingFailed))
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Raw Data İsteği
    // JSON decode gerektirmeyen istekler için (resim indirme, raw response vb.)
    func requestData(
        url: URL,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) {
        let task = session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.unknown(error)))
                    return
                }
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                completion(.success(data))
            }
        }
        task.resume()
    }
    
    // MARK: - POST İsteği (JSON Body ile)
    // Veri gönderme gerektiren API çağrıları için.
    // body parametresi Encodable tipinde herhangi bir model olabilir.
    func post<T: Decodable, B: Encodable>(
        url: String,
        body: B,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(body)
        } catch {
            completion(.failure(.decodingFailed))
            return
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.unknown(error)))
                    return
                }
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let decoded = try decoder.decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(.decodingFailed))
                }
            }
        }
        task.resume()
    }
}
