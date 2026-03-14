//
//  AppDelegate.swift
//  AnkaraAITripPlanner
//

import UIKit
import FirebaseCore // Firebase kullanımı için gerekli

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // Amaç: Uygulama başlatıldığında Firebase gibi temel servisleri konfigüre etmek.
    // Açıklama: didFinishLaunchingWithOptions metodu, uygulama hafızaya yüklendikten hemen sonra çağrılır.
    // Burada FirebaseCore kütüphanesini kullanarak projemizi Firebase'e bağlıyoruz.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Firebase yapılandırmasını başlatıyoruz. (GoogleService-Info.plist dosyasındaki verileri okur)
        FirebaseApp.configure()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Yeni bir scene (ekran) oluşturulacağı zaman çağrılır.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Kullanıcı bir scene'i kapattığında (örn: app switcher'dan sildiğinde) çağrılır.
    }
}
