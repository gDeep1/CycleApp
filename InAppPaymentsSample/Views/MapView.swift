//
//  MapView.swift
//  InAppPaymentsSample
//
//  Created by GaganDeep on 2023-06-05.
//  Copyright © 2023 Stephen Josey. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

struct MapZone {
    let name: String
    let locations: [CLLocation]
}

class MapView : MKMapView {
    lazy var buyButton = ActionButton(backgroundColor: Color.primaryAction, title: "  Unlock", image: UIImage(named: "ic_cycle"))

    var isUnlockHidden: Bool = true {
        didSet {
            buyButton.isHidden = isUnlockHidden
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = Color.background
        mapType = .standard
        self.delegate = self

        setConstraints()
        
        isUnlockHidden = true
    }
    
    private func setConstraints() {
        let containerStackView = UIStackView()
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.axis = .vertical
        addSubview(containerStackView)

        let descriptionStackView = UIStackView()
        descriptionStackView.translatesAutoresizingMaskIntoConstraints = false
        descriptionStackView.spacing = 20
        descriptionStackView.axis = .vertical

        NSLayoutConstraint.activate([
            containerStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30),
        ])

        containerStackView.addArrangedSubview(descriptionStackView)
        descriptionStackView.addArrangedSubview(buyButton)
    }
}

class MapViewAnnotation: MKPointAnnotation {
    var image: UIImage?
}

extension MapView {
    /// Add annotation pins on map
    /// - Parameter punch: Punch object
    func showCycles(for zones: [MapZone]) {
        
        self.annotations.forEach {
            if !($0 is MKUserLocation) {
                self.removeAnnotation($0)
            }
        }
        
        for zone in zones {
            for location in zone.locations {
                let annotation = MapViewAnnotation()
                if #available(iOS 13.0, *) {
                    annotation.image = UIImage(named: "ic_cycle")
                } else {
                    // Fallback on earlier versions
                }
                annotation.coordinate = location.coordinate
                addAnnotation(annotation)
            }
            
            if let location = zone.locations.first?.coordinate {
                zoomToCoordinates(location)
                
                let radius: CLLocationDistance = 55
                markCircleAround(location: location, radius: radius)
            }
        }
    
    }
    
    /// Zoom to coordinates
    /// - Parameter coordinate: CLLocationCoordinate2D
    func zoomToCoordinates(_ coordinate: CLLocationCoordinate2D?) {
        guard let coordinate = coordinate else {
            return
        }
        
        centerToLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }
    
    
    /// Center to location
    /// - Parameters:
    ///   - location: location
    ///   - regionRadius: radius around location
    func centerToLocation( _ location: CLLocation, regionRadius: CLLocationDistance = 200.0) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
    
    /// Mark Circle around the location
    /// - Parameters:
    ///   - location: Location
    ///   - radius: Radius
    func markCircleAround(location: CLLocationCoordinate2D, radius: CLLocationDistance) {
        let circle = MKCircle(center: location, radius: radius)
        add(circle)
    }
}
    

// MARK: - MKMapViewDelegate
extension MapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "MapViewAnnotation")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "MapViewAnnotation")
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView?.canShowCallout = true
        }
        else {
            annotationView?.annotation = annotation
        }
        
        if let customAnnotation = annotation as? MapViewAnnotation {
            annotationView?.image = customAnnotation.image
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.2)
            circleRenderer.strokeColor = UIColor.blue
            circleRenderer.lineWidth = 2
            return circleRenderer
        }
        
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        isUnlockHidden = false
    }
}
