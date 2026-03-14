//
//  TripPlanCell.swift
//  AnkaraAITripPlanner
//

import UIKit

// Amaç: Alternatif tatil planlarını card tasarımında göstermek.
// Açıklama: TripAlternativesViewController içinde kullanılan ve 
// içerisine TripPlan modelini alıp verileri bağlayan UITableViewCell alt sınıfı.
final class TripPlanCell: UITableViewCell {
    
    static let identifier = "TripPlanCell"
    var onSelect: (() -> Void)?
    
    // Yüzey
    private lazy var containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.applyCardStyle(cornerRadius: AppLayout.largeCornerRadius)
        return v
    }()
    
    // Header (İkon ve Başlık)
    private lazy var iconContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.primary.withAlphaComponent(0.15)
        v.layer.cornerRadius = 20
        return v
    }()
    
    private lazy var typeIconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = AppColors.primary
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = AppFonts.bold(18)
        lbl.textColor = AppColors.textPrimary
        return lbl
    }()
    
    private lazy var scoreLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = AppFonts.bold(14)
        lbl.textColor = AppColors.success
        lbl.textAlignment = .right
        return lbl
    }()
    
    // İçerik (Açıklama)
    private lazy var descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = AppFonts.regular(14)
        lbl.textColor = AppColors.textSecondary
        lbl.numberOfLines = 2
        return lbl
    }()
    
    // Otel & Ulaşım Bilgisi (Yatay Stack)
    private lazy var infoStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 8
        sv.backgroundColor = AppColors.background.withAlphaComponent(0.5)
        sv.layer.cornerRadius = 12
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        return sv
    }()
    
    private lazy var hotelLabel = createInfoLabel(icon: "bed.double.fill")
    private lazy var transportLabel = createInfoLabel(icon: "airplane")
    
    // Fiyat ve Seç Butonu Kapsayıcısı
    private lazy var bottomStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.alignment = .center
        sv.distribution = .equalSpacing
        return sv
    }()
    
    private lazy var priceLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = AppFonts.bold(20)
        lbl.textColor = AppColors.textPrimary
        return lbl
    }()
    
    private lazy var selectButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.filled()
        config.title = "Bu Planı Seç"
        config.baseBackgroundColor = AppColors.secondary
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        btn.configuration = config
        btn.addTarget(self, action: #selector(handleSelectButton), for: .touchUpInside)
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        contentView.addSubview(containerView)
        
        containerView.addSubview(iconContainer)
        iconContainer.addSubview(typeIconView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(scoreLabel)
        containerView.addSubview(descriptionLabel)
        
        containerView.addSubview(infoStackView)
        infoStackView.addArrangedSubview(hotelLabel)
        infoStackView.addArrangedSubview(transportLabel)
        
        containerView.addSubview(bottomStackView)
        bottomStackView.addArrangedSubview(priceLabel)
        bottomStackView.addArrangedSubview(selectButton)
        
        let p: CGFloat = 16
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: AppLayout.defaultPadding),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -AppLayout.defaultPadding),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            iconContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: p),
            iconContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: p),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),
            
            typeIconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            typeIconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            typeIconView.widthAnchor.constraint(equalToConstant: 20),
            typeIconView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            
            scoreLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -p),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: scoreLabel.leadingAnchor, constant: -8),
            
            descriptionLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: p),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -p),
            
            infoStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 16),
            infoStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: p),
            infoStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -p),
            
            bottomStackView.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 20),
            bottomStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: p),
            bottomStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -p),
            bottomStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -p)
        ])
    }
    
    private func createInfoLabel(icon: String) -> UILabel {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = AppFonts.medium(13)
        lbl.textColor = AppColors.textPrimary
        
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: icon)?.withTintColor(AppColors.textSecondary)
        attachment.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)
        
        let attrString = NSMutableAttributedString(attachment: attachment)
        attrString.append(NSAttributedString(string: " -"))
        lbl.attributedText = attrString
        return lbl
    }
    
    func configure(with plan: TripPlan) {
        titleLabel.text = plan.title
        descriptionLabel.text = plan.description
        typeIconView.image = UIImage(systemName: plan.planType.iconName)
        scoreLabel.text = "%\(plan.fitScore) Eşleşme"
        
        transportLabel.text = " \(String(describing: plan.transportation))"
        let transportAttr = NSMutableAttributedString(string: transportLabel.text ?? "")
        let tIcon = NSTextAttachment()
        tIcon.image = UIImage(systemName: "tram.fill")?.withTintColor(AppColors.textSecondary)
        tIcon.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)
        let tFinal = NSMutableAttributedString(attachment: tIcon)
        tFinal.append(transportAttr)
        transportLabel.attributedText = tFinal
        
        let hotelAttr = NSMutableAttributedString(string: " \(plan.hotel.name)")
        let hIcon = NSTextAttachment()
        hIcon.image = UIImage(systemName: "bed.double.fill")?.withTintColor(AppColors.textSecondary)
        hIcon.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)
        let hFinal = NSMutableAttributedString(attachment: hIcon)
        hFinal.append(hotelAttr)
        hotelLabel.attributedText = hFinal
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.maximumFractionDigits = 0
        priceLabel.text = formatter.string(from: NSNumber(value: plan.totalEstimatedCost)) ?? "₺\(Int(plan.totalEstimatedCost))"
    }
    
    @objc private func handleSelectButton() {
        HapticManager.shared.lightImpact()
        onSelect?()
    }
}

