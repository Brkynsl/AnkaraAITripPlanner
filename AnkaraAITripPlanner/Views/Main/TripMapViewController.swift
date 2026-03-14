//
//  TripMapViewController.swift
//  AnkaraAITripPlanner
//
//  Amaç: Seçilen seyahat planındaki tüm noktalari haritada göstermek ve rota çizmek.

import UIKit
import MapKit

final class TripMapViewController: UIViewController {
    
    var plan: TripPlan?
    
    // MARK: - UI Bileşenleri
    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.delegate = self
        map.showsUserLocation = false
        map.showsCompass = true
        map.showsScale = true
        return map
    }()
    
    // Gün Segment
    private lazy var daySegmentControl: UISegmentedControl = {
        let items = ["Tümü"]
        let sc = UISegmentedControl(items: items)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = AppColors.cardBackground.withAlphaComponent(0.95)
        sc.selectedSegmentTintColor = AppColors.primary
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: AppFonts.semibold(13)], for: .selected)
        sc.setTitleTextAttributes([.foregroundColor: AppColors.textPrimary, .font: AppFonts.regular(13)], for: .normal)
        sc.addTarget(self, action: #selector(dayFilterChanged), for: .valueChanged)
        return sc
    }()
    
    // Alt bilgi kartı
    private lazy var infoCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = AppColors.cardBackground
        v.layer.cornerRadius = 20
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.addShadow(opacity: 0.15, offset: CGSize(width: 0, height: -4), radius: 12)
        return v
    }()
    
    private lazy var infoTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = AppFonts.bold(18)
        lbl.textColor = AppColors.textPrimary
        lbl.text = "Rota Detayı"
        return lbl
    }()
    
    private lazy var infoSubtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = AppFonts.regular(14)
        lbl.textColor = AppColors.textSecondary
        lbl.numberOfLines = 3
        return lbl
    }()
    
    private lazy var infoBadge: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = AppFonts.semibold(12)
        lbl.textColor = .white
        lbl.backgroundColor = AppColors.secondary
        lbl.textAlignment = .center
        lbl.layer.cornerRadius = 12
        lbl.clipsToBounds = true
        return lbl
    }()
    
    // Kapat butonu
    private lazy var closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        btn.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        btn.tintColor = AppColors.textSecondary
        btn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return btn
    }()
    
    // Rota tipini saklama
    private var allAnnotations: [NumberedAnnotation] = []
    private var hotelAnnotation: MKPointAnnotation?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDaySegments()
        loadAnnotations(forDay: nil)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = AppColors.background
        
        view.addSubview(mapView)
        view.addSubview(daySegmentControl)
        view.addSubview(infoCard)
        view.addSubview(closeButton)
        
        infoCard.addSubview(infoTitleLabel)
        infoCard.addSubview(infoSubtitleLabel)
        infoCard.addSubview(infoBadge)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: infoCard.topAnchor, constant: 20),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            
            daySegmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            daySegmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            daySegmentControl.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            daySegmentControl.heightAnchor.constraint(equalToConstant: 36),
            
            infoCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            infoCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            infoCard.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            infoCard.heightAnchor.constraint(equalToConstant: 140),
            
            infoTitleLabel.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 20),
            infoTitleLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            infoTitleLabel.trailingAnchor.constraint(equalTo: infoBadge.leadingAnchor, constant: -12),
            
            infoBadge.centerYAnchor.constraint(equalTo: infoTitleLabel.centerYAnchor),
            infoBadge.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -20),
            infoBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            infoBadge.heightAnchor.constraint(equalToConstant: 24),
            
            infoSubtitleLabel.topAnchor.constraint(equalTo: infoTitleLabel.bottomAnchor, constant: 8),
            infoSubtitleLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            infoSubtitleLabel.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -20)
        ])
        
        // Default info
        updateInfoCard(title: plan?.hotel.name ?? "Otel", subtitle: plan?.hotel.address ?? "", badge: "Konaklama")
    }
    
    private func setupDaySegments() {
        guard let plan = plan else { return }
        for (i, day) in plan.dailyPlans.enumerated() {
            daySegmentControl.insertSegment(withTitle: "Gün \(i+1)", at: i+1, animated: false)
        }
    }
    
    // MARK: - Annotations & Route
    private func loadAnnotations(forDay dayIndex: Int?) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        allAnnotations.removeAll()
        
        guard let plan = plan else { return }
        
        // Otel annotation
        let hotelAnn = MKPointAnnotation()
        hotelAnn.coordinate = plan.hotel.coordinate
        hotelAnn.title = "🏨 \(plan.hotel.name)"
        hotelAnn.subtitle = "\(plan.hotel.starRating)⭐ • ₺\(Int(plan.hotel.pricePerNight))/gece"
        mapView.addAnnotation(hotelAnn)
        self.hotelAnnotation = hotelAnn
        
        // Aktivite annotations
        var routeCoordinates: [CLLocationCoordinate2D] = [plan.hotel.coordinate]
        var counter = 1
        
        let daysToShow: [DayPlan]
        if let dayIndex = dayIndex {
            daysToShow = [plan.dailyPlans[dayIndex]]
        } else {
            daysToShow = plan.dailyPlans
        }
        
        for day in daysToShow {
            for activity in day.activities {
                let ann = NumberedAnnotation()
                ann.coordinate = activity.coordinate
                ann.title = activity.name
                ann.number = counter
                ann.dayNumber = day.dayNumber
                
                var subtitle = activity.startTime
                if let fee = activity.entryFee {
                    subtitle += fee > 0 ? " • Giriş: ₺\(Int(fee))" : " • Ücretsiz"
                }
                if let hours = activity.openingHours {
                    subtitle += " • \(hours)"
                }
                ann.subtitle = subtitle
                ann.activity = activity
                
                mapView.addAnnotation(ann)
                allAnnotations.append(ann)
                routeCoordinates.append(activity.coordinate)
                counter += 1
            }
        }
        
        // Rota çizgisi (MKPolyline)
        if routeCoordinates.count > 1 {
            let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
            mapView.addOverlay(polyline)
        }
        
        // Haritayı sığdır
        if !routeCoordinates.isEmpty {
            let region = regionForCoordinates(routeCoordinates)
            mapView.setRegion(region, animated: true)
        }
        
        // Info card güncelle
        let totalActivities = daysToShow.reduce(0) { $0 + $1.activities.count }
        let dayLabel = dayIndex != nil ? "Gün \(dayIndex! + 1)" : "Tüm Günler"
        updateInfoCard(
            title: "\(dayLabel) Rotası",
            subtitle: "\(totalActivities) nokta • \(daysToShow.first?.totalDistance ?? "~5 km") yürüyüş",
            badge: "\(totalActivities) Durak"
        )
    }
    
    private func updateInfoCard(title: String, subtitle: String, badge: String) {
        infoTitleLabel.text = title
        infoSubtitleLabel.text = subtitle
        infoBadge.text = "  \(badge)  "
    }
    
    private func regionForCoordinates(_ coords: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        var minLat = coords[0].latitude
        var maxLat = coords[0].latitude
        var minLon = coords[0].longitude
        var maxLon = coords[0].longitude
        
        for coord in coords {
            minLat = min(minLat, coord.latitude)
            maxLat = max(maxLat, coord.latitude)
            minLon = min(minLon, coord.longitude)
            maxLon = max(maxLon, coord.longitude)
        }
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.5 + 0.01, longitudeDelta: (maxLon - minLon) * 1.5 + 0.01)
        return MKCoordinateRegion(center: center, span: span)
    }
    
    // MARK: - Actions
    @objc private func dayFilterChanged() {
        let idx = daySegmentControl.selectedSegmentIndex
        if idx == 0 {
            loadAnnotations(forDay: nil)
        } else {
            loadAnnotations(forDay: idx - 1)
        }
    }
    
    @objc private func closeTapped() {
        HapticManager.shared.lightImpact()
        dismiss(animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension TripMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        // Numbered annotation (aktivite)
        if let numbered = annotation as? NumberedAnnotation {
            let id = "NumberedPin"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView
            if view == nil {
                view = MKMarkerAnnotationView(annotation: numbered, reuseIdentifier: id)
            } else {
                view?.annotation = numbered
            }
            view?.canShowCallout = true
            view?.glyphText = "\(numbered.number)"
            view?.markerTintColor = colorForDay(numbered.dayNumber)
            
            // Callout'a bilgi butonu ekle
            let btn = UIButton(type: .detailDisclosure)
            view?.rightCalloutAccessoryView = btn
            
            return view
        }
        
        // Otel annotation
        let id = "HotelPin"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView
        if view == nil {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
        } else {
            view?.annotation = annotation
        }
        view?.canShowCallout = true
        view?.glyphImage = UIImage(systemName: "bed.double.fill")
        view?.markerTintColor = AppColors.accent
        return view
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = AppColors.primary.withAlphaComponent(0.8)
            renderer.lineWidth = 3.0
            renderer.lineDashPattern = [8, 4]
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let numbered = view.annotation as? NumberedAnnotation, let activity = numbered.activity else { return }
        
        // Alert ile detay göster
        var message = activity.description
        if let fee = activity.entryFee {
            message += "\n\n💰 Giriş: \(fee > 0 ? "₺\(Int(fee))" : "Ücretsiz")"
        }
        if let hours = activity.openingHours {
            message += "\n🕐 Saat: \(hours)"
        }
        if let transport = activity.transportInfo {
            message += "\n🚇 Ulaşım: \(transport)"
        }
        if let tips = activity.tips {
            message += "\n💡 İpucu: \(tips)"
        }
        
        let alert = UIAlertController(title: activity.name, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yol Tarifi", style: .default) { _ in
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: activity.coordinate))
            mapItem.name = activity.name
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
        })
        alert.addAction(UIAlertAction(title: "Tamam", style: .cancel))
        present(alert, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        
        if let numbered = annotation as? NumberedAnnotation, let activity = numbered.activity {
            var subtitle = activity.address
            if let fee = activity.entryFee {
                subtitle += " • \(fee > 0 ? "₺\(Int(fee))" : "Ücretsiz")"
            }
            updateInfoCard(title: "\(numbered.number). \(activity.name)", subtitle: subtitle, badge: activity.category.rawValue.capitalized)
        } else if annotation === hotelAnnotation {
            updateInfoCard(title: plan?.hotel.name ?? "", subtitle: plan?.hotel.address ?? "", badge: "Konaklama")
        }
    }
    
    private func colorForDay(_ dayNumber: Int) -> UIColor {
        let colors: [UIColor] = [
            AppColors.primary,
            AppColors.secondary,
            AppColors.accent,
            UIColor(hex: "#AF52DE"),
            UIColor(hex: "#FF2D55")
        ]
        return colors[(dayNumber - 1) % colors.count]
    }
}

// MARK: - NumberedAnnotation
class NumberedAnnotation: MKPointAnnotation {
    var number: Int = 0
    var dayNumber: Int = 1
    var activity: PlannedActivity?
}
