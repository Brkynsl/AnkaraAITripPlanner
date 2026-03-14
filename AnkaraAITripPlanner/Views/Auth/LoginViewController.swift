// MARK: - LoginViewController.swift
// Amaç: Kullanıcının uygulamaya giriş yapmasını sağlayan ana ekran.
// Açıklama: Premium ve modern bir login arayüzü sunar. Gradient arka plan,
//           illüstratif şehir silhouette, sosyal giriş butonları ve e-posta
//           ile giriş formu içerir. MVVM pattern'de AuthViewModel'i kullanarak
//           tüm iş mantığını ViewModel'e bırakır. ViewController sadece
//           UI oluşturma ve güncelleme işlemlerinden sorumludur.
//
// STORYBOARD BAĞLANTISI:
//   Storyboard ID: "LoginVC"
//   Class: LoginViewController
//   Segue'ler: "showRegister" → RegisterVC, "showForgotPassword" → ForgotPasswordVC
//
// Bu dosya programmatic UI kullanır çünkü Storyboard'da Auto Layout constraint'leri
// daha kolay yönetilir. Storyboard'da boş bir VC oluşturup class bağlantısı yapın.

import UIKit
import AuthenticationServices

// Google Sign-In SDK importu — SPM ile eklenmeli
// import GoogleSignIn

final class LoginViewController: UIViewController {
    
    // MARK: - ViewModel
    private let viewModel = AuthViewModel()
    
    // MARK: - UI Bileşenleri
    // Programmatic olarak oluşturulan UI elemanları.
    // lazy var kullanıyoruz çünkü ViewController yüklenene kadar oluşturulmasını istemiyoruz.
    
    // Gradient arka plan katmanı — login ekranına derinlik katar
    private var gradientLayer: CAGradientLayer?
    
    // Ana scroll view — küçük ekranlarda içerik taşmasını önler
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()
    
    // Scroll view'ın içerik container'ı
    private lazy var contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // Uygulama ikon/logo alanı — şehir temalı illüstrasyon yerine büyük uçak ikonu
    private lazy var logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = AppColors.secondary
        let config = UIImage.SymbolConfiguration(pointSize: 64, weight: .thin)
        iv.image = UIImage(systemName: "airplane.departure", withConfiguration: config)
        return iv
    }()
    
    // Uygulama başlığı
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = AppInfo.appName
        label.font = AppFonts.rounded(28)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // Alt başlık / slogan
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = AppInfo.appTagline
        label.font = AppFonts.light(16)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.textAlignment = .center
        return label
    }()
    
    // Şehir silhouette dekoratif görünümü — arka planda atmosfer oluşturur
    private lazy var cityScapeView: CityScapeView = {
        let v = CityScapeView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // MARK: - Form Alanları Container (Blur kart)
    private lazy var formCardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v.roundCorners(radius: AppLayout.largeCornerRadius)
        v.addBlurEffect(style: .systemUltraThinMaterialDark)
        return v
    }()
    
    // E-posta text field
    private lazy var emailTextField: UITextField = {
        let tf = createStyledTextField(placeholder: "E-posta adresiniz", icon: "envelope.fill")
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.textContentType = .emailAddress
        return tf
    }()
    
    // Şifre text field
    private lazy var passwordTextField: UITextField = {
        let tf = createStyledTextField(placeholder: "Şifreniz", icon: "lock.fill")
        tf.isSecureTextEntry = true
        tf.textContentType = .password
        return tf
    }()
    
    // Giriş Yap butonu — ana CTA
    private lazy var loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Giriş Yap", for: .normal)
        btn.titleLabel?.font = AppFonts.semibold(17)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = AppColors.accent
        btn.roundCorners(radius: AppLayout.cornerRadius)
        btn.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    // Şifremi Unuttum butonu
    private lazy var forgotPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Şifremi Unuttum", for: .normal)
        btn.titleLabel?.font = AppFonts.medium(14)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .normal)
        btn.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Ayırıcı Çizgi ("veya" yazısı ile)
    private lazy var dividerView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let leftLine = UIView()
        leftLine.translatesAutoresizingMaskIntoConstraints = false
        leftLine.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        
        let rightLine = UIView()
        rightLine.translatesAutoresizingMaskIntoConstraints = false
        rightLine.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "veya"
        label.font = AppFonts.regular(13)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.textAlignment = .center
        
        container.addSubview(leftLine)
        container.addSubview(rightLine)
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            leftLine.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            leftLine.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            leftLine.heightAnchor.constraint(equalToConstant: 0.5),
            leftLine.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -12),
            
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            rightLine.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 12),
            rightLine.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            rightLine.heightAnchor.constraint(equalToConstant: 0.5),
            rightLine.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            container.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        return container
    }()
    
    // MARK: - Sosyal Giriş Butonları
    
    // Apple ile giriş butonu — ASAuthorizationAppleIDButton kullanıyoruz (Apple kuralı)
    private lazy var appleSignInButton: ASAuthorizationAppleIDButton = {
        let btn = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.cornerRadius = AppLayout.cornerRadius
        btn.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
        return btn
    }()
    
    // Google ile giriş butonu
    private lazy var googleSignInButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("  Google ile Giriş Yap", for: .normal)
        btn.titleLabel?.font = AppFonts.semibold(15)
        btn.setTitleColor(UIColor(hex: "#4285F4"), for: .normal)
        btn.backgroundColor = .white
        btn.roundCorners(radius: AppLayout.cornerRadius)
        // Google "G" ikonu yerine SF Symbol kullanıyoruz (gerçek projede Google logo kullanılır)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        btn.setImage(UIImage(systemName: "g.circle.fill", withConfiguration: config), for: .normal)
        btn.tintColor = UIColor(hex: "#4285F4")
        btn.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Kayıt Ol Butonu (Alt kısım)
    private lazy var registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        let text = "Hesabınız yok mu? Kayıt Ol"
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.6),
                .font: AppFonts.regular(14)
            ]
        )
        // "Kayıt Ol" kısmını vurgula
        if let range = text.range(of: "Kayıt Ol") {
            let nsRange = NSRange(range, in: text)
            attributedString.addAttributes([
                .foregroundColor: AppColors.secondary,
                .font: AppFonts.semibold(14)
            ], range: nsRange)
        }
        
        btn.setAttributedTitle(attributedString, for: .normal)
        btn.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Yaşam Döngüsü
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupDismissKeyboardGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Gradient katmanını view boyutuna göre güncelle
        gradientLayer?.frame = view.bounds
    }
    
    // Status bar'ı beyaz yap (koyu arka plan için)
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - UI Kurulumu
    private func setupUI() {
        // Arka plan fallback
        view.backgroundColor = AppColors.background
        
        // Gradient arka plan
        let gradient = CAGradientLayer()
        gradient.colors = [AppColors.gradientStart.cgColor, AppColors.gradientEnd.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
        
        // Şehir silhouette arka planı
        view.addSubview(cityScapeView)
        
        // Scroll view ekleme
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Logo ve başlık
        contentView.addSubview(logoImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        // Form kartı
        contentView.addSubview(formCardView)
        formCardView.addSubview(emailTextField)
        formCardView.addSubview(passwordTextField)
        formCardView.addSubview(loginButton)
        formCardView.addSubview(forgotPasswordButton)
        
        // Ayırıcı ve sosyal girişlar için stack view
        let socialStackView = UIStackView(arrangedSubviews: [
            dividerView,
            appleSignInButton,
            googleSignInButton
        ])
        socialStackView.translatesAutoresizingMaskIntoConstraints = false
        socialStackView.axis = .vertical
        socialStackView.spacing = 16
        
        contentView.addSubview(socialStackView)
        contentView.addSubview(registerButton)
        
        setupConstraints(socialStack: socialStackView)
        addHoverEffectsToButtons()
    }
    
    // MARK: - Auto Layout Constraint'leri
    private func setupConstraints(socialStack: UIStackView) {
        let padding = AppLayout.defaultPadding
        let largePadding = AppLayout.largePadding
        
        NSLayoutConstraint.activate([
            // Şehir silhouette
            cityScapeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cityScapeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cityScapeView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cityScapeView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25),
            
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Logo
            logoImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 40),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            
            // Başlık
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: largePadding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -largePadding),
            
            // Alt başlık
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: largePadding),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -largePadding),
            
            // Form kartı
            formCardView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            formCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: largePadding),
            formCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -largePadding),
            
            // Form öğeleri
            emailTextField.topAnchor.constraint(equalTo: formCardView.topAnchor, constant: largePadding),
            emailTextField.leadingAnchor.constraint(equalTo: formCardView.leadingAnchor, constant: padding),
            emailTextField.trailingAnchor.constraint(equalTo: formCardView.trailingAnchor, constant: -padding),
            emailTextField.heightAnchor.constraint(equalToConstant: AppLayout.buttonHeight),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 12),
            passwordTextField.leadingAnchor.constraint(equalTo: formCardView.leadingAnchor, constant: padding),
            passwordTextField.trailingAnchor.constraint(equalTo: formCardView.trailingAnchor, constant: -padding),
            passwordTextField.heightAnchor.constraint(equalToConstant: AppLayout.buttonHeight),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            loginButton.leadingAnchor.constraint(equalTo: formCardView.leadingAnchor, constant: padding),
            loginButton.trailingAnchor.constraint(equalTo: formCardView.trailingAnchor, constant: -padding),
            loginButton.heightAnchor.constraint(equalToConstant: AppLayout.buttonHeight),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 12),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: formCardView.centerXAnchor),
            forgotPasswordButton.bottomAnchor.constraint(equalTo: formCardView.bottomAnchor, constant: -padding),
            
            // Sosyal Giriş Stack
            socialStack.topAnchor.constraint(equalTo: formCardView.bottomAnchor, constant: 32),
            socialStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: largePadding),
            socialStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -largePadding),
            
            appleSignInButton.heightAnchor.constraint(equalToConstant: AppLayout.buttonHeight),
            googleSignInButton.heightAnchor.constraint(equalToConstant: AppLayout.buttonHeight),
            
            // Kayıt ol linki - Çok daha belirgin mesafe
            registerButton.topAnchor.constraint(equalTo: socialStack.bottomAnchor, constant: 40),
            registerButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            registerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - ViewModel Binding
    // ViewModel'deki state değişikliklerini dinler ve UI'ı günceller.
    private func setupBindings() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self = self else { return }
            
            switch state {
            case .idle:
                break
                
            case .loading:
                self.showLoadingOverlay(message: "Giriş yapılıyor...")
                self.loginButton.isEnabled = false
                
            case .success(let user):
                self.hideLoadingOverlay()
                self.loginButton.isEnabled = true
                HapticManager.shared.success()
                
                // Onboarding kontrolü ve yönlendirme
                self.handleSuccessfulLogin(user: user)
                
            case .error(let message):
                self.hideLoadingOverlay()
                self.loginButton.isEnabled = true
                HapticManager.shared.error()
                self.showErrorAlert(message: message)
                // Hatalı alanları kırmızı ile vurgula
                self.emailTextField.shake()
                
            case .passwordResetSent:
                break // LoginVC'de kullanılmaz
            }
        }
    }
    
    // MARK: - Başarılı Giriş Sonrası Yönlendirme
    // Kullanıcı onboarding'i tamamlamışsa MainTabBar'a, tamamlamamışsa Onboarding'e gider.
    private func handleSuccessfulLogin(user: AppUser) {
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding)
        if user.hasCompletedOnboarding || hasSeenOnboarding {
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasCompletedOnboarding)
            SceneDelegate.shared?.showMainScreen()
        } else {
            SceneDelegate.shared?.showOnboarding()
        }
    }
    
    // MARK: - IBAction / Buton Aksiyonları
    
    @objc private func loginButtonTapped() {
        HapticManager.shared.buttonTap()
        loginButton.animateScale()
        
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        viewModel.signInWithEmail(email: email, password: password)
    }
    
    @objc private func forgotPasswordTapped() {
        HapticManager.shared.buttonTap()
        let forgotVC = ForgotPasswordViewController()
        let nav = UINavigationController(rootViewController: forgotVC)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }
    
    @objc private func registerTapped() {
        HapticManager.shared.buttonTap()
        let registerVC = RegisterViewController()
        // Register'dan dönüş sonrası login durumunu kontrol et
        registerVC.onRegistrationSuccess = { [weak self] user in
            self?.handleSuccessfulLogin(user: user)
        }
        let nav = UINavigationController(rootViewController: registerVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    // MARK: - Apple Sign-In
    @objc private func appleSignInTapped() {
        HapticManager.shared.buttonTap()
        
        let nonce = viewModel.generateAppleNonce()
        let hashedNonce = viewModel.sha256ForNonce(nonce)
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = hashedNonce
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // MARK: - Google Sign-In
    @objc private func googleSignInTapped() {
        HapticManager.shared.buttonTap()
        
        // Google Sign-In SDK Entegrasyonu Notu:
        // Uygulamanıza Google ile Giriş eklemek için:
        // 1. Firebase Console > Authentication > Sign-in Method kısmından Google'ı aktif edin.
        // 2. GoogleService-Info.plist dosyasını güncelleyip projeye ekleyin.
        // 3. Info.plist'e REVERSED_CLIENT_ID için URL Scheme ekleyin.
        
        let alert = UIAlertController(
            title: "Google ile Giriş",
            message: "Google Sign-In entegrasyonu için SDK kurulumu gerekmektedir. Firebase üzerinden Google'ı aktif ettiyseniz, lütfen GoogleService-Info.plist dosyanızı güncellediğinizden emin olun.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Anladım", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Yardımcı: Stilli TextField Oluşturma
    // Tüm text field'lar aynı görünüme sahip olsun diye tek bir metotla oluşturuyoruz.
    // Sol tarafta ikon, saydam arka plan, yuvarlak köşeler.
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
        
        // Sol ikon
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = UIColor.white.withAlphaComponent(0.5)
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 12, y: 0, width: 20, height: 20)
        
        let leftContainer = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 20))
        leftContainer.addSubview(iconView)
        tf.leftView = leftContainer
        tf.leftViewMode = .always
        
        // Sağ padding
        let rightPadding = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 20))
        tf.rightView = rightPadding
        tf.rightViewMode = .always
        
        return tf
    }
    
    // MARK: - Buton Hover Efektleri
    // Butonlara basıldığında küçülme efekti ekler — micro-interaction
    private func addHoverEffectsToButtons() {
        [loginButton, googleSignInButton].forEach { button in
            button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        }
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
    }
}

// MARK: - Apple Sign-In Delegate
// iOS ASAuthorizationController'dan gelen sonuçları işler.
extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let identityTokenData = appleIDCredential.identityToken,
           let identityToken = String(data: identityTokenData, encoding: .utf8),
           let nonce = viewModel.activeNonce {
            
            viewModel.signInWithApple(idToken: identityToken, nonce: nonce)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Kullanıcı iptal ettiyse hata gösterme
        if (error as? ASAuthorizationError)?.code == .canceled {
            return
        }
        showErrorAlert(message: "Apple ile giriş yapılamadı: \(error.localizedDescription)")
    }
}

// MARK: - Apple Sign-In Presentation Context
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

// MARK: - CityScapeView (Şehir Silhouette)
// Login arka planında dekoratif şehir manzarası çizer.
// CoreGraphics ile özel çizim yaparak illüstratif bir görünüm oluşturur.
// Bu view login ekranının premium hissini artırır.
final class CityScapeView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let width = rect.width
        let height = rect.height
        let baseY = height
        
        // Bina rengi — yarı saydam beyaz
        let buildingColor = UIColor.white.withAlphaComponent(0.06)
        context.setFillColor(buildingColor.cgColor)
        
        // Binaların rastgele ama tutarlı boyutları
        let buildings: [(x: CGFloat, w: CGFloat, h: CGFloat)] = [
            (0, 35, height * 0.4),
            (30, 25, height * 0.55),
            (52, 40, height * 0.7),
            (88, 30, height * 0.45),
            (115, 20, height * 0.6),
            (132, 35, height * 0.8),
            (164, 28, height * 0.5),
            (190, 22, height * 0.65),
            (210, 38, height * 0.75),
            (245, 26, height * 0.42),
            (268, 32, height * 0.58),
            (298, 45, height * 0.85), // En yüksek bina (kule)
            (340, 28, height * 0.48),
            (365, 35, height * 0.62),
            (397, 22, height * 0.5),
        ]
        
        // Ekran genişliğine göre binaları ölçekle
        let scaleX = width / 420.0
        
        for building in buildings {
            let x = building.x * scaleX
            let w = building.w * scaleX
            let h = building.h
            let buildingRect = CGRect(x: x, y: baseY - h, width: w, height: h)
            
            // Yuvarlak köşeli binalar
            let path = UIBezierPath(roundedRect: buildingRect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 3, height: 3))
            context.addPath(path.cgPath)
            context.fillPath()
            
            // Bina pencereleri — küçük sarı kareler
            let windowColor = UIColor.yellow.withAlphaComponent(0.08)
            context.setFillColor(windowColor.cgColor)
            
            let windowSize: CGFloat = 3 * scaleX
            let windowSpacing: CGFloat = 6 * scaleX
            
            var wy = baseY - h + 8
            while wy < baseY - 8 {
                var wx = x + 4 * scaleX
                while wx < x + w - 4 * scaleX {
                    let windowRect = CGRect(x: wx, y: wy, width: windowSize, height: windowSize)
                    context.fill(windowRect)
                    wx += windowSpacing
                }
                wy += windowSpacing + 2
            }
            
            // Bina rengini geri yükle
            context.setFillColor(buildingColor.cgColor)
        }
    }
}
