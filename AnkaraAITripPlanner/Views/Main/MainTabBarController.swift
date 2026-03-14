// MARK: - MainTabBarController.swift
// Amaç: Uygulamanın ana tab bar yapısını oluşturur ve yönetir.
// Açıklama: 3 ana sekmeyi (Ana Sayfa, Tatilim, Profilim) barındıran
//           UITabBarController alt sınıfıdır. Modern ve premium görünümlü
//           bir tab bar tasarımı sunar. Her sekme kendi NavigationController'ı
//           içinde çalışır — böylece her sekmede bağımsız navigation stack olur.
//
// STORYBOARD BAĞLANTISI:
//   Storyboard ID: "MainTabBarVC"
//   Class: MainTabBarController

import UIKit

final class MainTabBarController: UITabBarController {
    
    // MARK: - Yaşam Döngüsü
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBarAppearance()
    }
    
    // MARK: - Tab Bar Sekmeleri Kurulumu
    // Her sekmeyi kendi NavigationController'ı içinde oluşturur.
    // Navigation Controller sayesinde her sekmede push/pop navigation çalışır.
    private func setupViewControllers() {
        
        // 1. Ana Sayfa Sekmesi
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(
            title: "Ana Sayfa",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        homeNav.tabBarItem.tag = 0
        
        // 2. Tatilim Sekmesi
        let myTripVC = MyTripViewController()
        let myTripNav = UINavigationController(rootViewController: myTripVC)
        myTripNav.tabBarItem = UITabBarItem(
            title: "Tatilim",
            image: UIImage(systemName: "suitcase"),
            selectedImage: UIImage(systemName: "suitcase.fill")
        )
        myTripNav.tabBarItem.tag = 1
        
        // 3. Profilim Sekmesi
        let profileVC = ProfileViewController()
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(
            title: "Profilim",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        profileNav.tabBarItem.tag = 2
        
        // Tab bar'a sekmeleri ata
        viewControllers = [homeNav, myTripNav, profileNav]
        
        // Başlangıçta Ana Sayfa seçili olsun
        selectedIndex = 0
    }
    
    // MARK: - Tab Bar Görünüm Ayarları
    // Modern, şeffaf ve premium görünümlü tab bar oluşturur.
    // iOS 15+ appearance API'si kullanılır.
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        // Arka plan rengi — hafif blur efektli
        appearance.backgroundColor = AppColors.cardBackground
        
        // Seçili öğe rengi
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: AppColors.tabBarSelected,
            .font: AppFonts.medium(10)
        ]
        
        // Seçilmemiş öğe rengi
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: AppColors.tabBarUnselected,
            .font: AppFonts.regular(10)
        ]
        
        // Normal durum ayarları
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.normal.iconColor = AppColors.tabBarUnselected
        
        // Seçili durum ayarları
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        appearance.stackedLayoutAppearance.selected.iconColor = AppColors.tabBarSelected
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        // Tab bar'ın üst çizgisini gizle — daha modern görünüm
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
    }
    
    // MARK: - Sekme Değişim Animasyonu
    // Tab değiştiğinde hafif haptic feedback ver
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        HapticManager.shared.selection()
        
        // Seçilen tab ikonuna küçük bounce animasyonu ekle
        guard let items = tabBar.items,
              let index = items.firstIndex(of: item),
              let tabBarButtons = tabBar.subviews.filter({ String(describing: type(of: $0)) == "UITabBarButton" }) as? [UIView],
              index < tabBarButtons.count else { return }
        
        let selectedView = tabBarButtons[index]
        
        UIView.animate(withDuration: 0.15, animations: {
            selectedView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5) {
                selectedView.transform = .identity
            }
        })
    }
}
