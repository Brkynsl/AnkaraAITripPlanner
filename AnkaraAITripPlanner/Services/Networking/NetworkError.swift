// MARK: - NetworkError.swift
// Amaç: Ağ isteklerinde oluşabilecek hataları tanımlar.
// Açıklama: URLSession tabanlı networking katmanında meydana gelen hataları
//           anlamlı ve kullanıcı dostu mesajlarla sınıflandırır.
//           Her hata tipi için Türkçe açıklama sağlar.

import Foundation

// MARK: - Ağ Hataları
enum NetworkError: Error, LocalizedError {
    case invalidURL                    // Geçersiz URL
    case noData                        // Sunucudan veri gelmedi
    case decodingFailed                // JSON parse hatası
    case serverError(statusCode: Int)  // Sunucu hatası (4xx, 5xx)
    case noInternetConnection          // İnternet bağlantısı yok
    case timeout                       // İstek zaman aşımı
    case unauthorized                  // Yetkisiz erişim (401)
    case notFound                      // Kaynak bulunamadı (404)
    case rateLimited                   // İstek limiti aşıldı (429)
    case unknown(Error)                // Bilinmeyen hata
    
    // Kullanıcıya gösterilecek Türkçe hata mesajları
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz istek adresi. Lütfen tekrar deneyin."
        case .noData:
            return "Sunucudan yanıt alınamadı."
        case .decodingFailed:
            return "Veri işlenirken bir sorun oluştu."
        case .serverError(let statusCode):
            return "Sunucu hatası (Kod: \(statusCode)). Lütfen daha sonra tekrar deneyin."
        case .noInternetConnection:
            return "İnternet bağlantınızı kontrol edin."
        case .timeout:
            return "İstek zaman aşımına uğradı. Bağlantınızı kontrol edip tekrar deneyin."
        case .unauthorized:
            return "Bu işlem için yetkiniz yok. Lütfen tekrar giriş yapın."
        case .notFound:
            return "Aradığınız bilgi bulunamadı."
        case .rateLimited:
            return "Çok fazla istek gönderildi. Lütfen biraz bekleyin."
        case .unknown(let error):
            return "Beklenmeyen bir hata oluştu: \(error.localizedDescription)"
        }
    }
}
