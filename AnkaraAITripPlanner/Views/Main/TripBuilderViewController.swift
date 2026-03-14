//
//  TripBuilderViewController.swift
//  AnkaraAITripPlanner
//

import UIKit

// Amaç: Kullanıcıdan şehir, gün sayısı ve bütçe bilgilerini alarak AI motoruna iletmek.
// Açıklama: Bu ekran, adım adım bir form yapısına sahiptir. Girişleri doğrular ve
// animasyonlu bir "Yükleniyor" durumundayken arka planda AITripPlannerService'i çağırır.
final class TripBuilderViewController: UIViewController {

    // MARK: - Özellikler
    private let cityOptions = ["Ankara", "İstanbul", "İzmir", "Antalya", "Nevşehir (Kapadokya)", "Muğla (Bodrum)"]
    private var selectedCity: String = "Ankara"
    private var selectedDays: Int = 3
    private var selectedBudget: Double = 15000.0

    // MARK: - UI Bileşenleri
    
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
    
    // 1. Şehir Seçimi
    private lazy var cityLabel: UILabel = createTitleLabel(text: "Nereye gitmek istersin?")
    private lazy var cityButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.tinted()
        config.title = selectedCity
        config.image = UIImage(systemName: "chevron.up.chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.baseBackgroundColor = AppColors.primary
        config.baseForegroundColor = AppColors.primary
        config.cornerStyle = .medium
        btn.configuration = config
        
        // Menü oluşturma
        let actions = cityOptions.map { city in
            UIAction(title: city) { [weak self] _ in
                self?.selectedCity = city
                btn.configuration?.title = city
            }
        }
        btn.menu = UIMenu(title: "Şehir Seç", children: actions)
        btn.showsMenuAsPrimaryAction = true
        return btn
    }()
    
    // 2. Gün Sayısı
    private lazy var daysLabel: UILabel = createTitleLabel(text: "Kaç gün kalacaksın?")
    private lazy var daysValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(selectedDays) Gün"
        label.font = AppFonts.bold(22)
        label.textColor = AppColors.primary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var daysStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.minimumValue = 1
        stepper.maximumValue = 14
        stepper.value = Double(selectedDays)
        stepper.addTarget(self, action: #selector(daysStepperChanged(_:)), for: .valueChanged)
        return stepper
    }()
    
    // 3. Bütçe
    private lazy var budgetLabel: UILabel = createTitleLabel(text: "Toplam Bütçen Ne Kadar?")
    private lazy var budgetValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = formatCurrency(selectedBudget)
        label.font = AppFonts.bold(28)
        label.textColor = AppColors.success
        label.textAlignment = .center
        return label
    }()
    
    private lazy var budgetSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 5000
        slider.maximumValue = 100000
        slider.value = Float(selectedBudget)
        slider.minimumTrackTintColor = AppColors.success
        slider.addTarget(self, action: #selector(budgetSliderChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    // Alt Kısım - Oluştur Butonu
    private lazy var createButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.filled()
        config.title = "AI Planımı Oluştur"
        config.image = UIImage(systemName: "wand.and.stars")
        config.imagePadding = 12
        config.baseBackgroundColor = AppColors.secondary
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        btn.configuration = config
        btn.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        
        // Premium Shadow
        btn.layer.shadowColor = AppColors.secondary.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowRadius = 8
        
        return btn
    }()

    // MARK: - Yaşam Döngüsü
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - UI Kurulumu
    private func setupNavigationBar() {
        title = "Seyahat Planla"
        view.backgroundColor = AppColors.background
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let elements = [
            cityLabel, cityButton,
            daysLabel, daysValueLabel, daysStepper,
            budgetLabel, budgetValueLabel, budgetSlider,
            createButton
        ]
        
        elements.forEach { contentView.addSubview($0) }
        
        let p = AppLayout.largePadding
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // 1. Şehir
            cityLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: p),
            cityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            cityLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            
            cityButton.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 12),
            cityButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            cityButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            cityButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 2. Gün
            daysLabel.topAnchor.constraint(equalTo: cityButton.bottomAnchor, constant: p + 10),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            daysLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            
            daysValueLabel.topAnchor.constraint(equalTo: daysLabel.bottomAnchor, constant: 16),
            daysValueLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            daysStepper.topAnchor.constraint(equalTo: daysValueLabel.bottomAnchor, constant: 16),
            daysStepper.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // 3. Bütçe
            budgetLabel.topAnchor.constraint(equalTo: daysStepper.bottomAnchor, constant: p + 10),
            budgetLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            budgetLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            
            budgetValueLabel.topAnchor.constraint(equalTo: budgetLabel.bottomAnchor, constant: 16),
            budgetValueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            budgetValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            
            budgetSlider.topAnchor.constraint(equalTo: budgetValueLabel.bottomAnchor, constant: 16),
            budgetSlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            budgetSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            
            // Buton
            createButton.topAnchor.constraint(equalTo: budgetSlider.bottomAnchor, constant: 50),
            createButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: p),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -p),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    private func createTitleLabel(text: String) -> UILabel {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = text
        lbl.font = AppFonts.semibold(18)
        lbl.textColor = AppColors.textPrimary
        return lbl
    }
    
    // MARK: - Aksiyonlar
    
    @objc private func daysStepperChanged(_ sender: UIStepper) {
        selectedDays = Int(sender.value)
        daysValueLabel.text = "\(selectedDays) Gün"
        HapticManager.shared.lightImpact()
    }
    
    @objc private func budgetSliderChanged(_ sender: UISlider) {
        // 500'ün katlarına yuvarla
        let rounded = round(sender.value / 500) * 500
        sender.value = rounded
        selectedBudget = Double(rounded)
        budgetValueLabel.text = formatCurrency(selectedBudget)
        HapticManager.shared.selectionChanged()
    }
    
    @objc private func createTapped() {
        HapticManager.shared.success()
        createButton.animateScale()
        
        // Modal olarak Yükleme Ekranı göster
        let loadingVC = GeneratingTripViewController()
        loadingVC.city = selectedCity
        loadingVC.days = selectedDays
        loadingVC.budget = selectedBudget
        loadingVC.modalPresentationStyle = .fullScreen
        loadingVC.modalTransitionStyle = .crossDissolve
        present(loadingVC, animated: true)
    }
    
    // MARK: - Yardımcılar
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "₺\(Int(value))"
    }
}
