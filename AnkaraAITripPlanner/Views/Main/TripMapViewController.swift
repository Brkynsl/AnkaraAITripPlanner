//
//  TripMapViewController.swift
//  AnkaraAITripPlanner
//

import UIKit
import MapKit

// Amaç: Kullanıcının seyahatindeki gezi noktalarını ve oteli harita üzerinde göstermek.
// Açıklama: MapKit kullanarak özel annotation'lar barındıran tam ekran harita sayfası.
// Günlere göre filtrelenebilir veya tüm yerleri gösterecek şekilde yapılandırılabilir.
final class TripMapViewController: UIViewController {

    var plan: TripPlan?
    
    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.showsUserLocation = true
        map.delegate = self
        
        if #available(iOS 16.0, *) {
            map.preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .realistic)
        } else {
            map.mapType = .standard
        }
        return map
    }()
    
    // Alt Bilgi Kartı (Seçili pine göre değişecek, şimdilik sadece Başlık-Özet gösteriyor)
    private lazy var infoCardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.background
        v.layer.cornerRadius = 24
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.1
        v.layer.shadowRadius = 10
        v.layer.shadowOffset = CGSize(width: 0, height: -5)
        return v
    }()
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Harita Görünümü"
        lbl.font = AppFonts.bold(20)
        lbl.textColor = AppColors.textPrimary
        return lbl
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "Tüm gezi noktalarınız ve oteliniz."
        lbl.font = AppFonts.regular(14)
        lbl.textColor = AppColors.textSecondary
        lbl.numberOfLines = 2
        return lbl
    }()
    
    private lazy var closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        btn.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        btn.tintColor = AppColors.textSecondary
        btn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addAnnotations()
    }
    
    private func setupUI() {
        view.backgroundColor = AppColors.background
        
        view.addSubview(mapView)
        view.addSubview(infoCardView)
        infoCardView.addSubview(titleLabel)
        infoCardView.addSubview(subtitleLabel)
        
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            infoCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            infoCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            infoCardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            infoCardView.heightAnchor.constraint(equalToConstant: 160),
            
            titleLabel.topAnchor.constraint(equalTo: infoCardView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: infoCardView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: infoCardView.trailingAnchor, constant: -24),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: infoCardView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: infoCardView.trailingAnchor, constant: -24),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func addAnnotations() {
        guard let plan = plan else { return }
        
        var annotations: [MKPointAnnotation] = []
        
        // 1. Otel Annotation
        let hotelAnno = CustomAnnotation()
        hotelAnno.coordinate = CLLocationCoordinate2D(latitude: plan.hotel.latitude, longitude: plan.hotel.longitude)
        hotelAnno.title = plan.hotel.name
        hotelAnno.subtitle = "Konaklama (Otel)"
        hotelAnno.category = .hotel
        annotations.append(hotelAnno)
        
        // 2. Gezi Noktaları
        for day in plan.dailyPlans {
            for act in day.activities {
                let actAnno = CustomAnnotation()
                actAnno.coordinate = act.coordinate
                actAnno.title = act.name
                actAnno.subtitle = "Gün \(day.dayNumber) • \(act.category.displayName)"
                actAnno.category = act.category
                annotations.append(actAnno)
            }
        }
        
        mapView.addAnnotations(annotations)
        
        // Eğer annotation yoksa çık
        guard !annotations.isEmpty else { return }
        
        // Haritayı noktaları kapsayacak şekilde Region'a ayarla
        let rect = annotations.reduce(MKMapRect.null) { (rect, anno) -> MKMapRect in
            let pointRect = MKMapRect(origin: MKMapPoint(anno.coordinate), size: MKMapSize(width: 0.1, height: 0.1))
            return rect.union(pointRect)
        }
        
        // Padding ekleyerek zoom yap
        mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 80, left: 40, bottom: 200, right: 40), animated: true)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

// MARK: - Custom Annotation & MapKit Delegate
class CustomAnnotation: MKPointAnnotation {
    var category: ActivityCategory = .other
}

extension TripMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Kullanıcı lokasyonuysa varsayılan görünümü bırak
        if annotation is MKUserLocation { return nil }
        
        guard let customAnno = annotation as? CustomAnnotation else { return nil }
        
        let identifier = "CustomPin"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            
            // Yol tarifi butonu eklenebilir
            let mapsButton = UIButton(type: .detailDisclosure)
            view.rightCalloutAccessoryView = mapsButton
        }
        
        // Kategoriye Göre Renk ve İkon
        view.glyphImage = UIImage(systemName: customAnno.category.iconName)
        
        switch customAnno.category {
        case .hotel:
            view.markerTintColor = AppColors.primary
        case .restaurant, .nightlife:
            view.markerTintColor = UIColor(hex: "#FF6B35")
        case .museum, .landmark:
            view.markerTintColor = AppColors.secondary
        case .park:
            view.markerTintColor = AppColors.success
        default:
            view.markerTintColor = AppColors.textSecondary
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Annotation'a tıklandığında alt kartı güncelle
        guard let customAnno = view.annotation as? CustomAnnotation else { return }
        titleLabel.text = customAnno.title
        subtitleLabel.text = customAnno.subtitle
        HapticManager.shared.selectionChanged()
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // İlgili lokasyon için Apple Maps açma
        guard let coordinate = view.annotation?.coordinate, let title = view.annotation?.title else { return }
        
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}
