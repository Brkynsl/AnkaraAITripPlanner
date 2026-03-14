// MARK: - MyTripViewController.swift
// Amaç: Kullanıcının oluşturduğu seyahat planlarını listeleyen "Tatilim" sekmesi.
// Açıklama: Aktif ve geçmiş seyahat planlarını gösterir. Her plan için
//           özet kartı, bütçe dağılımı ve harita görünümü sunar.
//           Aşama 2'de detay sayfaları ve harita entegrasyonu eklenecek.
//
// STORYBOARD BAĞLANTISI:
//   Storyboard ID: "MyTripVC"
//   Class: MyTripViewController

import UIKit

final class MyTripViewController: UIViewController {
    
    // MARK: - Özellikler
    private var trips: [Trip] = [] {
        didSet {
            updateUI()
            tableView.reloadData()
        }
    }
    
    // MARK: - UI Bileşenleri
    
    // Boş durum görünümü — henüz plan oluşturulmamışsa gösterilir
    private lazy var emptyStateView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var emptyIconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = AppColors.textSecondary.withAlphaComponent(0.3)
        let config = UIImage.SymbolConfiguration(pointSize: 72, weight: .ultraLight)
        iv.image = UIImage(systemName: "suitcase", withConfiguration: config)
        return iv
    }()
    
    private lazy var emptyTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Henüz bir tatil planınız yok"
        label.font = AppFonts.semibold(18)
        label.textColor = AppColors.textPrimary
        label.textAlignment = .center
        return label
    }()
    
    private lazy var emptyDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ana sayfadan yeni bir seyahat planı oluşturduğunuzda planlarınız burada görünecek."
        label.font = AppFonts.regular(15)
        label.textColor = AppColors.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var createFirstTripButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("İlk Planımı Oluştur", for: .normal)
        btn.titleLabel?.font = AppFonts.semibold(16)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = AppColors.secondary
        btn.roundCorners(radius: AppLayout.cornerRadius)
        btn.addTarget(self, action: #selector(createFirstTripTapped), for: .touchUpInside)
        return btn
    }()
    
    // Trips List View
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        tv.delegate = self
        tv.dataSource = self
        tv.register(TripListCell.self, forCellReuseIdentifier: TripListCell.identifier)
        tv.isHidden = true
        return tv
    }()
    
    // MARK: - Yaşam Döngüsü
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTrips()
    }
    
    private func fetchTrips() {
        guard let userId = AuthService.shared.currentFirebaseUser?.uid else { return }
        FirestoreService.shared.getTrips(userId: userId) { [weak self] result in
            DispatchQueue.main.async { // UI güncellemeleri main thread'de olmalı
                switch result {
                case .success(let trips):
                    self?.trips = trips.sorted(by: { $0.createdAt > $1.createdAt })
                case .failure(let error):
                    print("Seyahatler yüklenirken hata oluştu: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func updateUI() {
        let isEmpty = trips.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    // MARK: - Navigation Bar
    private func setupNavigationBar() {
        title = "Tatilim"
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
        
        // Boş durum görünümü
        view.addSubview(emptyStateView)
        emptyStateView.addSubview(emptyIconView)
        emptyStateView.addSubview(emptyTitleLabel)
        emptyStateView.addSubview(emptyDescriptionLabel)
        emptyStateView.addSubview(createFirstTripButton)
        
        let padding = AppLayout.largePadding
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            emptyIconView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyIconView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyIconView.widthAnchor.constraint(equalToConstant: 100),
            emptyIconView.heightAnchor.constraint(equalToConstant: 100),
            
            emptyTitleLabel.topAnchor.constraint(equalTo: emptyIconView.bottomAnchor, constant: 24),
            emptyTitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyTitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            emptyDescriptionLabel.topAnchor.constraint(equalTo: emptyTitleLabel.bottomAnchor, constant: 8),
            emptyDescriptionLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyDescriptionLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            createFirstTripButton.topAnchor.constraint(equalTo: emptyDescriptionLabel.bottomAnchor, constant: 24),
            createFirstTripButton.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            createFirstTripButton.widthAnchor.constraint(equalToConstant: 200),
            createFirstTripButton.heightAnchor.constraint(equalToConstant: AppLayout.buttonHeight),
            createFirstTripButton.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Aksiyonlar
    @objc private func createFirstTripTapped() {
        HapticManager.shared.buttonTap()
        // Ana sayfa sekmesine geçiş
        tabBarController?.selectedIndex = 0
    }
}

// MARK: - UITableViewDelegate & DataSource
extension MyTripViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TripListCell.identifier, for: indexPath) as? TripListCell else {
            return UITableViewCell()
        }
        let trip = trips[indexPath.row]
        cell.configure(with: trip)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trip = trips[indexPath.row]
        let detailVC = TripDetailViewController()
        detailVC.trip = trip
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - TripListCell
final class TripListCell: UITableViewCell {
    static let identifier = "TripListCell"
    
    private lazy var containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.applyCardStyle()
        return v
    }()
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = AppFonts.bold(18)
        lbl.textColor = AppColors.textPrimary
        return lbl
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = AppFonts.regular(14)
        lbl.textColor = AppColors.textSecondary
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            subtitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with trip: Trip) {
        titleLabel.text = "\(trip.city) Seyahati"
        subtitleLabel.text = "\(trip.days) Gün • \(trip.selectedPlan?.title ?? "Plan")"
    }
}
