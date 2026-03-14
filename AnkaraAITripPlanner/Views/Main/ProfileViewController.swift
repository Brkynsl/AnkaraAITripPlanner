// MARK: - ProfileViewController.swift
// Amaç: Kullanıcı profili ve tercihler ekranı.
// Açıklama: Kullanıcının hesap bilgilerini, seyahat tercihlerini ve
//           uygulama ayarlarını görüntüleyip düzenleyebildiği ekran.
//           Profil fotoğrafı, isim, favori ulaşım türleri, yemek tercihleri,
//           ve çıkış yap özelliği içerir. Aşama 2'de tercih düzenleme
//           detay sayfaları eklenecektir.
//
// STORYBOARD BAĞLANTISI:
//   Storyboard ID: "ProfileVC"
//   Class: ProfileViewController

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - UI Bileşenleri
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private lazy var contentStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .fill
        return sv
    }()
    
    // Profil kartı — kullanıcı bilgileri
    private lazy var profileCardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.applyCardStyle(cornerRadius: AppLayout.largeCornerRadius)
        return v
    }()
    
    // Profil ikonu
    private lazy var avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.tintColor = AppColors.secondary
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .light)
        iv.image = UIImage(systemName: "person.circle.fill", withConfiguration: config)
        iv.backgroundColor = AppColors.secondary.withAlphaComponent(0.1)
        iv.layer.cornerRadius = 35
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.semibold(20)
        label.textColor = AppColors.textPrimary
        label.text = "Kullanıcı"
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.regular(14)
        label.textColor = AppColors.textSecondary
        label.text = ""
        return label
    }()
    
    // Çıkış Yap butonu
    private lazy var logoutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("  Çıkış Yap", for: .normal)
        btn.titleLabel?.font = AppFonts.semibold(16)
        btn.setTitleColor(AppColors.error, for: .normal)
        btn.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
        btn.tintColor = AppColors.error
        btn.backgroundColor = AppColors.error.withAlphaComponent(0.1)
        btn.roundCorners(radius: AppLayout.cornerRadius)
        btn.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Yaşam Döngüsü
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadUserProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserProfile()
    }
    
    // MARK: - Navigation Bar
    private func setupNavigationBar() {
        title = "Profilim"
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
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        // Profil kartı oluştur
        setupProfileCard()
        
        // Menü bölümleri oluştur
        let preferencesSection = createMenuSection(title: "Tercihler", items: [
            ("airplane", "Ulaşım Tercihleri", AppColors.secondary),
            ("fork.knife", "Yemek Tercihleri", AppColors.accent),
            ("star.fill", "İlgi Alanları", UIColor(hex: "#AF52DE")),
            ("wallet.pass.fill", "Bütçe Davranışı", AppColors.success)
        ])
        
        let settingsSection = createMenuSection(title: "Ayarlar", items: [
            ("moon.fill", "Karanlık Mod", AppColors.primary),
            ("globe", "Dil", AppColors.textSecondary),
            ("bell.fill", "Bildirimler", UIColor(hex: "#FF9500")),
            ("shield.fill", "Gizlilik", UIColor(hex: "#34C759"))
        ])
        
        let infoSection = createMenuSection(title: "Hakkında", items: [
            ("info.circle.fill", "Uygulama Hakkında", AppColors.secondary),
            ("envelope.fill", "Destek", AppColors.accent),
            ("star.bubble.fill", "Değerlendir", UIColor(hex: "#FF2D55"))
        ])
        
        contentStackView.addArrangedSubview(profileCardView)
        contentStackView.addArrangedSubview(preferencesSection)
        contentStackView.addArrangedSubview(settingsSection)
        contentStackView.addArrangedSubview(infoSection)
        contentStackView.addArrangedSubview(logoutButton)
        
        // Logout buton yüksekliği
        logoutButton.heightAnchor.constraint(equalToConstant: AppLayout.buttonHeight).isActive = true
        
        // Altta boşluk
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 32).isActive = true
        contentStackView.addArrangedSubview(spacer)
        
        let padding = AppLayout.defaultPadding
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: padding),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: padding),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -padding),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -(padding * 2))
        ])
    }
    
    // MARK: - Profil Kartı Düzeni
    private func setupProfileCard() {
        profileCardView.addSubview(avatarImageView)
        profileCardView.addSubview(nameLabel)
        profileCardView.addSubview(emailLabel)
        
        let padding = AppLayout.largePadding
        
        NSLayoutConstraint.activate([
            profileCardView.heightAnchor.constraint(equalToConstant: 110),
            
            avatarImageView.leadingAnchor.constraint(equalTo: profileCardView.leadingAnchor, constant: padding),
            avatarImageView.centerYAnchor.constraint(equalTo: profileCardView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: profileCardView.trailingAnchor, constant: -padding),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor, constant: 10),
            
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4)
        ])
    }
    
    // MARK: - Menü Bölümü Oluşturma
    private func createMenuSection(title: String, items: [(icon: String, title: String, color: UIColor)]) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.applyCardStyle(cornerRadius: AppLayout.cornerRadius)
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        
        // Bölüm başlığı
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = AppFonts.semibold(13)
        titleLabel.textColor = AppColors.textSecondary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(stackView)
        
        for (index, item) in items.enumerated() {
            let row = createMenuRow(icon: item.icon, title: item.title, color: item.color) { [weak self] in
                self?.handleMenuTap(title: item.title)
            }
            stackView.addArrangedSubview(row)
            
            // Son satır hariç ayırıcı ekle
            if index < items.count - 1 {
                let separator = UIView()
                separator.translatesAutoresizingMaskIntoConstraints = false
                separator.backgroundColor = AppColors.separator
                separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                
                let separatorContainer = UIView()
                separatorContainer.translatesAutoresizingMaskIntoConstraints = false
                separatorContainer.addSubview(separator)
                NSLayoutConstraint.activate([
                    separator.leadingAnchor.constraint(equalTo: separatorContainer.leadingAnchor, constant: 52),
                    separator.trailingAnchor.constraint(equalTo: separatorContainer.trailingAnchor),
                    separator.topAnchor.constraint(equalTo: separatorContainer.topAnchor),
                    separator.bottomAnchor.constraint(equalTo: separatorContainer.bottomAnchor)
                ])
                
                stackView.addArrangedSubview(separatorContainer)
            }
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8)
        ])
        
        return container
    }
    
    // MARK: - Menü Satırı Oluşturma
    private func createMenuRow(icon: String, title: String, color: UIColor, action: (() -> Void)? = nil) -> UIView {
        let row = CustomTapView()
        row.onTap = action
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        let iconBg = UIView()
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        iconBg.backgroundColor = color.withAlphaComponent(0.12)
        iconBg.layer.cornerRadius = 8
        
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = AppFonts.regular(16)
        label.textColor = AppColors.textPrimary
        
        let chevron = UIImageView()
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.image = UIImage(systemName: "chevron.right")
        chevron.tintColor = AppColors.textSecondary.withAlphaComponent(0.5)
        chevron.contentMode = .scaleAspectFit
        
        row.addSubview(iconBg)
        iconBg.addSubview(iconView)
        row.addSubview(label)
        row.addSubview(chevron)
        
        NSLayoutConstraint.activate([
            iconBg.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            iconBg.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: 30),
            iconBg.heightAnchor.constraint(equalToConstant: 30),
            
            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),
            
            label.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            
            chevron.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        return row
    }
    
    // MARK: - Kullanıcı Profilini Yükleme
    private func loadUserProfile() {
        if let user = AuthService.shared.currentFirebaseUser {
            nameLabel.text = user.displayName ?? "Kullanıcı"
            emailLabel.text = user.email ?? ""
        }
    }
    
    // MARK: - Aksiyonlar
    
    @objc private func logoutTapped() {
        HapticManager.shared.buttonTap()
        
        showConfirmationAlert(
            title: "Çıkış Yap",
            message: "Hesabınızdan çıkış yapmak istediğinize emin misiniz?",
            confirmTitle: "Çıkış Yap"
        ) { [weak self] in
            do {
                try AuthService.shared.signOut()
                
                // Root ViewController'ı resetleyerek Login ekranına dön (daha güvenli ve temiz)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.filter(\.isKeyWindow).first {
                    
                    let loginVC = LoginViewController()
                    let navVC = UINavigationController(rootViewController: loginVC)
                    
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        window.rootViewController = navVC
                    }, completion: nil)
                }
            } catch {
                self?.showErrorAlert(message: "Çıkış yapılırken hata oluştu: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleMenuTap(title: String) {
        HapticManager.shared.lightImpact()
        if title.contains("Tercihler") || title.contains("Bütçe") {
            let prefVC = PreferencesViewController()
            navigationController?.pushViewController(prefVC, animated: true)
        } else {
            showSuccessAlert(title: "Bilgi", message: "\(title) özelliği yakında eklenecek.")
        }
    }
}

// MARK: - CustomTapView
final class CustomTapView: UIView {
    var onTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func tapped() {
        onTap?()
    }
}
