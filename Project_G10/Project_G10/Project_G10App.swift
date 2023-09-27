//
//  Project_G10App.swift
//  Project_G10
//
//  Created by Jansen Fung on 2023-03-25.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore

@main
struct Project_G10App: App {
    let fireDBHelper: FireDBHelper
    let fireAuthHelper: FireAuthHelper
    let locationHelper: LocationHelper
   
    init(){
        FirebaseApp.configure()
        self.fireDBHelper = FireDBHelper.getInstance() ?? FireDBHelper(store: Firestore.firestore())
        self.fireAuthHelper = FireAuthHelper()
        self.locationHelper = LocationHelper()
       // UserDefaults.standard.set("", forKey: "CURRENT_USER")
    }
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(self.fireDBHelper)
                .environmentObject(self.fireAuthHelper)
                .environmentObject(self.locationHelper)
        }
    }
}
