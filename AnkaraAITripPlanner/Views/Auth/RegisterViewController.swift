// MARK: - RegisterViewController.swift
// Amaç: Yeni kullanıcı kaydı (sign up) ekranı.
// Açıklama: Ad soyad, e-posta, şifre ve şifre tekrarı alanlarıyla
//           yeni hesap oluşturma formunu sunar. AuthViewModel aracılığıyla
//           form doğrulama ve Firebase kayıt işlemini gerçekleştirir.
//           Kayıt başarılı olduğunda login ekranına callback ile bildirir.
//
// STORYBOARD BAĞLANTISI:
//   Storyboard ID: "RegisterVC"
//   Class: RegisterViewController

import UIKit

final class RegisterViewController: UIViewController {
    
    // MARK: - ViewModel
    private let viewModel = AuthViewModel()
    
    // Kayıt başarılı olduğunda LoginVC'ye bildirim gönderen closure
    var onRegistrationSuccess: ((AppUser) -> Void)?
    
    // MARK: - UI Bileşenleri
    private var gradientLayer: CAGradientLayer?
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()
    
    private lazy var contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // Sayfa başlığı
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hesap Oluştur"
        label.font = AppFonts.rounded(28)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    // Alt açıklama
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Seyahat planlarınızı oluşturmaya başlayın"
        label.font = AppFonts.light(15)
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // Form container - blur kartı
    private lazy var formCardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v.roundCorners(radius: AppLayout.largeCornerRadius)
        v.addBlurEffect(style: .systemUltraThinMaterialDark)
        return v
    }()
    
    // Ad Soyad
    private lazy var nameTextField: UITextField = {
        return createStyledTextField(placeholder: "Ad Soyad", icon: "person.fill")
    }()
    
    // E-posta
    private lazy var emailTextField: UITextField = {
        let tf = createStyledTextField(placeholder: "E-posta adresiniz", icon: "envelope.fill")
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        return tf
    }()
    
    // Şifre
    private lazy var passwordTextField: UITextField = {
        let tf = createStyledTextField(placeholder: "Şifre (en az 6 karakter)", icon: "lock.fill")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    // Şifre Tekrar
    private lazy var confirmPasswordTextField: UITextField = {
        let tf = createStyledTextField(placeholder: "Şifre tekrar", icon: "lock.rotation")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    // Kayıt Ol butonu
    private lazy var registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Kayıt Ol", for: .normal)
        btn.titleLabel?.font = AppFonts.semibold(17)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = AppColors.secondary
        btn.roundCorners(radius: AppLayout.cornerRadius)
        btn.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    // Giriş yap linki
    private lazy var loginLinkButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        let text = "Zaten hesabınız var mı? Giriş Yap"
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.6),
                .font: AppFonts.regular(14)
            ]
        )
        if let range = text.range(of: "Giriş Yap") {
            let nsRange = NSRange(range, in: text)
            attributedString.addAttributes([
                .foregroundColor: AppColors.accent,
                .font: AppFonts.semibold(14)
            ], range: nsRange)
        }
        
        btn.setAttributedTitle(attributedString, for: .normal)
        btn.addTarget(self, action: #selector(loginLinkTapped), for: .touchUpInside)
        return btn
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
    
    // MARK: - Navigation Bar Ayarları
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
        // Arka plan rengi (Gradient yüklenene kadar veya alternatif olarak)
        view.backgroundColor = AppColors.background
        
        // Gradient arka plan
        let gradient = CAGradientLayer()
        gradient.colors = [AppColors.gradientStart.cgColor, AppColors.gradientEnd.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(formCardView)
        
        // Form öğelerini bir stack view içine alıyoruz (Daha düzenli ve hatasız layout için)
        let stackView = UIStackView(arrangedSubviews: [
            nameTextField,
            emailTextField,
            passwordTextField,
            confirmPasswordTextField,
            registerButton
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.distribution = .fillEqually
        
        formCardView.addSubview(stackView)
        contentView.addSubview(loginLinkButton)
        
        // Form elemanlarının yüksekliğini stack view içinde de korumak için
        [nameTextField, emailTextField, passwordTextField, confirmPasswordTextField, registerButton].forEach {
            $0.heightAnchor.constraint(equalToConstant: AppLayout.buttonHeight).isActive = true
        }
        
        setupConstraints(stackView: stackView)
    }
    
    // MARK: - Constraint'ler
    private func setupConstraints(stackView: UIStackView) {
        let padding = AppLayout.defaultPadding
        let largePadding = AppLayout.largePadding
        
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
            
            headerLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 60),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: largePadding),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -largePadding),
            
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: largePadding),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -largePadding),
            
            formCardView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            formCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: largePadding),
            formCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -largePadding),
            
            stackView.topAnchor.constraint(equalTo: formCardView.topAnchor, constant: largePadding),
            stackView.leadingAnchor.constraint(equalTo: formCardView.leadingAnchor, constant: padding),
            stackView.trailingAnchor.constraint(equalTo: formCardView.trailingAnchor, constant: -padding),
            stackView.bottomAnchor.constraint(equalTo: formCardView.bottomAnchor, constant: -largePadding),
            
            loginLinkButton.topAnchor.constraint(equalTo: formCardView.bottomAnchor, constant: 32),
            loginLinkButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loginLinkButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - ViewModel Binding
    private func setupBindings() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self = self else { return }
            
            switch state {
            case .idle:
                break
            case .loading:
                self.showLoadingOverlay(message: "Kayıt yapılıyor...")
                self.registerButton.isEnabled = false
            case .success(let user):
                self.hideLoadingOverlay()
                self.registerButton.isEnabled = true
                HapticManager.shared.success()
                // Önce dismiss, sonra callback
                self.dismiss(animated: true) {
                    self.onRegistrationSuccess?(user)
                }
            case .error(let message):
                self.hideLoadingOverlay()
                self.registerButton.isEnabled = true
                HapticManager.shared.error()
                self.showErrorAlert(message: message)
            case .passwordResetSent:
                break
            }
        }
    }
    
    // MARK: - Aksiyonlar
    
    @objc private func registerButtonTapped() {
        HapticManager.shared.buttonTap()
        registerButton.animateScale()
        
        let name = nameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let confirmPassword = confirmPasswordTextField.text ?? ""
        
        viewModel.signUpWithEmail(
            name: name,
            email: email,
            password: password,
            confirmPassword: confirmPassword
        )
    }
    
    @objc private func loginLinkTapped() {
        HapticManager.shared.buttonTap()
        dismiss(animated: true)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - TextField Oluşturma Yardımcısı
    private func createStyledTextField(placeholder: String, icon: String) -> UITextField {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        tf.roundCorners(radius: AppLayout.cornerRadius)
        tf.textColor = .white
        tf.font = AppFonts.regular(16)
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.4)]
        )
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
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
    }
}
