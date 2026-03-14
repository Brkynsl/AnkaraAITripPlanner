// MARK: - Constants.swift
// Amaç: Uygulama genelinde kullanılan sabit değerleri tek bir merkezde toplar.
// Açıklama: Renkler, fontlar, Firestore koleksiyon isimleri, boyut sabitleri ve
// uygulama genelindeki tüm "sihirli sayılar" burada tanımlanır. Bu sayede
// bir değişiklik yapıldığında sadece bu dosyayı güncellemek yeterli olur.
// Bu yaklaşım "Single Source of Truth" prensibini uygular.

import UIKit

// MARK: - Uygulama Renk Paleti
// Uygulamanın tüm renklerini tek bir enum altında topladık.
// Dark mode desteği için UIColor(dynamicProvider:) kullanıyoruz.
// Bu sayede iOS otomatik olarak light/dark modda doğru rengi seçer.
enum AppColors {
    
    // Ana marka rengi — koyu lacivert/mavi tonunda premium his verir
    static let primary = UIColor(red: 0.11, green: 0.11, blue: 0.35, alpha: 1.0)
    
    // İkincil renk — turkuaz/teal tonunda, modern ve ferah
    static let secondary = UIColor(red: 0.0, green: 0.78, blue: 0.75, alpha: 1.0)
    
    // Vurgu rengi — turuncu/amber tonunda, CTA butonları ve dikkat çekici öğeler için
    static let accent = UIColor(red: 1.0, green: 0.58, blue: 0.0, alpha: 1.0)
    
    // Arka plan rengi — dark mode uyumlu
    static let background = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.07, green: 0.07, blue: 0.12, alpha: 1.0)
            : UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1.0)
    }
    
    // Kart arka plan rengi — yarı saydam, glassmorphism efekti için
    static let cardBackground = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 0.95)
            : UIColor.white.withAlphaComponent(0.95)
    }
    
    // Metin renkleri
    static let textPrimary = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? .white : UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
    }
    
    static let textSecondary = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(white: 0.7, alpha: 1.0)
            : UIColor(white: 0.45, alpha: 1.0)
    }
    
    // Başarı, uyarı ve hata renkleri
    static let success = UIColor(red: 0.18, green: 0.8, blue: 0.44, alpha: 1.0)
    static let warning = UIColor(red: 1.0, green: 0.76, blue: 0.03, alpha: 1.0)
    static let error = UIColor(red: 0.91, green: 0.3, blue: 0.24, alpha: 1.0)
    
    // Gradient başlangıç ve bitiş renkleri — login arka planı için
    static let gradientStart = UIColor(red: 0.09, green: 0.09, blue: 0.32, alpha: 1.0)
    static let gradientEnd = UIColor(red: 0.16, green: 0.16, blue: 0.45, alpha: 1.0)
    
    // Tab bar seçili ve seçilmemiş renkleri
    static let tabBarSelected = secondary
    static let tabBarUnselected = UIColor(white: 0.6, alpha: 1.0)
    
    // Ayırıcı çizgi rengi
    static let separator = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(white: 0.2, alpha: 1.0)
            : UIColor(white: 0.88, alpha: 1.0)
    }
}

// MARK: - Uygulama Fontları
// Tüm fontları merkezi bir yerden yönetiyoruz.
// System font kullanıyoruz çünkü SF Pro iOS'ta varsayılan ve premium görünür.
// İleride custom font eklemek istersen sadece burayı değiştirmen yeterli.
enum AppFonts {
    
    static func bold(_ size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size, weight: .bold)
    }
    
    static func semibold(_ size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size, weight: .semibold)
    }
    
    static func medium(_ size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size, weight: .medium)
    }
    
    static func regular(_ size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size, weight: .regular)
    }
    
    static func light(_ size: CGFloat) -> UIFont {
        return .systemFont(ofSize: size, weight: .light)
    }
    
    // Özel başlık fontu — rounded tasarım
    static func rounded(_ size: CGFloat, weight: UIFont.Weight = .bold) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: size)
        }
        return systemFont
    }
    
    // Sık kullanılan font boyutları
    static let largeTitle = bold(34)
    static let title1 = bold(28)
    static let title2 = bold(22)
    static let title3 = semibold(20)
    static let headline = semibold(17)
    static let body = regular(17)
    static let callout = regular(16)
    static let subheadline = regular(15)
    static let footnote = regular(13)
    static let caption = regular(12)
}

// MARK: - Firestore Koleksiyon İsimleri
// Firestore'daki koleksiyon ve alan isimlerini sabit olarak tutuyoruz.
// Yazım hatası riskini ortadan kaldırır ve refactoring'i kolaylaştırır.
enum FirestoreKeys {
    
    enum Collections {
        static let users = "users"
        static let trips = "trips"
        static let preferences = "preferences"
        static let savedPlans = "savedPlans"
    }
    
    enum UserFields {
        static let displayName = "displayName"
        static let email = "email"
        static let photoURL = "photoURL"
        static let authProvider = "authProvider"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    }
    
    enum TripFields {
        static let userId = "userId"
        static let city = "city"
        static let days = "days"
        static let totalBudget = "totalBudget"
        static let selectedPlanIndex = "selectedPlanIndex"
        static let plans = "plans"
        static let createdAt = "createdAt"
        static let status = "status"
    }
}

// MARK: - Boyut Sabitleri
// Layout'ta kullanılan padding, margin, corner radius gibi değerleri
// merkezi tutuyoruz. Tutarlı bir görünüm sağlar.
enum AppLayout {
    static let defaultPadding: CGFloat = 16
    static let largePadding: CGFloat = 24
    static let smallPadding: CGFloat = 8
    static let cornerRadius: CGFloat = 12
    static let largeCornerRadius: CGFloat = 20
    static let buttonHeight: CGFloat = 52
    static let textFieldHeight: CGFloat = 50
    static let cardShadowRadius: CGFloat = 10
    static let cardShadowOpacity: Float = 0.12
    static let iconSize: CGFloat = 24
    static let avatarSize: CGFloat = 80
}

// MARK: - Animasyon Sabitleri
enum AppAnimation {
    static let defaultDuration: TimeInterval = 0.3
    static let longDuration: TimeInterval = 0.5
    static let springDamping: CGFloat = 0.8
    static let springVelocity: CGFloat = 0.5
}

// MARK: - Storyboard & Segue Tanımlayıcıları
// Storyboard ID'leri ve segue isimlerini burada tanımlıyoruz.
// Böylece yazım hataları derleme zamanında yakalanır.
enum StoryboardID {
    static let auth = "Auth"
    static let onboarding = "Onboarding"
    static let main = "Main"
    
    enum ViewControllers {
        static let login = "LoginVC"
        static let register = "RegisterVC"
        static let forgotPassword = "ForgotPasswordVC"
        static let onboardingContainer = "OnboardingContainerVC"
        static let mainTabBar = "MainTabBarVC"
        static let home = "HomeVC"
        static let myTrip = "MyTripVC"
        static let profile = "ProfileVC"
    }
    
    enum Segues {
        static let showRegister = "showRegister"
        static let showForgotPassword = "showForgotPassword"
        static let showOnboarding = "showOnboarding"
        static let showMain = "showMain"
    }
}

// MARK: - UserDefaults Anahtarları
enum UserDefaultsKeys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let lastSelectedCity = "lastSelectedCity"
    static let isDarkModeEnabled = "isDarkModeEnabled"
}

// MARK: - Uygulama Bilgileri
enum AppInfo {
    static let appName = "Ankara AI Trip Planner"
    static let appTagline = "Akıllı Seyahat Planınız"
    static let supportEmail = "destek@ankaraaitripplanner.com"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
}
