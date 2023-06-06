//
//  MapViewType.swift
//  InAppPaymentsSample
//
//  Created by GaganDeep on 2023-06-06.
//  Copyright © 2023 Stephen Josey. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import UIKit

struct MapZone {
    let name: String
    let locations: [CLLocation]
}

class MapViewAnnotation: MKPointAnnotation {
    var image: UIImage?
}
