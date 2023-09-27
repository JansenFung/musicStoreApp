//
//  FireAuthHelper.swift
//  Project_G10
//
//  Created by Jansen Fung on 2023-03-25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


//Firebase authorization Helper Singletion Class
class FireAuthHelper: ObservableObject{
    private let fireDBHelper = FireDBHelper.getInstance() ?? FireDBHelper(store: Firestore.firestore())
    
    @Published var user: User?{
        didSet{
            objectWillChange.send()
        }
    }
    
    func listenToAuthState(){
        Auth.auth().addStateDidChangeListener{
            [weak self] _, user in
            
            guard let self = self else{
                return
            }
            
            self.user = user
        }
    }
    
    //sign out
    func signOut(){
        do{
            try Auth.auth().signOut()
        }
        catch {
            print(#function, "Unable to logout \(error)")
        }
    }
    
    //create new user account with provided email and password
    func createNewAccount(email: String, password: String) async -> Bool{
        do{
            let result = try await Auth.auth().createUser(withEmail: email, password: password)

            DispatchQueue.main.async {
                self.user = result.user
                //insert new user in user collection
                self.fireDBHelper.insertUser(email: email, password: password)
            }
            return true
        }
        catch{
            print(#function, "Unable create new user \(error)")
            return false
        }
    }

    //sign in with given email and password
    func signIn(email: String, password: String) async -> Bool{
        do{
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            
            DispatchQueue.main.async {
                self.user = result.user
            }
            
            return true
        }
        catch{
            print(#function, "Unable signin \(error)")
            return false
        }
    }
}

