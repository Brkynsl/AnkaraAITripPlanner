// MARK: - OnboardingContainerViewController.swift
// Amaç: Onboarding (uygulama tanıtım) ekranlarının ana container'ı.
// Açıklama: UICollectionView ile yatay kaydırmalı sayfa yapısı oluşturur.
//           Her sayfa uygulamanın bir özelliğini tanıtan içerik gösterir.
//           "İlerle", "Atla" ve son sayfada "Başla" butonları içerir.
//           Sayfa göstergesi (dots) mevcut sayfayı belirtir.
//           Tamamlandığında Firestore'da onboarding durumu güncellenir.
//
// STORYBOARD BAĞLANTISI:
//   Storyboard ID: "OnboardingContainerVC"
//   Class: OnboardingContainerViewController

import UIKit

final class OnboardingContainerViewController: UIViewController {
    
    // MARK: - ViewModel
    private let viewModel = OnboardingViewModel()
    
    // Mevcut sayfa indeksi
    private var currentPage = 0
    
    // MARK: - UI Bileşenleri
    private var gradientLayer: CAGradientLayer?
    
    // Yatay kaydırmalı collection view — her hücre bir onboarding sayfası
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.isPagingEnabled = true // Sayfa sayfa kayma efekti
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(OnboardingPageCell.self, forCellWithReuseIdentifier: OnboardingPageCell.reuseID)
        return cv
    }()
    
    // Sayfa göstergesi (dots)
    private lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.numberOfPages = viewModel.totalPages
        pc.currentPage = 0
        pc.currentPageIndicatorTintColor = AppColors.secondary
        pc.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
        pc.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)
        return pc
    }()
    
    // İlerle / Başla butonu
    private lazy var nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("İlerle", for: .normal)
        btn.titleLabel?.font = AppFonts.semibold(17)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = AppColors.secondary
        btn.roundCorners(radius: AppLayout.cornerRadius)
        btn.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    // Atla butonu (sağ üst köşede)
    private lazy var skipButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Atla", for: .normal)
        btn.titleLabel?.font = AppFonts.medium(15)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .normal)
        btn.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Yaşam Döngüsü
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
        // Collection view hücre boyutunu güncelle
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = collectionView.bounds.size
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    // MARK: - UI Kurulumu
    private func setupUI() {
        // Gradient arka plan
        let gradient = CAGradientLayer()
        gradient.colors = [
            AppColors.gradientStart.cgColor,
            AppColors.primary.cgColor,
            AppColors.gradientEnd.cgColor
        ]
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
        
        view.addSubview(skipButton)
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(nextButton)
        
        let padding = AppLayout.largePadding
        
        NSLayoutConstraint.activate([
            // Atla butonu — sağ üst
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            // Collection view — ortada, ekranın büyük kısmını kaplar
            collectionView.topAnchor.constraint(equalTo: skipButton.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -24),
            
            // Sayfa göstergesi
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -24),
            
            // İlerle / Başla butonu — alt kısımda
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: AppLayout.buttonHeight)
        ])
    }
    
    // MARK: - Sayfa Güncelleme
    // Mevcut sayfaya göre buton metinlerini ve görünümlerini günceller.
    private func updateUIForCurrentPage() {
        pageControl.currentPage = currentPage
        
        if viewModel.isLastPage(currentPage) {
            // Son sayfada "Başla" butonu göster ve "Atla" butonunu gizle
            nextButton.setTitle("Başla", for: .normal)
            nextButton.backgroundColor = AppColors.accent
            skipButton.fadeOut(duration: 0.2)
        } else {
            nextButton.setTitle("İlerle", for: .normal)
            nextButton.backgroundColor = AppColors.secondary
            skipButton.isHidden = false
            skipButton.alpha = 1
        }
    }
    
    // MARK: - Aksiyonlar
    
    @objc private func nextButtonTapped() {
        HapticManager.shared.buttonTap()
        nextButton.animateScale()
        
        if viewModel.isLastPage(currentPage) {
            // Son sayfa — onboarding'i tamamla
            completeOnboarding()
        } else {
            // Sonraki sayfaya git
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            updateUIForCurrentPage()
        }
    }
    
    @objc private func skipButtonTapped() {
        HapticManager.shared.buttonTap()
        completeOnboarding()
    }
    
    @objc private func pageControlChanged() {
        currentPage = pageControl.currentPage
        let indexPath = IndexPath(item: currentPage, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        updateUIForCurrentPage()
    }
    
    // MARK: - Onboarding Tamamlama
    // ViewModel aracılığıyla Firestore'da durumu günceller ve ana ekrana yönlendirir.
    private func completeOnboarding() {
        HapticManager.shared.success()
        
        viewModel.completeOnboarding { [weak self] _ in
            self?.navigateToMain()
        }
    }
    
    // MARK: - Ana Ekrana Geçiş
    private func navigateToMain() {
        guard let window = view.window else { return }
        
        let mainVC = MainTabBarController()
        
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = mainVC
        }, completion: nil)
    }
}

// MARK: - UICollectionView DataSource
extension OnboardingContainerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.totalPages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OnboardingPageCell.reuseID,
            for: indexPath
        ) as? OnboardingPageCell else {
            return UICollectionViewCell()
        }
        
        let page = viewModel.pages[indexPath.item]
        cell.configure(with: page)
        return cell
    }
}

// MARK: - UICollectionView Delegate & FlowLayout
extension OnboardingContainerViewController: UICollectionViewDelegateFlowLayout {
    
    // Her hücre tam ekran boyutunda
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return collectionView.bounds.size
    }
    
    // Kaydırma bittiğinde mevcut sayfayı güncelle
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        if page != currentPage {
            currentPage = page
            updateUIForCurrentPage()
            HapticManager.shared.selection()
        }
    }
}
