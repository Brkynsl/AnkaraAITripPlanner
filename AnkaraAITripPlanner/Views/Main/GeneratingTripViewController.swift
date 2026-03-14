//
//  GeneratingTripViewController.swift
//  AnkaraAITripPlanner
//

import UIKit
import Lottie

// Amaç: Yapay zeka plan oluştururken kullanıcıyı sıkmadan bekleten tam ekran animasyonlu yükleme sayfası.
// Açıklama: TripBuilderViewController'da "Oluştur"a basılınca bu sayfa açılır.
// Arkada `AITripPlannerService` çalışır. Cevap geldiğinde 3 alternatif planı
// gösterecek olan `TripAlternativesViewController` sayfasına yönlendirir.
final class GeneratingTripViewController: UIViewController {

    var city: String = ""
    var days: Int = 1
    var budget: Double = 0.0
    
    private lazy var animationView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.secondary
        v.layer.cornerRadius = 60
        v.layer.shadowColor = AppColors.secondary.cgColor
        v.layer.shadowRadius = 30
        v.layer.shadowOpacity = 0.6
        v.layer.shadowOffset = .zero
        
        // Inner gradient for depth
        let grad = CAGradientLayer()
        grad.colors = [UIColor.white.withAlphaComponent(0.3).cgColor, UIColor.clear.cgColor]
        grad.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        grad.cornerRadius = 60
        v.layer.addSublayer(grad)
        
        return v
    }()
    
    private lazy var iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "sparkles")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "AI Planınız Hazırlanıyor..."
        lbl.font = AppFonts.bold(22)
        lbl.textColor = AppColors.textPrimary
        lbl.textAlignment = .center
        return lbl
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "\(days) günlük \(city) seyahatiniz için en uygun rotalar,\nulaşım ve otel seçenekleri hesaplanıyor."
        lbl.font = AppFonts.regular(15)
        lbl.textColor = AppColors.textSecondary
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startAnimations()
        fetchPlans()
    }
    
    private func setupUI() {
        view.backgroundColor = AppColors.background
        
        view.addSubview(animationView)
        animationView.addSubview(iconImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            animationView.widthAnchor.constraint(equalToConstant: 120),
            animationView.heightAnchor.constraint(equalToConstant: 120),
            
            iconImageView.centerXAnchor.constraint(equalTo: animationView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: animationView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }
    
    private func startAnimations() {
        UIView.animate(withDuration: 1.0, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) {
            self.animationView.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }
    }
    
    private func fetchPlans() {
        AITripPlannerService.shared.generateTripPlans(city: city, days: days, budget: budget) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let plans):
                    if plans.isEmpty {
                        self.showErrorAlert(message: "Üzgünüz, kriterlerinize uygun plan oluşturulamadı.") {
                            self.dismiss(animated: true)
                        }
                    } else {
                        self.goToAlternatives(plans: plans)
                    }
                case .failure(let error):
                    self.showErrorAlert(message: "Hata: \(error.localizedDescription)") {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    private func goToAlternatives(plans: [TripPlan]) {
        // Önce üzerimizdeki bekleyen animasyonları veya olası sunumları temizle
        // En sağlıklı yöntem: Önce loading ekranını kapatıp, sonra ana sunucudan (presentingViewController) yenisini açmaktır.
        
        let presenter = self.presentingViewController
        
        self.dismiss(animated: true) {
            let alternativesVC = TripAlternativesViewController()
            alternativesVC.plans = plans
            alternativesVC.city = self.city
            alternativesVC.days = self.days
            alternativesVC.budget = self.budget
            
            let navVC = UINavigationController(rootViewController: alternativesVC)
            navVC.modalPresentationStyle = .fullScreen
            
            // Eğer presenter hala hayattaysa onun üzerinden aç
            if let presenter = presenter {
                presenter.present(navVC, animated: true)
            } else {
                // Fallback: Window root üzerinden aç
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.filter(\.isKeyWindow).first {
                    window.rootViewController?.present(navVC, animated: true)
                }
            }
        }
    }
}
