// MARK: - UIViewController+Alerts.swift
// Amaç: Tüm ViewController'larda ortak kullanılan alert, loading ve mesaj gösterme
//        işlemlerini tek bir yerden yönetmek.
// Açıklama: Her ekranda tekrar tekrar UIAlertController oluşturmak yerine,
//           bu extension sayesinde tek satırla hata mesajı, başarı bildirimi
//           veya loading göstergesi gösterebiliriz. Kod tekrarını %90 azaltır.

import UIKit

extension UIViewController {
    
    // MARK: - Hata Alert'i Gösterme
    // Kullanıcıya hata mesajı gösterir. Tamam butonu ile kapatılır.
    // Kullanım: showErrorAlert(message: "Şifreniz yanlış")
    func showErrorAlert(title: String = "Hata", message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    // MARK: - Başarı Alert'i Gösterme
    // İşlem başarılı olduğunda kullanıcıya bilgi verir.
    // Kullanım: showSuccessAlert(message: "Kayıt başarılı!")
    func showSuccessAlert(title: String = "Başarılı", message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    // MARK: - Onay Alert'i Gösterme (Evet/Hayır)
    // Kullanıcıdan onay gerektiren işlemler için (çıkış yap, sil vb.)
    func showConfirmationAlert(
        title: String,
        message: String,
        confirmTitle: String = "Evet",
        cancelTitle: String = "Vazgeç",
        onConfirm: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
        alert.addAction(UIAlertAction(title: confirmTitle, style: .destructive) { _ in
            onConfirm()
        })
        present(alert, animated: true)
    }
    
    // MARK: - Loading Göstergesi (Overlay)
    // Ekranın üstünde yarı saydam bir loading overlay gösterir.
    // API çağrıları sırasında kullanıcıya işlemin devam ettiğini bildirir.
    // Tag sistemi ile aynı overlay'in tekrar eklenmesini önler.
    
    private static let loadingViewTag = 999_888
    
    func showLoadingOverlay(message: String = "Yükleniyor...") {
        // Zaten varsa tekrar ekleme
        guard view.viewWithTag(UIViewController.loadingViewTag) == nil else { return }
        
        // Yarı saydam arka plan
        let overlayView = UIView()
        overlayView.tag = UIViewController.loadingViewTag
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        overlayView.frame = view.bounds
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Blur efektli kart
        let containerView = UIView()
        containerView.backgroundColor = AppColors.cardBackground
        containerView.roundCorners(radius: AppLayout.cornerRadius)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Activity indicator (dönen yükleme simgesi)
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = AppColors.secondary
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Mesaj etiketi
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = AppFonts.medium(15)
        messageLabel.textColor = AppColors.textPrimary
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Hiyerarşi: overlay → container → [indicator, label]
        containerView.addSubview(activityIndicator)
        containerView.addSubview(messageLabel)
        overlayView.addSubview(containerView)
        view.addSubview(overlayView)
        
        // Auto Layout
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 180),
            containerView.heightAnchor.constraint(equalToConstant: 120),
            
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            
            messageLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8)
        ])
        
        // Fade in animasyonu ile göster
        overlayView.alpha = 0
        UIView.animate(withDuration: 0.2) {
            overlayView.alpha = 1
        }
    }
    
    // MARK: - Loading Göstergesini Kaldırma
    func hideLoadingOverlay() {
        guard let overlayView = view.viewWithTag(UIViewController.loadingViewTag) else { return }
        UIView.animate(withDuration: 0.2, animations: {
            overlayView.alpha = 0
        }, completion: { _ in
            overlayView.removeFromSuperview()
        })
    }
    
    // MARK: - Klavyeyi Kapatma (Tap Gesture)
    // Ekrana dokunulduğunda açık olan klavyeyi kapatır.
    // Login, register gibi metin girişi olan ekranlarda kullanılır.
    func setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardAction))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboardAction() {
        view.endEditing(true)
    }
}
