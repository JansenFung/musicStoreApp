//
//  LocationHelper.swift
//  Project_G10
//
//  Created by Jansen Fung on 2023-03-27.
//

import Foundation
import CoreLocation
import MapKit
import Contacts

//Location Helper class
class LocationHelper: NSObject, ObservableObject, CLLocationManagerDelegate{
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, "Unable to receive location events: \(error.localizedDescription)")
    }
    
    //convert address into coordinate2D
    func doForwordGecoding(address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void){
        self.geocoder.geocodeAddressString(address, completionHandler: {
            (placemarks, error) in
            
            if let error = error {
                print(#function, "Unable to perform forward geocoding: \(error.localizedDescription)")
            }
            else{
                if let placemarks = placemarks?.first?.location?.coordinate{
                        completion(placemarks)
                }
                else{
                    completion(nil)
                    return
                }
            }
        })
    }
}
