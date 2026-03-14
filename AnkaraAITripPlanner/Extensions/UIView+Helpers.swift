// MARK: - UIView+Helpers.swift
// Amaç: UIView sınıfına sık kullanılan görsel efekt ve layout yardımcıları ekler.
// Açıklama: Köşe yuvarlama, gölge ekleme, gradient katmanı, animasyonlar ve
// Auto Layout constraint kısayolları gibi tekrar eden işlemleri tek satırda
// yapabilmemizi sağlar. Bu extension'lar sayesinde ViewController'lar
// çok daha temiz ve okunabilir olur.

import UIKit

extension UIView {
    
    // MARK: - Köşe Yuvarlama
    // View'ın köşelerini yuvarlar. Kartlar, butonlar, resimler için kullanılır.
    // masksToBounds: içerik view sınırlarını aşmasın mı (gölge ile birlikte kullanımda false yapılır)
    func roundCorners(radius: CGFloat = AppLayout.cornerRadius, masksToBounds: Bool = true) {
        layer.cornerRadius = radius
        layer.masksToBounds = masksToBounds
        // iOS 13+ smooth corner kullanımı (Apple'ın kendi uygulamalarındaki gibi)
        layer.cornerCurve = .continuous
    }
    
    // MARK: - Gölge Ekleme
    // View'a profesyonel görünümlü gölge ekler.
    // Premium hissi veren subtle gölgeler oluşturmak için kullanılır.
    // Not: Gölge ile birlikte cornerRadius kullanmak için masksToBounds = false olmalı.
    func addShadow(
        color: UIColor = .black,
        opacity: Float = AppLayout.cardShadowOpacity,
        offset: CGSize = CGSize(width: 0, height: 4),
        radius: CGFloat = AppLayout.cardShadowRadius
    ) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
    
    // MARK: - Kart Stili (Corner + Shadow birlikte)
    // Hem köşe yuvarlama hem de gölge ekleme işlemini tek seferde yapar.
    // Container view + inner view yaklaşımı ile gölge ve cornerRadius birlikte çalışır.
    func applyCardStyle(cornerRadius: CGFloat = AppLayout.cornerRadius) {
        self.roundCorners(radius: cornerRadius, masksToBounds: false)
        self.addShadow()
        self.backgroundColor = AppColors.cardBackground
    }
    
    // MARK: - Gradient Arka Plan Ekleme
    // View'a dikey gradient arka plan ekler. Login ekranı, header'lar için kullanılır.
    // CAGradientLayer ekleyerek iki renk arasında yumuşak geçiş sağlar.
    @discardableResult
    func addGradient(
        colors: [UIColor],
        startPoint: CGPoint = CGPoint(x: 0.5, y: 0),
        endPoint: CGPoint = CGPoint(x: 0.5, y: 1)
    ) -> CAGradientLayer {
        // Önceki gradient varsa kaldır (yeniden ekleme durumunda)
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        
        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.frame = bounds
        gradient.cornerRadius = layer.cornerRadius
        layer.insertSublayer(gradient, at: 0)
        return gradient
    }
    
    // MARK: - Blur Efekti Ekleme (Glassmorphism)
    // View'a iOS blur efekti ekler. Modern glassmorphism tasarımı için kullanılır.
    // UIVisualEffectView ile doğal iOS blur'u sağlanır.
    func addBlurEffect(style: UIBlurEffect.Style = .systemUltraThinMaterial) {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.layer.cornerRadius = layer.cornerRadius
        blurView.clipsToBounds = true
        insertSubview(blurView, at: 0)
    }
    
    // MARK: - Kenarlık (Border) Ekleme
    func addBorder(color: UIColor = AppColors.separator, width: CGFloat = 1.0) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
    // MARK: - Fade In Animasyonu
    // View'ı yumuşak bir şekilde görünür yapar. Ekran geçişlerinde kullanılır.
    func fadeIn(duration: TimeInterval = AppAnimation.defaultDuration, completion: (() -> Void)? = nil) {
        alpha = 0
        isHidden = false
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1
        }, completion: { _ in
            completion?()
        })
    }
    
    // MARK: - Fade Out Animasyonu
    func fadeOut(duration: TimeInterval = AppAnimation.defaultDuration, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.isHidden = true
            completion?()
        })
    }
    
    // MARK: - Sarsma (Shake) Animasyonu
    // Yanlış girdi durumlarında (hatalı şifre, boş alan) dikkat çekmek için kullanılır.
    // Haptic feedback ile birlikte kullanıldığında çok etkili bir deneyim sunar.
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.duration = 0.5
        animation.values = [-8.0, 8.0, -6.0, 6.0, -4.0, 4.0, 0.0]
        layer.add(animation, forKey: "shake")
    }
    
    // MARK: - Ölçek (Scale) Animasyonu
    // Butona basıldığında küçülme/büyüme efekti için kullanılır.
    // Micro-interaction olarak kullanıcı deneyimini iyileştirir.
    func animateScale(scale: CGFloat = 0.95, duration: TimeInterval = 0.1) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: { _ in
            UIView.animate(withDuration: duration) {
                self.transform = .identity
            }
        })
    }
    
    // MARK: - Kolay Constraint Pinleme
    // View'ı parent'ına Auto Layout ile sabitler. Padding parametresiyle
    // kenarlardan boşluk bırakılabilir. Çok sık kullanılan bir kısayol.
    func pinToSuperview(padding: CGFloat = 0) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.topAnchor, constant: padding),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: padding),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -padding),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -padding)
        ])
    }
    
    // MARK: - Safe Area'ya Pinleme
    func pinToSafeArea(padding: CGFloat = 0) {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: padding),
            leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor, constant: padding),
            trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor, constant: -padding),
            bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -padding)
        ])
    }
    
    // MARK: - Boyut Constraint Kısayolu
    func setSize(width: CGFloat? = nil, height: CGFloat? = nil) {
        translatesAutoresizingMaskIntoConstraints = false
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    // MARK: - Ortalama Constraint Kısayolu
    func centerInSuperview() {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])
    }
}
