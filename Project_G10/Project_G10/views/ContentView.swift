//
//  ContentView.swift
//  Project_G10
//
//  Created by Jansen Fung on 2023-03-25.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject private var fireDBHelper: FireDBHelper
    @EnvironmentObject private var fireAuthHelper: FireAuthHelper
    
    @State private var linkSelection: Int?
    @State private var currentUser: String = ""
        //(Auth.auth().currentUser?.email ?? "")
    @State private var isAdminUser: Bool = false
    @State private var showNewRecordStoreInfoView: Bool = false
    @State private var showAlert: Bool = false
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack{
            NavigationLink(destination: SignInView(), tag: 1, selection: self.$linkSelection){}
            
            NavigationLink(destination: NewRecordStoreInfoView().environmentObject(self.fireDBHelper), tag: 2, selection: self.$linkSelection){}
            
            VStack{
                Text("Welcome \(self.currentUser)")
                
                TabView{
                    //record store view
                    RecordStoreView().tabItem(){
                        Image(systemName: "music.note.house.fill")
                        Text("Record Stores")
                    }
                    
                    //display admin view
                    if self.isAdminUser{
                        AdminView().tabItem(){
                            Image(systemName: "plus.circle")
                            Text("Edit")
                        }
                    }
                    
                    //favorite list view
                    if !currentUser.isEmpty{
                        FavoritesView().tabItem(){
                            Image(systemName: "heart.fill")
                            Text("Favorites")
                        }
                    }
                }
            }//VStack ends
            .navigationTitle("Record Stores")
            .navigationBarTitleDisplayMode(.large)
            .onAppear{
                UITabBar.appearance().backgroundColor = .lightText

                //update the current user
                self.currentUser = self.fireAuthHelper.user?.email ?? ""
                //Auth.auth().currentUser?.email ?? ""
                
                //check wether the cuurent user is an admin user
                if self.fireAuthHelper.user != nil{
                    Task{
                        await self.isAdminUser = self.fireDBHelper.isAdminUser()
                    }
                }
            }
            .toolbar{
                ToolbarItem(placement:.navigationBarTrailing){
                    Menu{
                        //sign in option
                        if Auth.auth().currentUser == nil{
                            Button(action:{self.linkSelection = 1}){
                                Text("Sign In")
                            }
                        }
                        else{
                            //sign out option
                            Button(action:{
                                self.showAlert.toggle()
                            }){
                                Text("Sign Out")
                            }
                        }
                        
                        //add new record store info
                        if !currentUser.isEmpty{
                            Button(action:{
                                self.linkSelection = 2
                            }){
                                Text("New Record Store")
                            }
                        }
                    }
                    label:{
                        Image(systemName: "person.fill")
                    }
                }
            }
        }//NavigationStack ends
        .background(.gray)
        //sign out alert
        .alert(isPresented: self.$showAlert){
            Alert(title: Text("Comfirm: Logout"),
                  message:Text(""),
                  primaryButton:.destructive(Text("Cancel")),
                  secondaryButton: .default(Text("Logout")){
                self.signOut()
            })
        }
    }//body ends
    
    //reset the currentUser and isAdminUser properties when signing out
    private func signOut(){
        self.fireAuthHelper.signOut()
        self.currentUser = ""
        self.isAdminUser = false
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
