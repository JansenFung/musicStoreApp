//
//  FireDBHelper.swift
//  Project_G10
//
//  Created by Jansen Fung on 2023-03-25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth


//Firestore Database Helper Singleton Class
class FireDBHelper: ObservableObject{
    //list of record stores info
    @Published var recordStoreList = [RecordStoreInfo]()
    //current user favorites list of record store
    @Published var currentUserFavorites = [RecordStoreInfo]()
    //list of unclaimed record store info
    @Published var unClaimedRecordStoreList = [RecordStoreInfo]()
    
    //record store info collection
    private let RECORD_STORE_COLLECTION = "Record_Stores"
    //clamied and unclamied record store document
    private let CLAIMED_UNCLAIMED_RECORD_STORES = "claimed_unclaimedRecordStores"
    //clamied record store sub-collection
    private let CLAIMED_RECORD_STORES_COLLECTION = "claimedRecordStores"
    //unclamied record store sub-collection
    private let UNCLAIMED_RECORD_STORES_COLLECTION = "unclaimedRecordStores"
    //users collection
    private let USER_COLLECTION = "USER_LIST"
    //user favorite list sub-collection
    private let FAVORITE_COLLECTION = "USER_FAVORITES_RECORD_STORE"
    
    private let store: Firestore
    
    private static var share: FireDBHelper?
    
    init(store: Firestore) {
        self.store = store
    }
    
    static func getInstance() -> FireDBHelper?{
        if self.share == nil{
            share = FireDBHelper(store: Firestore.firestore())
        }
        
        return self.share
    }
    
    //Insert new user account in user collection
    func insertUser(email: String, password: String){
        self.store.collection(self.USER_COLLECTION)
            .document(Auth.auth().currentUser?.uid ?? "")
            .setData(["email": email, "password": password, "isAdmin": false]){
                error in
               
                if let error = error {
                    print(#function, "Unable to insert in the Firestore \(error)")
                }
            }
    }
    
    //insert unclamied record store info in unclamied record store sub-collection
    func insertUnClaimedRecordStoreInfo(newRecordStoreInfo: RecordStoreInfo){
        do {
           try self.store.collection(self.RECORD_STORE_COLLECTION)
                .document(self.CLAIMED_UNCLAIMED_RECORD_STORES)
                .collection(self.UNCLAIMED_RECORD_STORES_COLLECTION)
                .addDocument(from: newRecordStoreInfo)
        }
        catch{
            print(#function, "Unable to insert in the Firestore \(error)")
        }
    }
    
    //insert clamied record store info in clamied record store sub-collection
    func insertClaimedRecordStoreInfo(newRecordStoreInfo: RecordStoreInfo){
        do {
           try self.store.collection(self.RECORD_STORE_COLLECTION)
                .document(self.CLAIMED_UNCLAIMED_RECORD_STORES)
                .collection(self.CLAIMED_RECORD_STORES_COLLECTION)
                .addDocument(from: newRecordStoreInfo)
        }
        catch{
            print(#function, "Unable to insert in the Firestore \(error)")
        }
    }
    
    //insert record store info in user favorite list sub-collection
    func insertToFavotites(selectedRecordStore: RecordStoreInfo){
        do {
            try self.store.collection(self.USER_COLLECTION)
                .document(Auth.auth().currentUser?.uid ?? "").collection(self.FAVORITE_COLLECTION)
                .addDocument(from: selectedRecordStore)
        }
        catch {
            print(#function, "Unable to insert in the Firestore \(error)")
        }
    }
    
    //delete record store info from user favorite list sub-collection
    func deleteFavorite(selectedRecordStore: RecordStoreInfo){
        self.store.collection(self.USER_COLLECTION)
            .document(Auth.auth().currentUser?.uid ?? "").collection(self.FAVORITE_COLLECTION)
            .document(selectedRecordStore.id!).delete(){
                error in
                
                if let error = error {
                    print(#function, "Unable to insert in the Firestore \(error)")
                }
            }
    }
    
    //delete unclaimed record store info from unclaimed record store sub-collection
    func deleteUnClaimedRecordStoreInfo(recordStoreInfoToDelete: RecordStoreInfo){
        self.store.collection(self.RECORD_STORE_COLLECTION)
            .document(self.CLAIMED_UNCLAIMED_RECORD_STORES)
            .collection(self.UNCLAIMED_RECORD_STORES_COLLECTION)
            .document(recordStoreInfoToDelete.id!).delete(){
                error in
                
                if let error = error {
                    print(#function, "Unable to delete from Firestore \(error)")
                }
            }
    }
    
    func updateInfoToClaimed(recordStoreInfoToUpdate: RecordStoreInfo){
        self.store.collection(self.RECORD_STORE_COLLECTION)
            .document(self.CLAIMED_UNCLAIMED_RECORD_STORES)
            .collection(self.UNCLAIMED_RECORD_STORES_COLLECTION)
            .document(recordStoreInfoToUpdate.id!).updateData(["isClaimed": true]){
                error in
                
                if let error = error {
                    print(#function, "Unable to update from Firestore \(error)")
                }
            }
            
    }
    
    //Get all record store info from claimed record store sub-collection
    func getAllRecordStoreInfo(){
        self.recordStoreList.removeAll()
        
        self.store.collection(self.RECORD_STORE_COLLECTION)
            .document(self.CLAIMED_UNCLAIMED_RECORD_STORES)
            .collection(self.CLAIMED_RECORD_STORES_COLLECTION)
            .addSnapshotListener{
                (querySnapshot, error) in
                
                guard let snapshot = querySnapshot else {
                    print(#function, "Uable to get data for Firestore")
                    return
                }
                
                snapshot.documentChanges.forEach{
                    docChange in
                    
                    do{
                        var recordStore = try docChange.document.data(as: RecordStoreInfo.self)
                        let docID = docChange.document.documentID
                        
                        recordStore.id = docID
                        
                        let matchedIndex = self.recordStoreList.firstIndex(where: {($0.id?.elementsEqual(docID))!})
                        
                        if docChange.type == .added{
                            self.recordStoreList.append(recordStore)
                        }
                        
                        if docChange.type == .removed{
                            self.recordStoreList.remove(at: matchedIndex!)
                        }
                        
                        if docChange.type == .modified {
                            self.recordStoreList[matchedIndex!]
                            = recordStore
                        }
                    }
                    catch {
                        print(#function, "Unable to covert document into Record Store object")
                    }
                }
                
            }
    }
    
    //Get current user favorite list from favorite record store sub-collection
    func getCurrentUserFavorites(){
        self.currentUserFavorites.removeAll()
        
        self.store.collection(self.USER_COLLECTION)
            .document(Auth.auth().currentUser?.uid ?? "").collection(self.FAVORITE_COLLECTION)
            .addSnapshotListener{
                (querySnapshot, error) in
                
                guard let snapshot = querySnapshot else {
                    print(#function, "Uable to get data for Firestore")
                    return
                }
                
                snapshot.documentChanges.forEach{
                    docChange in
                    
                    do{
                        var recordStore = try docChange.document.data(as: RecordStoreInfo.self)
                        let docID = docChange.document.documentID
                        
                        recordStore.id = docID
                        
                        let matchedIndex = self.currentUserFavorites.firstIndex(where: {($0.id?.elementsEqual(docID))!})
                        
                        if docChange.type == .added{
                            self.currentUserFavorites.append(recordStore)
                        }
                        
                        if docChange.type == .removed{
                            if matchedIndex != nil {
                                self.currentUserFavorites.remove(at: matchedIndex!)
                            }
                        }
                        
                        if docChange.type == .modified {
                            if matchedIndex != nil {
                                self.currentUserFavorites[matchedIndex!]
                                = recordStore
                            }
                        }
                    }
                    catch {
                        print(#function, "Unable to covert document into Record Store object")
                    }
                }
                
            }
    }
    
    //Get all unclaimed record stores info from unclamied record store sub-collection
    func getAllUnClaimedRecordStoreInfo(){
        self.unClaimedRecordStoreList.removeAll()
        
        self.store.collection(self.RECORD_STORE_COLLECTION)
            .document(self.CLAIMED_UNCLAIMED_RECORD_STORES)
            .collection(self.UNCLAIMED_RECORD_STORES_COLLECTION)
            .addSnapshotListener{
                (querySnapshot, error) in
                
                guard let snapshot = querySnapshot else {
                    print(#function, "Uable to get data for Firestore")
                    return
                }
                
                snapshot.documentChanges.forEach{
                    docChange in
                    
                    do{
                        var recordStore = try docChange.document.data(as: RecordStoreInfo.self)
                        
                        let docID = docChange.document.documentID
                        recordStore.id = docID
                        
                        let matchedIndex = self.unClaimedRecordStoreList.firstIndex(where: {($0.id?.elementsEqual(docID))!})
                        
                        if docChange.type == .added{
                            self.unClaimedRecordStoreList.append(recordStore)
                        }
                        
                        if docChange.type == .modified {
                            if matchedIndex != nil {
                                self.unClaimedRecordStoreList[matchedIndex!]
                                = recordStore
                            }
                        }
                        
                        if docChange.type == .removed{
                            if matchedIndex != nil {
                                self.unClaimedRecordStoreList.remove(at: matchedIndex!)
                            }
                        }
                        
                        print(#function, self.unClaimedRecordStoreList.count)
                    }
                    catch {
                        print(#function, "Unable to covert document into Record Store object")
                    }
                }
            }
    }
    
    //Check whether the current user is an admin user
    func isAdminUser() async -> Bool{
        do{
            let currentUser = try await self.store.collection(self.USER_COLLECTION)
                .document(Auth.auth().currentUser?.uid ?? "")
                .getDocument()
            
            if currentUser.exists {
                if let data = currentUser.data(){
                    guard let isAdmin = data["isAdmin"] as? Bool else{
                        return false
                    }
                    
                    return isAdmin
                }
                else{
                    print(#function, "current user data is nil")
                    return false
                }
            }
            else{
                print(#function, "no current user")
                return false
            }
        }
        catch{
            print(#function, "Unable to ge document \(error)")
            return false
        }
//        {
//                  doc, error in
//
//                  if doc != nil{
//                      if let user = doc?.data(){
//                          guard let isAdmin = user["isAdmin"] as? Bool else{
//                              print(#function, "failed")
//                              return
//                          }
//
//                          self.isCurrentUserAdmin = isAdmin
//
//                              UserDefaults.standard.set(isAdmin, forKey: "IS_ADMIN")
//
//                              print(#function, "\(isAdmin)")
//
//                      }
//                  }
//                  else{
//                      print(#function, "nil")
//                  }
//              }
    }
}
