// MARK: - ForgotPasswordViewController.swift
// Amaç: Şifre sıfırlama (Şifremi Unuttum) ekranı.
// Açıklama: Kullanıcı e-posta adresini girer, Firebase Auth aracılığıyla
//           şifre sıfırlama bağlantısı içeren bir e-posta gönderilir.
//           Başarılı olduğunda kullanıcıya bilgi mesajı gösterilir.
//
// STORYBOARD BAĞLANTISI:
//   Storyboard ID: "ForgotPasswordVC"
//   Class: ForgotPasswordViewController

import UIKit

final class ForgotPasswordViewController: UIViewController {
    
    // MARK: - ViewModel
    private let viewModel = AuthViewModel()
    
    // MARK: - UI Bileşenleri
    private var gradientLayer: CAGradientLayer?
    
    // Başlık ikon
    private lazy var iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = AppColors.accent
        let config = UIImage.SymbolConfiguration(pointSize: 48, weight: .light)
        iv.image = UIImage(systemName: "key.fill", withConfiguration: config)
        return iv
    }()
    
    // Başlık
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Şifremi Unuttum"
        label.font = AppFonts.rounded(24)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    // Açıklama
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "E-posta adresinizi girin, şifre sıfırlama bağlantısı göndereceğiz."
        label.font = AppFonts.regular(15)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // Form kartı
    private lazy var formCardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v.roundCorners(radius: AppLayout.largeCornerRadius)
        v.addBlurEffect(style: .systemUltraThinMaterialDark)
        return v
    }()
    
    // E-posta alanı
    private lazy var emailTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        tf.roundCorners(radius: AppLayout.cornerRadius)
        tf.textColor = .white
        tf.font = AppFonts.regular(16)
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.attributedPlaceholder = NSAttributedString(
            string: "E-posta adresiniz",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.4)]
        )
        
        let iconView = UIImageView(image: UIImage(systemName: "envelope.fill"))
        iconView.tintColor = UIColor.white.withAlphaComponent(0.5)
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 12, y: 0, width: 20, height: 20)
        let leftContainer = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 20))
        leftContainer.addSubview(iconView)
        tf.leftView = leftContainer
        tf.leftViewMode = .always
        
        let rightPadding = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 20))
        tf.rightView = rightPadding
        tf.rightViewMode = .always
        
        return tf
    }()
    
    // Gönder butonu
    private lazy var sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Sıfırlama Bağlantısı Gönder", for: .normal)
        btn.titleLabel?.font = AppFonts.semibold(16)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = AppColors.accent
        btn.roundCorners(radius: AppLayout.cornerRadius)
        btn.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    // Başarı mesajı container'ı (başlangıçta gizli)
    private lazy var successView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.success.withAlphaComponent(0.15)
        v.roundCorners(radius: AppLayout.cornerRadius)
        v.isHidden = true
        
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        icon.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
        icon.tintColor = AppColors.success
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Şifre sıfırlama bağlantısı e-posta adresinize gönderildi. Lütfen gelen kutunuzu kontrol edin."
        label.font = AppFonts.regular(14)
        label.textColor = .white
        label.numberOfLines = 0
        
        v.addSubview(icon)
        v.addSubview(label)
        
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 16),
            icon.centerYAnchor.constraint(equalTo: v.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 28),
            icon.heightAnchor.constraint(equalToConstant: 28),
            
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: v.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -16)
        ])
        
        return v
    }()
    
    // MARK: - Yaşam Döngüsü
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupDismissKeyboardGesture()
        setupNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    // MARK: - Navigation Bar
    private func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeTapped)
        )
    }
    
    // MARK: - UI Kurulumu
    private func setupUI() {
        let gradient = CAGradientLayer()
        gradient.colors = [AppColors.gradientStart.cgColor, AppColors.gradientEnd.cgColor]
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
        
        view.addSubview(iconImageView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(formCardView)
        formCardView.addSubview(emailTextField)
        formCardView.addSubview(sendButton)
        view.addSubview(successView)
        
        let padding = AppLayout.defaultPadding
        let largePadding = AppLayout.largePadding
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: largePadding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -largePadding),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: largePadding),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -largePadding),
            
            formCardView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
            formCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: largePadding),
            formCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -largePadding),
            
            emailTextField.topAnchor.constraint(equalTo: formCardView.topAnchor, constant: largePadding),
            emailTextField.leadingAnchor.constraint(equalTo: formCardView.leadingAnchor, constant: padding),
            emailTextField.trailingAnchor.constraint(equalTo: formCardView.trailingAnchor, constant: -padding),
            emailTextField.heightAnchor.constraint(equalToConstant: AppLayout.textFieldHeight),
            
            sendButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            sendButton.leadingAnchor.constraint(equalTo: formCardView.leadingAnchor, constant: padding),
            sendButton.trailingAnchor.constraint(equalTo: formCardView.trailingAnchor, constant: -padding),
            sendButton.heightAnchor.constraint(equalToConstant: AppLayout.buttonHeight),
            sendButton.bottomAnchor.constraint(equalTo: formCardView.bottomAnchor, constant: -largePadding),
            
            successView.topAnchor.constraint(equalTo: formCardView.bottomAnchor, constant: 20),
            successView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: largePadding),
            successView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -largePadding)
        ])
    }
    
    // MARK: - ViewModel Binding
    private func setupBindings() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self = self else { return }
            
            switch state {
            case .loading:
                self.showLoadingOverlay(message: "Gönderiliyor...")
                self.sendButton.isEnabled = false
            case .passwordResetSent:
                self.hideLoadingOverlay()
                self.sendButton.isEnabled = true
                HapticManager.shared.success()
                self.successView.isHidden = false
                self.successView.fadeIn()
                // 3 saniye sonra otomatik kapat
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.dismiss(animated: true)
                }
            case .error(let message):
                self.hideLoadingOverlay()
                self.sendButton.isEnabled = true
                HapticManager.shared.error()
                self.showErrorAlert(message: message)
            default:
                break
            }
        }
    }
    
    // MARK: - Aksiyonlar
    
    @objc private func sendButtonTapped() {
        HapticManager.shared.buttonTap()
        sendButton.animateScale()
        let email = emailTextField.text ?? ""
        viewModel.resetPassword(email: email)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
