//
//  TripDetailViewController.swift
//  AnkaraAITripPlanner
//

import UIKit

// Amaç: Kullanıcının seçtiği ve kaydettiği seyahat planının tüm detaylarını göstermek.
// Açıklama: Ulaşım, Otel, Günlük Planlar ve Harita kısayolunu içeren 
// kapsamlı, scroll edilebilir bir ekran.
final class TripDetailViewController: UIViewController {

    var trip: Trip? {
        didSet {
            // Veri set edildiğinde UI'ı güncelle
            setupData()
        }
    }
    
    // UI Bileşenleri
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private lazy var contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var headerImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = AppColors.primary.withAlphaComponent(0.2)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        // Gerçekte Unsplash benzeri API'den resim çekilir.
        iv.image = UIImage(systemName: "photo.artframe")
        iv.tintColor = AppColors.primary
        return iv
    }()
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = AppFonts.bold(28)
        lbl.textColor = AppColors.textPrimary
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = AppFonts.medium(16)
        lbl.textColor = AppColors.secondary
        return lbl
    }()
    
    // Yüzen Harita Butonu
    private lazy var mapFloatingButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.filled()
        config.title = "Haritada Gör"
        config.image = UIImage(systemName: "map.fill")
        config.imagePadding = 8
        config.baseBackgroundColor = AppColors.primary
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        btn.configuration = config
        btn.layer.shadowColor = AppColors.primary.cgColor
        btn.layer.shadowOpacity = 0.4
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius = 8
        btn.addTarget(self, action: #selector(openMap), for: .touchUpInside)
        return btn
    }()
    
    // Ulaşım ve Otel Kartları
    private lazy var transportCard = InfoCardView(title: "Ulaşım", icon: "airplane")
    private lazy var hotelCard = InfoCardView(title: "Konaklama", icon: "bed.double.fill")
    
    // Günlük Planlar Stack
    private lazy var daysStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 16
        return sv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        title = "Seyahat Detayı"
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupUI() {
        view.backgroundColor = AppColors.background
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(mapFloatingButton)
        
        contentView.addSubview(headerImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(transportCard)
        contentView.addSubview(hotelCard)
        
        let planTitleLabel = UILabel()
        planTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        planTitleLabel.text = "Günlük Plan"
        planTitleLabel.font = AppFonts.bold(22)
        planTitleLabel.textColor = AppColors.textPrimary
        contentView.addSubview(planTitleLabel)
        
        contentView.addSubview(daysStackView)
        
        let p: CGFloat = 16
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerImageView.heightAnchor.constraint(equalToConstant: 220),
            
            titleLabel.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            
            transportCard.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            transportCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            transportCard.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -8),
            
            hotelCard.topAnchor.constraint(equalTo: transportCard.topAnchor),
            hotelCard.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 8),
            hotelCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            
            planTitleLabel.topAnchor.constraint(equalTo: transportCard.bottomAnchor, constant: 32),
            planTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            
            daysStackView.topAnchor.constraint(equalTo: planTitleLabel.bottomAnchor, constant: 16),
            daysStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            daysStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            daysStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100), // Buton için boşluk
            
            mapFloatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            mapFloatingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mapFloatingButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupData() {
        guard let trip = trip, let plan = trip.selectedPlan else { return }
        
        titleLabel.text = "\(trip.city) Seyahati"
        subtitleLabel.text = "\(trip.days) Gün • \(plan.title)"
        
        transportCard.setValue("\(plan.transportation.provider)\n\(plan.transportation.departureTime)")
        hotelCard.setValue("\(plan.hotel.name)\nGece: ₺\(Int(plan.hotel.pricePerNight))")
        
        // Günleri oluştur
        daysStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for day in plan.dailyPlans {
            let dayView = DayPlanView()
            dayView.configure(with: day)
            daysStackView.addArrangedSubview(dayView)
        }
    }
    
    @objc private func openMap() {
        HapticManager.shared.lightImpact()
        guard let plan = trip?.selectedPlan else { return }
        
        let mapVC = TripMapViewController()
        mapVC.plan = plan
        mapVC.modalPresentationStyle = .fullScreen
        mapVC.modalTransitionStyle = .coverVertical
        present(mapVC, animated: true)
    }
}

// MARK: - InfoCardView
class InfoCardView: UIView {
    
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let iconView = UIImageView()
    
    init(title: String, icon: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AppColors.background
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = AppColors.textSecondary.withAlphaComponent(0.2).cgColor
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = AppFonts.medium(14)
        titleLabel.textColor = AppColors.textSecondary
        
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = AppFonts.semibold(14)
        valueLabel.textColor = AppColors.textPrimary
        valueLabel.numberOfLines = 2
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = AppColors.primary
        iconView.contentMode = .scaleAspectFit
        
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            
            valueLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setValue(_ value: String) {
        valueLabel.text = value
    }
}

// MARK: - DayPlanView
class DayPlanView: UIView {
    
    private let titleLabel = UILabel()
    private let contentStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AppColors.background
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = AppColors.textSecondary.withAlphaComponent(0.1).cgColor
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFonts.bold(18)
        titleLabel.textColor = AppColors.primary
        
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 10
        
        addSubview(titleLabel)
        addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            contentStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with day: DayPlan) {
        titleLabel.text = day.title
        
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for activity in day.activities {
            let activityLabel = UILabel()
            activityLabel.font = AppFonts.regular(14)
            activityLabel.textColor = AppColors.textPrimary
            activityLabel.numberOfLines = 0
            
            let boldAttr = [NSAttributedString.Key.font: AppFonts.bold(14)]
            let attrStr = NSMutableAttributedString(string: "\(activity.startTime) - ", attributes: boldAttr)
            attrStr.append(NSAttributedString(string: "\(activity.name)\n", attributes: boldAttr))
            attrStr.append(NSAttributedString(string: "\(activity.description)"))
            
            activityLabel.attributedText = attrStr
            contentStack.addArrangedSubview(activityLabel)
        }
    }
}
