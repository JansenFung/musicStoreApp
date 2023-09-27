//
//  RecordStoreinfo.swift
//  Project_G10
//
//  Created by Jansen Fung on 2023-03-25.
//

import Foundation
import FirebaseFirestoreSwift

//Record Store Model
struct RecordStoreInfo: Codable, Hashable{
    @DocumentID var id: String? = UUID().uuidString
    var name: String
    var address: String
    var phoneNumber: String
    var website: String
    var imageURL: String
    var email: String
    var businessHours: [String]
    var isClaimed: Bool
    
    init(name: String, address: String, phoneNumber: String, website: String, imageURL: String, email: String, businessHours: [String], isClaimed: Bool) {
        self.name = name
        self.address = address
        self.phoneNumber = phoneNumber
        self.website = website
        self.imageURL = imageURL
        self.email = email
        self.businessHours = businessHours
        self.isClaimed = isClaimed
    }
    
    //Decode from Firestore JSON Object
    init?(from dictonary: [String: Any]) {
        guard let name = dictonary["name"] as? String else{
            print(#function, "Unable to read name from Firestore document")
            return nil
        }
        
        guard let address = dictonary["address"] as? String else{
            print(#function, "Unable to read address from Firestore document")
            return nil
        }
        
        guard let phoneNumber = dictonary["phoneNumber"] as? String else{
            print(#function, "Unable to read phone number from Firestore document")
            return nil
        }
        
        guard let website = dictonary["website"] as? String else{
            print(#function, "Unable to read website from Firestore document")
            return nil
        }
        
        guard let imageURL = dictonary["imageURL"] as? String else{
            print(#function, "Unable to read imageURL from Firestore document")
            return nil
        }
        
        guard let email = dictonary["email"] as? String else{
            print(#function, "Unable to read email from Firestore document")
            return nil
        }
        
        guard let businessHours = dictonary["businessHours"] as? [String] else{
            print(#function, "Unable to read businessHours from Firestore document")
            return nil
        }
        
        guard let isClaimed = dictonary["isClaimed"] as? Bool else{
            print(#function, "Unable to read isClaimed from Firestore document")
            return nil
        }
        
        self.init(name: name, address: address, phoneNumber: phoneNumber, website: website, imageURL: imageURL, email: email, businessHours: businessHours, isClaimed: isClaimed)
    }
}
