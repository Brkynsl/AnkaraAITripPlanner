//
//  PreferencesViewController.swift
//  AnkaraAITripPlanner
//

import UIKit

// Amaç: Kullanıcının seyahat tercihlerini (ulaşım, konfor, yemek) ayarlamasını sağlamak.
// Açıklama: UISwitch ve UISegmentedControl gibi standart ve anlaşılır bileşenlerle 
// UserDefaults üzerine basit tercihler kaydedilir. AI Motoru bu tercihleri okuyarak
// daha kişiselleştirilmiş sonuçlar üretebilir.
final class PreferencesViewController: UIViewController {

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
    
    // Yemek Tercihleri
    private lazy var vegetarianSwitch = createSwitch(key: "pref_vegetarian")
    private lazy var halalSwitch = createSwitch(key: "pref_halal")
    
    // Konaklama Tipi
    private lazy var accommodationSegment: UISegmentedControl = {
        let items = ["Maliyet Odaklı", "Dengeli", "Konfor Odaklı"]
        let sc = UISegmentedControl(items: items)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "pref_accommodation")
        sc.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        return sc
    }()
    
    // Ulaşım Tercihi
    private lazy var transportSegment: UISegmentedControl = {
        let items = ["Toplu Taşıma", "Taksi / Araç", "Yürüyüş"]
        let sc = UISegmentedControl(items: items)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "pref_transport")
        sc.addTarget(self, action: #selector(transportChanged(_:)), for: .valueChanged)
        return sc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
    }
    
    private func setupNavigationBar() {
        title = "Tercihlerim"
        view.backgroundColor = AppColors.background
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Bölümler
        let foodSection = createSection(title: "Yemek Tercihleri", views: [
            createRow(title: "Vejetaryen / Vegan", control: vegetarianSwitch),
            createRow(title: "Sadece Helal Kesim", control: halalSwitch)
        ])
        
        let accommodationSection = createSection(title: "Otel & Konaklama", views: [
            createRow(title: "Öncelik", control: accommodationSegment)
        ])
        
        let transportSection = createSection(title: "Şehir İçi Ulaşım", views: [
            createRow(title: "Öncelik", control: transportSegment)
        ])
        
        // Kaydedildi Bilgisi
        let infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.text = "Tercihleriniz otomatik olarak kaydedilir ve AI Motorumuz bir sonraki planlamanızda bu ayarları dikkate alır."
        infoLabel.font = AppFonts.regular(13)
        infoLabel.textColor = AppColors.textSecondary
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        
        contentView.addSubview(foodSection)
        contentView.addSubview(accommodationSection)
        contentView.addSubview(transportSection)
        contentView.addSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            foodSection.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            foodSection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            foodSection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            accommodationSection.topAnchor.constraint(equalTo: foodSection.bottomAnchor, constant: 32),
            accommodationSection.leadingAnchor.constraint(equalTo: foodSection.leadingAnchor),
            accommodationSection.trailingAnchor.constraint(equalTo: foodSection.trailingAnchor),
            
            transportSection.topAnchor.constraint(equalTo: accommodationSection.bottomAnchor, constant: 32),
            transportSection.leadingAnchor.constraint(equalTo: foodSection.leadingAnchor),
            transportSection.trailingAnchor.constraint(equalTo: foodSection.trailingAnchor),
            
            infoLabel.topAnchor.constraint(equalTo: transportSection.bottomAnchor, constant: 40),
            infoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            infoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            infoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - Yardımcı Fonksiyonlar
    private func createSwitch(key: String) -> UISwitch {
        let s = UISwitch()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.isOn = UserDefaults.standard.bool(forKey: key)
        s.onTintColor = AppColors.success
        // Action ekliyoruz (Örn: tag 1,2.. verip tek fonksiyonda toplayabiliriz ama action closure yapalım)
        s.addAction(UIAction(handler: { _ in
            UserDefaults.standard.set(s.isOn, forKey: key)
            HapticManager.shared.lightImpact()
        }), for: .valueChanged)
        return s
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "pref_accommodation")
        HapticManager.shared.selectionChanged()
    }
    
    @objc private func transportChanged(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "pref_transport")
        HapticManager.shared.selectionChanged()
    }
    
    private func createSection(title: String, views: [UIView]) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title.uppercased()
        titleLabel.font = AppFonts.semibold(13)
        titleLabel.textColor = AppColors.textSecondary
        
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = AppColors.background
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = AppColors.textSecondary.withAlphaComponent(0.2).cgColor
        
        let stack = UIStackView(arrangedSubviews: views)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 20
        
        container.addSubview(titleLabel)
        container.addSubview(card)
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            card.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            card.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    private func createRow(title: String, control: UIView) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = title
        lbl.font = AppFonts.medium(16)
        lbl.textColor = AppColors.textPrimary
        
        row.addSubview(lbl)
        row.addSubview(control)
        
        // Switch mi yoksa Segmented Control mü kontrol et (Segmented alt alta, Switch yanyana)
        if control is UISwitch {
            NSLayoutConstraint.activate([
                lbl.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                lbl.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                
                control.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                control.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                
                row.heightAnchor.constraint(equalToConstant: 40)
            ])
        } else {
            NSLayoutConstraint.activate([
                lbl.topAnchor.constraint(equalTo: row.topAnchor),
                lbl.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                
                control.topAnchor.constraint(equalTo: lbl.bottomAnchor, constant: 12),
                control.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                control.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                control.bottomAnchor.constraint(equalTo: row.bottomAnchor)
            ])
        }
        
        return row
    }
}
