// MARK: - HomeViewController.swift
// Amaç: Uygulamanın ana sayfası — trip oluşturma akışının başladığı ekran.
// Açıklama: Kullanıcının şehir seçmesi, gün sayısı ve bütçe girmesi için
//           modern ve akıcı bir arayüz sunar. Aşama 2'de bu ekran
//           şehir seçimi, bütçe girişi ve AI plan oluşturma akışıyla
//           tamamen doldurulacaktır. Şu an temel yapı kurulmuştur.
//
// STORYBOARD BAĞLANTISI:
//   Storyboard ID: "HomeVC"
//   Class: HomeViewController

import UIKit

final class HomeViewController: UIViewController {
    
    // MARK: - UI Bileşenleri
    
    // Hoşgeldin kartı — kullanıcıya kişiselleştirilmiş mesaj gösterir
    private lazy var welcomeCardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.cardBackground
        v.roundCorners(radius: AppLayout.largeCornerRadius)
        v.addBlurEffect(style: .systemThinMaterial)
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        return v
    }()
    
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Merhaba! 👋"
        label.font = AppFonts.rounded(24)
        label.textColor = AppColors.textPrimary
        return label
    }()
    
    private lazy var welcomeSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Yeni bir seyahat planlamaya ne dersin?"
        label.font = AppFonts.regular(15)
        label.textColor = AppColors.textSecondary
        label.numberOfLines = 0
        return label
    }()
    
    // Plan Oluştur butonu — ana CTA
    private lazy var createTripButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        var config = UIButton.Configuration.filled()
        config.title = "Yeni Plan Oluştur"
        config.subtitle = "AI destekli seyahat planınızı oluşturun"
        config.image = UIImage(systemName: "sparkles")
        config.imagePadding = 12
        config.titlePadding = 4
        config.baseForegroundColor = .white
        config.baseBackgroundColor = AppColors.secondary
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        
        btn.configuration = config
        btn.addTarget(self, action: #selector(createTripTapped), for: .touchUpInside)
        return btn
    }()
    
    // Özellik kartları scroll view
    private lazy var featuresScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()
    
    private lazy var featuresStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .fill
        return sv
    }()
    
    // Boş durum görünümü (henüz plan oluşturulmamışsa)
    private lazy var emptyStateImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = AppColors.textSecondary.withAlphaComponent(0.3)
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .ultraLight)
        iv.image = UIImage(systemName: "map", withConfiguration: config)
        return iv
    }()
    
    // MARK: - Yaşam Döngüsü
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        updateWelcomeMessage()
    }
    
    // MARK: - Navigation Bar
    private func setupNavigationBar() {
        title = "Ana Sayfa"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColors.background
        appearance.titleTextAttributes = [.foregroundColor: AppColors.textPrimary]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: AppColors.textPrimary,
            .font: AppFonts.rounded(34)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    // MARK: - UI Kurulumu
    private func setupUI() {
        view.backgroundColor = AppColors.background
        
        view.addSubview(welcomeCardView)
        welcomeCardView.addSubview(welcomeLabel)
        welcomeCardView.addSubview(welcomeSubtitleLabel)
        
        view.addSubview(createTripButton)
        view.addSubview(featuresScrollView)
        featuresScrollView.addSubview(featuresStackView)
        view.addSubview(emptyStateImageView)
        
        // Özellik kartları oluştur
        createFeatureCards()
        
        let padding = AppLayout.defaultPadding
        let largePadding = AppLayout.largePadding
        
        NSLayoutConstraint.activate([
            welcomeCardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: padding),
            welcomeCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            welcomeCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            welcomeLabel.topAnchor.constraint(equalTo: welcomeCardView.topAnchor, constant: largePadding),
            welcomeLabel.leadingAnchor.constraint(equalTo: welcomeCardView.leadingAnchor, constant: largePadding),
            welcomeLabel.trailingAnchor.constraint(equalTo: welcomeCardView.trailingAnchor, constant: -largePadding),
            
            welcomeSubtitleLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 4),
            welcomeSubtitleLabel.leadingAnchor.constraint(equalTo: welcomeCardView.leadingAnchor, constant: largePadding),
            welcomeSubtitleLabel.trailingAnchor.constraint(equalTo: welcomeCardView.trailingAnchor, constant: -largePadding),
            welcomeSubtitleLabel.bottomAnchor.constraint(equalTo: welcomeCardView.bottomAnchor, constant: -largePadding),
            
            createTripButton.topAnchor.constraint(equalTo: welcomeCardView.bottomAnchor, constant: largePadding),
            createTripButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            createTripButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            createTripButton.heightAnchor.constraint(equalToConstant: 72),
            
            featuresScrollView.topAnchor.constraint(equalTo: createTripButton.bottomAnchor, constant: largePadding),
            featuresScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            featuresScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            featuresScrollView.heightAnchor.constraint(equalToConstant: 140),
            
            featuresStackView.topAnchor.constraint(equalTo: featuresScrollView.topAnchor),
            featuresStackView.leadingAnchor.constraint(equalTo: featuresScrollView.leadingAnchor, constant: padding),
            featuresStackView.trailingAnchor.constraint(equalTo: featuresScrollView.trailingAnchor, constant: -padding),
            featuresStackView.bottomAnchor.constraint(equalTo: featuresScrollView.bottomAnchor),
            featuresStackView.heightAnchor.constraint(equalTo: featuresScrollView.heightAnchor),
            
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.topAnchor.constraint(equalTo: featuresScrollView.bottomAnchor, constant: 40),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 120),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    // MARK: - Özellik Kartları
    // Yatay kaydırmalı küçük kartlar — uygulamanın özelliklerini tanıtır.
    private func createFeatureCards() {
        let features: [(icon: String, title: String, color: UIColor)] = [
            ("airplane", "Ulaşım", UIColor(hex: "#FF6B35")),
            ("bed.double.fill", "Konaklama", UIColor(hex: "#00B4D8")),
            ("fork.knife", "Yeme-İçme", UIColor(hex: "#2EC4B6")),
            ("building.columns.fill", "Müzeler", UIColor(hex: "#9B5DE5")),
            ("map.fill", "Rotalar", UIColor(hex: "#F15BB5"))
        ]
        
        for feature in features {
            let card = createFeatureCard(icon: feature.icon, title: feature.title, color: feature.color)
            featuresStackView.addArrangedSubview(card)
        }
    }
    
    private func createFeatureCard(icon: String, title: String, color: UIColor) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = color.withAlphaComponent(0.12)
        card.roundCorners(radius: AppLayout.cornerRadius)
        card.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .light)
        iconView.image = UIImage(systemName: icon, withConfiguration: config)
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = AppFonts.medium(13)
        label.textColor = AppColors.textPrimary
        label.textAlignment = .center
        
        card.addSubview(iconView)
        card.addSubview(label)
        
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: card.centerYAnchor, constant: -12),
            iconView.widthAnchor.constraint(equalToConstant: 36),
            iconView.heightAnchor.constraint(equalToConstant: 36),
            
            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: card.centerXAnchor)
        ])
        
        return card
    }
    
    // MARK: - Hoşgeldin Mesajı Güncelleme
    private func updateWelcomeMessage() {
        if let displayName = AuthService.shared.currentFirebaseUser?.displayName, !displayName.isEmpty {
            welcomeLabel.text = "Merhaba, \(displayName)! 👋"
        }
    }
    
    // MARK: - Aksiyonlar
    
    @objc private func createTripTapped() {
        HapticManager.shared.cardSelect()
        createTripButton.animateScale()
        
        let builderVC = TripBuilderViewController()
        navigationController?.pushViewController(builderVC, animated: true)
    }
}
