// MARK: - LocationManager.swift
// Amaç: Kullanıcının konum bilgisini yönetir ve konum izni akışını kontrol eder.
// Açıklama: CoreLocation framework'ünü kullanarak kullanıcının mevcut konumunu alır.
//           Harita özelliklerinde kullanılır. Konum izni durumunu takip eder ve
//           uygun hata mesajları gösterir. Delegate pattern yerine closure tabanlı
//           callback kullanarak modern bir yaklaşım sunar.

import Foundation
import CoreLocation

final class LocationManager: NSObject {
    
    // MARK: - Singleton
    static let shared = LocationManager()
    
    // CoreLocation'ın ana yönetici nesnesi
    private let locationManager = CLLocationManager()
    
    // Konum güncellemesi geldiğinde çağrılacak closure
    private var locationCompletion: ((CLLocation?, Error?) -> Void)?
    
    // Son bilinen konum (cache)
    private(set) var lastKnownLocation: CLLocation?
    
    // MARK: - Başlatma
    private override init() {
        super.init()
        locationManager.delegate = self
        // Şehir seviyesinde doğruluk yeterli — pil tasarrufu sağlar
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    // MARK: - Konum İzni Durumu
    // Mevcut konum izni durumunu döndürür.
    var authorizationStatus: CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }
    
    // MARK: - Konum İzni İsteme
    // Kullanıcıdan konum izni ister. İlk seferde sistem dialog'u gösterilir.
    // "Uygulamayı kullanırken" izni istenir — arka planda konum gerekmez.
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Mevcut Konumu Alma
    // Tek seferlik konum güncellemesi alır.
    // Completion handler ile sonuç veya hata döndürür.
    func getCurrentLocation(completion: @escaping (CLLocation?, Error?) -> Void) {
        self.locationCompletion = completion
        
        switch authorizationStatus {
        case .notDetermined:
            // Henüz izin istenmemiş — önce izin iste
            requestLocationPermission()
        case .restricted, .denied:
            // İzin reddedilmiş — hata döndür
            let error = NSError(
                domain: "LocationManager",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Konum izni verilmemiş. Lütfen Ayarlar'dan konum iznini açın."]
            )
            completion(nil, error)
        case .authorizedWhenInUse, .authorizedAlways:
            // İzin verilmiş — konum al
            locationManager.requestLocation()
        @unknown default:
            break
        }
    }
    
    // MARK: - İki Nokta Arası Mesafe Hesaplama
    // Metre cinsinden mesafe döndürür. Kuş uçuşu mesafedir.
    // Haritada gezi noktaları arası mesafe göstermek için kullanılır.
    func distanceBetween(
        from: CLLocationCoordinate2D,
        to: CLLocationCoordinate2D
    ) -> CLLocationDistance {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
    
    // MARK: - Mesafeyi Okunabilir Formata Çevirme
    // Metre → "1.2 km" veya "800 m" formatına çevirir.
    func formatDistance(_ meters: CLLocationDistance) -> String {
        if meters >= 1000 {
            return String(format: "%.1f km", meters / 1000)
        } else {
            return String(format: "%.0f m", meters)
        }
    }
}

// MARK: - CLLocationManagerDelegate
// CoreLocation'dan gelen konum güncellemelerini ve hataları işler.
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastKnownLocation = location
        locationCompletion?(location, nil)
        locationCompletion = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationCompletion?(nil, error)
        locationCompletion = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // İzin durumu değiştiğinde, bekleyen bir istek varsa tekrar dene
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            if locationCompletion != nil {
                manager.requestLocation()
            }
        default:
            break
        }
    }
}
