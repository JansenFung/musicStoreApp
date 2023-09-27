//
//  Location.swift
//  Project_G10
//
//  Created by Jansen Fung on 2023-03-25.
//

import Foundation
import MapKit

struct Location: Identifiable{
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}
