//
//  TripDetailViewController.swift
//  AnkaraAITripPlanner
//
//  Amaç: Seçilen seyahat planının tüm detaylarını kapsamlı bir guide olarak göstermek.

import UIKit

final class TripDetailViewController: UIViewController {

    var trip: Trip? {
        didSet { if isViewLoaded { setupData() } }
    }
    
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
        sv.spacing = 20
        sv.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 100, right: 16)
        sv.isLayoutMarginsRelativeArrangement = true
        return sv
    }()
    
    // Hero Header
    private lazy var headerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.primary.withAlphaComponent(0.15)
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        return v
    }()
    
    private lazy var headerIconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "airplane.departure")
        iv.tintColor = AppColors.primary
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = AppFonts.bold(26)
        lbl.textColor = AppColors.textPrimary
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = AppFonts.regular(15)
        lbl.textColor = AppColors.textSecondary
        lbl.numberOfLines = 0
        return lbl
    }()
    
    // Harita butonu (floating)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupData()
    }
    
    private func setupNavigationBar() {
        title = "Seyahat Detayı"
        navigationItem.largeTitleDisplayMode = .never
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = AppColors.background
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        view.addSubview(mapFloatingButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            mapFloatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            mapFloatingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mapFloatingButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Data Setup
    private func setupData() {
        guard let trip = trip, let plan = trip.selectedPlan else { return }
        
        // Mevcut içerikleri temizle
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 1. Hero Header
        contentStackView.addArrangedSubview(buildHeaderCard(trip: trip, plan: plan))
        
        // 2. Bütçe Dağılımı
        contentStackView.addArrangedSubview(buildBudgetCard(plan: plan))
        
        // 3. Ulaşım Kartı
        contentStackView.addArrangedSubview(buildTransportCard(plan: plan))
        
        // 4. Otel Kartı
        contentStackView.addArrangedSubview(buildHotelCard(plan: plan))
        
        // 5. Günlük Planlar
        let planTitle = UILabel()
        planTitle.font = AppFonts.bold(22)
        planTitle.textColor = AppColors.textPrimary
        planTitle.text = "📋 Günlük Program"
        contentStackView.addArrangedSubview(planTitle)
        
        for day in plan.dailyPlans {
            contentStackView.addArrangedSubview(buildDayCard(day: day))
        }
        
        // 6. Seyahat İpuçları
        contentStackView.addArrangedSubview(buildTipsCard(trip: trip))
    }
    
    // MARK: - Card Builders
    
    private func buildHeaderCard(trip: Trip, plan: TripPlan) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = AppColors.primary.withAlphaComponent(0.1)
        card.layer.cornerRadius = 20
        card.clipsToBounds = true
        
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = UIImage(systemName: "airplane.departure")
        icon.tintColor = AppColors.primary
        icon.contentMode = .scaleAspectFit
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "\(trip.city) Seyahati"
        title.font = AppFonts.bold(26)
        title.textColor = AppColors.textPrimary
        
        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = "\(trip.days) Gün • \(plan.title) • ₺\(Int(plan.totalEstimatedCost))"
        subtitle.font = AppFonts.medium(15)
        subtitle.textColor = AppColors.secondary
        
        let desc = UILabel()
        desc.translatesAutoresizingMaskIntoConstraints = false
        desc.text = plan.description
        desc.font = AppFonts.regular(14)
        desc.textColor = AppColors.textSecondary
        desc.numberOfLines = 0
        
        card.addSubview(icon)
        card.addSubview(title)
        card.addSubview(subtitle)
        card.addSubview(desc)
        
        NSLayoutConstraint.activate([
            icon.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            icon.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            icon.widthAnchor.constraint(equalToConstant: 40),
            icon.heightAnchor.constraint(equalToConstant: 40),
            
            title.centerYAnchor.constraint(equalTo: icon.centerYAnchor),
            title.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6),
            subtitle.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            subtitle.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            
            desc.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 8),
            desc.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            desc.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            desc.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
        
        return card
    }
    
    private func buildBudgetCard(plan: TripPlan) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle()
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "💰 Bütçe Dağılımı"
        title.font = AppFonts.bold(18)
        title.textColor = AppColors.textPrimary
        
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        
        let b = plan.budgetBreakdown
        let items: [(String, Double, UIColor)] = [
            ("✈️ Ulaşım", b.transportation, AppColors.primary),
            ("🏨 Konaklama", b.accommodation, AppColors.secondary),
            ("🍽️ Yemek", b.food, AppColors.accent),
            ("🎫 Aktiviteler", b.activities, UIColor(hex: "#AF52DE")),
            ("🚌 Yerel Ulaşım", b.localTransport, UIColor(hex: "#FF9500")),
            ("📦 Diğer", b.miscellaneous, AppColors.textSecondary)
        ]
        
        let total = plan.totalEstimatedCost
        
        for (label, amount, color) in items {
            let row = buildBudgetRow(label: label, amount: amount, total: total, color: color)
            stack.addArrangedSubview(row)
        }
        
        // Toplam
        let totalRow = UIView()
        totalRow.translatesAutoresizingMaskIntoConstraints = false
        let sep = UIView()
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.backgroundColor = AppColors.separator
        sep.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        let totalLabel = UILabel()
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        totalLabel.text = "TOPLAM: ₺\(Int(total))"
        totalLabel.font = AppFonts.bold(16)
        totalLabel.textColor = AppColors.primary
        totalLabel.textAlignment = .right
        
        stack.addArrangedSubview(sep)
        stack.addArrangedSubview(totalLabel)
        
        card.addSubview(title)
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            
            stack.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        
        return card
    }
    
    private func buildBudgetRow(label: String, amount: Double, total: Double, color: UIColor) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = label
        lbl.font = AppFonts.regular(14)
        lbl.textColor = AppColors.textPrimary
        
        let amountLbl = UILabel()
        amountLbl.translatesAutoresizingMaskIntoConstraints = false
        amountLbl.text = "₺\(Int(amount))"
        amountLbl.font = AppFonts.semibold(14)
        amountLbl.textColor = AppColors.textPrimary
        amountLbl.textAlignment = .right
        
        // Yüzde bar
        let barBg = UIView()
        barBg.translatesAutoresizingMaskIntoConstraints = false
        barBg.backgroundColor = color.withAlphaComponent(0.15)
        barBg.layer.cornerRadius = 3
        
        let barFill = UIView()
        barFill.translatesAutoresizingMaskIntoConstraints = false
        barFill.backgroundColor = color
        barFill.layer.cornerRadius = 3
        
        row.addSubview(lbl)
        row.addSubview(barBg)
        barBg.addSubview(barFill)
        row.addSubview(amountLbl)
        
        let percentage = total > 0 ? CGFloat(amount / total) : 0
        
        NSLayoutConstraint.activate([
            lbl.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            lbl.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            lbl.widthAnchor.constraint(equalToConstant: 120),
            
            barBg.leadingAnchor.constraint(equalTo: lbl.trailingAnchor, constant: 8),
            barBg.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            barBg.heightAnchor.constraint(equalToConstant: 6),
            barBg.trailingAnchor.constraint(equalTo: amountLbl.leadingAnchor, constant: -8),
            
            barFill.leadingAnchor.constraint(equalTo: barBg.leadingAnchor),
            barFill.topAnchor.constraint(equalTo: barBg.topAnchor),
            barFill.bottomAnchor.constraint(equalTo: barBg.bottomAnchor),
            barFill.widthAnchor.constraint(equalTo: barBg.widthAnchor, multiplier: min(percentage, 1.0)),
            
            amountLbl.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            amountLbl.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            amountLbl.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        return row
    }
    
    private func buildTransportCard(plan: TripPlan) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle()
        
        let t = plan.transportation
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "✈️ Ulaşım"
        title.font = AppFonts.bold(18)
        title.textColor = AppColors.textPrimary
        
        let details = UILabel()
        details.translatesAutoresizingMaskIntoConstraints = false
        details.numberOfLines = 0
        details.font = AppFonts.regular(14)
        details.textColor = AppColors.textSecondary
        details.text = """
        \(t.type.displayName) • \(t.provider)
        🛫 Kalkış: \(t.departureCity) → \(t.arrivalCity)
        ⏰ \(t.departureTime) - \(t.arrivalTime) (\(t.duration))
        💺 Sınıf: \(t.classType)
        💰 Gidiş: ₺\(Int(t.price)) • Dönüş: ₺\(Int(t.returnPrice ?? t.price))
        """
        
        card.addSubview(title)
        card.addSubview(details)
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            
            details.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            details.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            details.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            details.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        
        return card
    }
    
    private func buildHotelCard(plan: TripPlan) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle()
        
        let h = plan.hotel
        let stars = String(repeating: "⭐", count: h.starRating)
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "🏨 Konaklama"
        title.font = AppFonts.bold(18)
        title.textColor = AppColors.textPrimary
        
        let details = UILabel()
        details.translatesAutoresizingMaskIntoConstraints = false
        details.numberOfLines = 0
        details.font = AppFonts.regular(14)
        details.textColor = AppColors.textSecondary
        details.text = """
        \(h.name) \(stars)
        📍 \(h.address) (\(h.distanceToCenter) merkeze)
        💰 Gecelik: ₺\(Int(h.pricePerNight)) • Toplam: ₺\(Int(h.totalPrice))
        📊 Puan: \(h.rating)/10 (\(h.reviewCount) değerlendirme)
        🕐 Giriş: \(h.checkIn) • Çıkış: \(h.checkOut)
        🏷️ \(h.amenities.joined(separator: " • "))
        """
        
        card.addSubview(title)
        card.addSubview(details)
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            
            details.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            details.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            details.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            details.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        
        return card
    }
    
    private func buildDayCard(day: DayPlan) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle()
        
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0
        
        // Gün başlığı
        let titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = day.title
        titleLabel.font = AppFonts.bold(18)
        titleLabel.textColor = AppColors.primary
        
        let costLabel = UILabel()
        costLabel.translatesAutoresizingMaskIntoConstraints = false
        costLabel.text = "₺\(Int(day.estimatedCost))"
        costLabel.font = AppFonts.semibold(14)
        costLabel.textColor = AppColors.secondary
        costLabel.textAlignment = .right
        
        let distLabel = UILabel()
        distLabel.translatesAutoresizingMaskIntoConstraints = false
        distLabel.text = day.totalDistance ?? ""
        distLabel.font = AppFonts.regular(12)
        distLabel.textColor = AppColors.textSecondary
        distLabel.textAlignment = .right
        
        titleView.addSubview(titleLabel)
        titleView.addSubview(costLabel)
        titleView.addSubview(distLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -8),
            
            costLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 16),
            costLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -16),
            
            distLabel.topAnchor.constraint(equalTo: costLabel.bottomAnchor, constant: 2),
            distLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -16)
        ])
        
        stack.addArrangedSubview(titleView)
        
        // Aktivite satırları
        for (index, activity) in day.activities.enumerated() {
            let activityView = buildActivityRow(activity: activity, index: index + 1)
            stack.addArrangedSubview(activityView)
        }
        
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8)
        ])
        
        return card
    }
    
    private func buildActivityRow(activity: PlannedActivity, index: Int) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        
        // Timeline nokta
        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = AppColors.secondary
        dot.layer.cornerRadius = 12
        
        let numLabel = UILabel()
        numLabel.translatesAutoresizingMaskIntoConstraints = false
        numLabel.text = "\(index)"
        numLabel.font = AppFonts.bold(11)
        numLabel.textColor = .white
        numLabel.textAlignment = .center
        dot.addSubview(numLabel)
        
        // İsim ve saat
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = AppFonts.semibold(15)
        nameLabel.textColor = AppColors.textPrimary
        nameLabel.text = activity.name
        
        let timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = AppFonts.medium(12)
        timeLabel.textColor = AppColors.secondary
        timeLabel.text = "🕐 \(activity.startTime) - \(activity.endTime)"
        
        // Açıklama
        let descLabel = UILabel()
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.font = AppFonts.regular(13)
        descLabel.textColor = AppColors.textSecondary
        descLabel.numberOfLines = 2
        descLabel.text = activity.description
        
        // Detay badges (entry fee, transport, etc.)
        let badgeStack = UIStackView()
        badgeStack.translatesAutoresizingMaskIntoConstraints = false
        badgeStack.axis = .horizontal
        badgeStack.spacing = 8
        badgeStack.alignment = .leading
        
        if let fee = activity.entryFee {
            let badge = createBadge(text: fee > 0 ? "💰 ₺\(Int(fee))" : "🆓 Ücretsiz", color: fee > 0 ? AppColors.accent : AppColors.success)
            badgeStack.addArrangedSubview(badge)
        }
        
        if let hours = activity.openingHours {
            let badge = createBadge(text: "🕐 \(hours)", color: AppColors.primary)
            badgeStack.addArrangedSubview(badge)
        }
        
        // Ulaşım bilgisi
        let transportLabel = UILabel()
        transportLabel.translatesAutoresizingMaskIntoConstraints = false
        transportLabel.font = AppFonts.regular(12)
        transportLabel.textColor = AppColors.textSecondary
        transportLabel.numberOfLines = 0
        
        var transportText = ""
        if let info = activity.transportInfo {
            transportText += "🚇 \(info)"
        }
        if let tips = activity.tips {
            transportText += transportText.isEmpty ? "" : "\n"
            transportText += "💡 \(tips)"
        }
        transportLabel.text = transportText
        
        row.addSubview(dot)
        row.addSubview(nameLabel)
        row.addSubview(timeLabel)
        row.addSubview(descLabel)
        row.addSubview(badgeStack)
        row.addSubview(transportLabel)
        
        NSLayoutConstraint.activate([
            dot.topAnchor.constraint(equalTo: row.topAnchor, constant: 8),
            dot.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            dot.widthAnchor.constraint(equalToConstant: 24),
            dot.heightAnchor.constraint(equalToConstant: 24),
            
            numLabel.centerXAnchor.constraint(equalTo: dot.centerXAnchor),
            numLabel.centerYAnchor.constraint(equalTo: dot.centerYAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: row.topAnchor, constant: 6),
            nameLabel.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -8),
            
            timeLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            
            descLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            descLabel.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 12),
            descLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            
            badgeStack.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 6),
            badgeStack.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 12),
            badgeStack.trailingAnchor.constraint(lessThanOrEqualTo: row.trailingAnchor, constant: -16),
            
            transportLabel.topAnchor.constraint(equalTo: badgeStack.bottomAnchor, constant: 4),
            transportLabel.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 12),
            transportLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            transportLabel.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -12)
        ])
        
        return row
    }
    
    private func createBadge(text: String, color: UIColor) -> UIView {
        let badge = UILabel()
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.text = " \(text) "
        badge.font = AppFonts.medium(11)
        badge.textColor = color
        badge.backgroundColor = color.withAlphaComponent(0.12)
        badge.layer.cornerRadius = 8
        badge.clipsToBounds = true
        badge.heightAnchor.constraint(equalToConstant: 22).isActive = true
        return badge
    }
    
    private func buildTipsCard(trip: Trip) -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle()
        card.backgroundColor = AppColors.secondary.withAlphaComponent(0.1)
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "💡 Seyahat İpuçları"
        title.font = AppFonts.bold(18)
        title.textColor = AppColors.textPrimary
        
        let tips = UILabel()
        tips.translatesAutoresizingMaskIntoConstraints = false
        tips.numberOfLines = 0
        tips.font = AppFonts.regular(14)
        tips.textColor = AppColors.textSecondary
        tips.text = """
        • Müzekart ile birçok müzeye ücretsiz giriş yapabilirsiniz
        • Yerel ulaşım için AnkaraKart veya İstanbulKart alın
        • Sabah erken saatlerde turistik yerleri ziyaret edin
        • Restoran tavsiyeleri için yerel halktan öneriler isteyin
        • Su şişesi yanınızda bulundurun — özellikle yaz aylarında
        • Harita üzerindeki rota sırasını takip ederek zaman kazanın
        """
        
        card.addSubview(title)
        card.addSubview(tips)
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            
            tips.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            tips.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            tips.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            tips.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        
        return card
    }
    
    // MARK: - Actions
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
