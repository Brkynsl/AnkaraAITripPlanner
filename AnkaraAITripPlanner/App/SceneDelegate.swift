//
//  SceneDelegate.swift
//  AnkaraAITripPlanner
//

import UIKit
import FirebaseAuth // Auth durumu kontrolü için

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // Amaç: Uygulama ekranı göründüğünde hangi View Controller'ın ilk açılacağını belirlemek.
    // Açıklama: Kullanıcı oturum açmış mı? Onboarding'i geçmiş mi? Bu soruların cevabına göre 
    // root (kök) View Controller'ı dinamik olarak SceneDelegate üzerinden atıyoruz.
    // Klasik Storyboard "Is Initial View Controller" okunu kod ile ezmiş oluyoruz.
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Geliştirme Notu: Eğer her seferinde Login ekranını görmek istiyorsan 
        // aşağıdaki satırı bir seferlik aktif et (comment'i kaldır) ve uygulamayı çalıştır.
        // try? Auth.auth().signOut()
        
        // 1. Durum: Kullanıcı giriş yapmış mı?
        if let currentUser = Auth.auth().currentUser {
            print("LOG: Kullanıcı oturumu açık: \(currentUser.email ?? "Unknown")")
            
            let hasSeenOnboarding = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding)
            
            if hasSeenOnboarding {
                let mainTabBarVC = MainTabBarController()
                window.rootViewController = mainTabBarVC
            } else {
                let onboardingVC = OnboardingContainerViewController()
                window.rootViewController = onboardingVC
            }
        } else {
            print("LOG: Oturum kapalı, Login ekranına yönlendiriliyor.")
            let loginVC = LoginViewController()
            let navVC = UINavigationController(rootViewController: loginVC)
            window.rootViewController = navVC
        }
        
        // Window'u görünür yap
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
