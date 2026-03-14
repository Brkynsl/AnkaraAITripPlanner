//
//  SceneDelegate.swift
//  AnkaraAITripPlanner
//

import UIKit
import FirebaseAuth // Auth durumu kontrolü için

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Kaydedilmiş dark mode tercihini uygula
        let isDarkMode = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isDarkModeEnabled)
        window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        
        // Kullanıcı giriş yapmış mı?
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
            showLoginScreen(animated: false)
        }
        
        window.makeKeyAndVisible()
    }
    
    // MARK: - Root VC Değiştirme Yardımcıları
    // Uygulama genelinde kullanılır (login başarı, logout, vb.)
    
    func showLoginScreen(animated: Bool = true) {
        let loginVC = LoginViewController()
        let navVC = UINavigationController(rootViewController: loginVC)
        navVC.navigationBar.isHidden = true
        setRootViewController(navVC, animated: animated)
    }
    
    func showMainScreen(animated: Bool = true) {
        let mainTabBarVC = MainTabBarController()
        setRootViewController(mainTabBarVC, animated: animated)
    }
    
    func showOnboarding(animated: Bool = true) {
        let onboardingVC = OnboardingContainerViewController()
        setRootViewController(onboardingVC, animated: animated)
    }
    
    private func setRootViewController(_ vc: UIViewController, animated: Bool) {
        guard let window = self.window else { return }
        
        if animated {
            UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: {
                window.rootViewController = vc
            })
        } else {
            window.rootViewController = vc
        }
    }
    
    // MARK: - Dark Mode Toggle
    func setDarkMode(_ enabled: Bool) {
        window?.overrideUserInterfaceStyle = enabled ? .dark : .light
        UserDefaults.standard.set(enabled, forKey: UserDefaultsKeys.isDarkModeEnabled)
    }
    
    // MARK: - Yardımcı: SceneDelegate'e erişim
    static var shared: SceneDelegate? {
        return UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) 
            .flatMap { $0.delegate as? SceneDelegate }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
