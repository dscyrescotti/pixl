//
//  MapRow.swift
//  Pixl
//
//  Created by Dscyre Scotti on 28/04/2021.
//

import UIKit
import SnapKit
import Then
import MapKit

class MapRow: ReusableRow {
    
    private let mapView = MKMapView().then {
        $0.layer.cornerRadius = 10
        $0.isUserInteractionEnabled = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !subviews.isEmpty {
            mapView.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
                make.leading.trailing.equalTo(titleLabel)
                make.bottom.equalTo(self).offset(-10)
                make.height.equalTo(200)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with location: CLLocation, for title: String) {
        mapView.centerToLocation(location)
        let annotation = Annotation(title: title, locationName: nil, discipline: nil, coordinate: location.coordinate)
        mapView.addAnnotation(annotation)
        titleLabel.text = title
        if subviews.isEmpty {
            addSubview(titleLabel)
            addSubview(mapView)
        }
    }
}

extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 100) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

class Annotation: NSObject, MKAnnotation {
  let title: String?
  let locationName: String?
  let discipline: String?
  let coordinate: CLLocationCoordinate2D

  init(
    title: String?,
    locationName: String?,
    discipline: String?,
    coordinate: CLLocationCoordinate2D
  ) {
    self.title = title
    self.locationName = locationName
    self.discipline = discipline
    self.coordinate = coordinate

    super.init()
  }

  var subtitle: String? {
    return locationName
  }
}

