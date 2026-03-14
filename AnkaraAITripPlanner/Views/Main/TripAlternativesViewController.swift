//
//  TripAlternativesViewController.swift
//  AnkaraAITripPlanner
//

import UIKit

// Amaç: AI motorundan dönen 3 alternatif tatil planını kullanıcıya sunmak.
// Açıklama: Kullanıcı bu ekranda planlar arasında gezinir, birini "Seç" butonuna 
// basarak onaylar. Seçilen plan Firestore'a "Trip" modeli olarak kaydedilir ve
// kullanıcı Tatilim sayfasına yönlendirilir.
final class TripAlternativesViewController: UIViewController {

    // Dışarıdan enjekte edilecek veriler
    var city: String = ""
    var days: Int = 1
    var budget: Double = 0.0
    var plans: [TripPlan] = []
    
    // UI Bileşenleri
    private lazy var headerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.background
        return v
    }()
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Sizin İçin 3 Plan Çıkardık"
        lbl.font = AppFonts.bold(26)
        lbl.textColor = AppColors.textPrimary
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "\(city) rotanız için belirlediğiniz bütçeye özel optimize edilmiş alternatifler."
        lbl.font = AppFonts.regular(15)
        lbl.textColor = AppColors.textSecondary
        lbl.numberOfLines = 0
        return lbl
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 40, right: 0)
        tv.delegate = self
        tv.dataSource = self
        tv.register(TripPlanCell.self, forCellReuseIdentifier: TripPlanCell.identifier)
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        title = "Alternatifler"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "İptal", style: .plain, target: self, action: #selector(cancelTapped))
    }
    
    private func setupUI() {
        view.backgroundColor = AppColors.background
        
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        view.addSubview(tableView)
        
        let p = AppLayout.largePadding
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: p),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: p),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -p),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: p),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -p),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func cancelTapped() {
        // İptal ederse doğrudan kapat, ana ekrana dönsün
        dismiss(animated: true)
    }
    
    // MARK: - Plan Seçimi & Kayıt (Firestore)
    private func selectPlan(at index: Int) {
        let selectedPlan = plans[index]
        
        guard let userId = AuthService.shared.currentFirebaseUser?.uid else {
            showErrorAlert(message: "Lütfen önce giriş yapın.")
            return
        }
        
        // Yeni bir Trip nesnesi oluşturuluyor
        let newTrip = Trip(
            id: nil,
            userId: userId,
            city: city,
            days: days,
            totalBudget: budget,
            plans: plans,
            selectedPlanIndex: index,
            status: .planned,
            createdAt: Date(),
            updatedAt: nil
        )
        
        // Firestore'a kaydet (Animasyonlu bekleme ekranı eklenebilir)
        FirestoreService.shared.saveTrip(newTrip) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let docId):
                print("Plan başarıyla kaydedildi, ID: \(docId)")
                // Başarılı! 
                self.dismiss(animated: true) {
                    // Ana Tab Bar'ı bul ve 'Tatilim' (index 1) sekmesine geçir.
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.filter(\.isKeyWindow).first,
                       let tabBarController = window.rootViewController as? UITabBarController {
                        tabBarController.selectedIndex = 1
                    }
                }
            case .failure(let error):
                self.showErrorAlert(message: "Plan kaydedilemedi: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - UITableViewDelegate & DataSource
extension TripAlternativesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TripPlanCell.identifier, for: indexPath) as? TripPlanCell else {
            return UITableViewCell()
        }
        let plan = plans[indexPath.row]
        cell.configure(with: plan)
        
        // Seçme butonu tıklandığında closure dönecek
        cell.onSelect = { [weak self] in
            self?.selectPlan(at: indexPath.row)
        }
        return cell
    }
}
