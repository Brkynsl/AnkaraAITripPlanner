// MARK: - OnboardingPageCell.swift
// Amaç: Onboarding koleksiyon view'ındaki her bir sayfayı temsil eden hücre.
// Açıklama: Büyük bir ikon, başlık ve açıklama metni içerir.
//           Her sayfa uygulamanın bir özelliğini tanıtır.
//           Animate edilebilir yapıda tasarlandı — hücre görünür olduğunda
//           ikon ve metin yumuşak bir animasyonla belirir.

import UIKit

final class OnboardingPageCell: UICollectionViewCell {
    
    // MARK: - Tekrar Kullanım Kimliği
    static let reuseID = "OnboardingPageCell"
    
    // MARK: - UI Bileşenleri
    
    // Büyük ikon — SF Symbol ile oluşturulan ana görsel
    private lazy var iconContainerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.roundCorners(radius: 40)
        return v
    }()
    
    private lazy var iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = AppColors.secondary
        return iv
    }()
    
    // Sayfa başlığı
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.rounded(24)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // Açıklama metni
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.regular(16)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // Dekoratif daire — arka planda büyük yarı saydam daire
    private lazy var decorativeCircle: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.white.withAlphaComponent(0.03)
        v.layer.cornerRadius = 100
        return v
    }()
    
    // MARK: - Başlatma
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Kurulumu
    private func setupUI() {
        backgroundColor = .clear
        
        contentView.addSubview(decorativeCircle)
        contentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        let padding = AppLayout.largePadding
        
        NSLayoutConstraint.activate([
            // Dekoratif daire — merkezden hafif yukarıda
            decorativeCircle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            decorativeCircle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -80),
            decorativeCircle.widthAnchor.constraint(equalToConstant: 200),
            decorativeCircle.heightAnchor.constraint(equalToConstant: 200),
            
            // İkon container — ortada
            iconContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -100),
            iconContainerView.widthAnchor.constraint(equalToConstant: 120),
            iconContainerView.heightAnchor.constraint(equalToConstant: 120),
            
            // İkon — container içinde ortalanmış
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 56),
            iconImageView.heightAnchor.constraint(equalToConstant: 56),
            
            // Başlık
            titleLabel.topAnchor.constraint(equalTo: iconContainerView.bottomAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding + 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -(padding + 8)),
            
            // Açıklama
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding + 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -(padding + 8))
        ])
    }
    
    // MARK: - Hücre Yapılandırma
    // OnboardingPage modelinden verileri alarak UI'ı doldurur.
    func configure(with page: OnboardingPage) {
        titleLabel.text = page.title
        descriptionLabel.text = page.description
        
        let config = UIImage.SymbolConfiguration(pointSize: 48, weight: .light)
        iconImageView.image = UIImage(systemName: page.iconName, withConfiguration: config)
        
        // Her sayfaya özel vurgu rengi
        let accentColor = UIColor(hex: page.accentColor)
        iconImageView.tintColor = accentColor
        iconContainerView.backgroundColor = accentColor.withAlphaComponent(0.15)
    }
    
    // MARK: - Giriş Animasyonu
    // Hücre screen'e geldiğinde ikon ve metinler animasyonla belirir.
    override func prepareForReuse() {
        super.prepareForReuse()
        iconContainerView.transform = .identity
        titleLabel.alpha = 1
        descriptionLabel.alpha = 1
    }
}
