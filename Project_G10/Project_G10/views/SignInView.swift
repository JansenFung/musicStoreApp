//
//  SignInView.swift
//  Project_G10
//
//  Created by Jansen Fung on 2023-03-25.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @EnvironmentObject private var fireAuthHelper: FireAuthHelper
    @Environment(\.dismiss) private var dismiss
    
    @State private var rememberEmail: Bool = false
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showSignUpView: Bool = false
    @State private var showPassword: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var linkSelection: Int?
    @State private var currentUser: String = Auth.auth().currentUser?.email ?? ""
    
    private let gridItems: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(alignment: .leading){
            NavigationLink(destination: SignUpView(), tag: 2, selection: self.$linkSelection){}
            
            //Email address
            Section("Email Address"){
                TextField("Email Address", text: self.$email)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
            }
            
            //Password
            Section("Password"){
                //show password
                if self.showPassword {
                    ZStack(alignment: .trailingLastTextBaseline){
                        TextField("Password", text: self.$password)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                        Image(systemName: "eye.slash.fill")
                            .onTapGesture {
                                self.showPassword.toggle()
                            }
                    }//ZStack
                }
                //hide password
                else{
                    ZStack(alignment: .trailingLastTextBaseline){
                        SecureField("Password", text: self.$password)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                        
                        Image(systemName: "eye.fill")
                            .onTapGesture {
                                self.showPassword.toggle()
                            }
                    }//ZStack ends
                }
            }//Section ends
            
            //Remember email address
            Toggle("Remember email address", isOn: self.$rememberEmail).padding(10)
            
            //SignIn and SignUp
            LazyVGrid(columns: self.gridItems){
                //Sign In
                Button(action:{
                    Task{
                        await self.signIn(email:self.email,password:self.password)
                    }
                }){
                    Text("Sign In")
                }
                .alert(isPresented: self.$showErrorAlert){
                    Alert(title: Text("Invalid Email or Password"),
                          message: Text("\(self.errorMessage)"),
                          dismissButton: .default(Text("Continue")))
                }
                .tint(.indigo)
                .buttonStyle(.borderedProminent)
                
                //Sign Up
                Button(action:{
                    self.linkSelection = 2
                }){
                    Text("Sign Up")
                }
                .tint(.indigo)
                .buttonStyle(.borderedProminent)
//                .sheet(isPresented: self.$showSignUpView){
//                    SignUpView().environmentObject(self.fireAuthHelper)
//                }
            }
            .padding()
        }//VStack ends
        .padding(.horizontal)
        .onAppear(){
            //dimiss the view if the user is signed in
            self.currentUser =
                Auth.auth().currentUser?.email ?? ""
            
            if !currentUser.isEmpty{
                dismiss()
            }
            
            //get the email address from UserDefault if the user chooses the "remember" option
            let rememberEmail = UserDefaults.standard.string(forKey: "USER_EMAIL") ?? ""
            
            self.email = rememberEmail
        }
    }//body ends

    private func signIn(email: String, password: String) async{
        do {
            let regex = try Regex("[A-Za-z0-9]+@[A-Za-z0-9]+[.](com|ca)")
            
            //email or password is empty
            if password.trimmingCharacters(in: .whitespaces).isEmpty ||
                 email.trimmingCharacters(in: .whitespaces).isEmpty
             {
                 self.showErrorAlert.toggle()
                 self.errorMessage = "Email and password cannot be empty"
                 return
             }
            
            //invalid email address
            if !email.lowercased().contains(regex) {
                self.showErrorAlert.toggle()
                self.errorMessage = "Invaild Email address"
                return
            }

            //Invalid password length
            if password.count < 6 {
                self.showErrorAlert.toggle()
                self.errorMessage = "Password must be at least 6 characters"
                return
            }
            
            //call fireAuthHelper.signIn()
            if await self.fireAuthHelper.signIn(email: email.lowercased(), password: password)
            {
                //if user switch the rememberEmail toggle to true
                //save the user email address in UserDefaults
                if self.rememberEmail {
                    UserDefaults.standard.set(email, forKey: "USER_EMAIL")
                }
                //Otherwise remove the user email address from UserDefaults
                else {
                    UserDefaults.standard.removeObject(forKey: "USER_EMAIL")
                }
                
                dismiss()
            }
            //sign in failed
            else{
                self.showErrorAlert.toggle()
                self.errorMessage = "Invalid email address or password"
            }
        }
        catch{
            print(#function, "Unable to convert Regular Expression \(error)")
        }
    }
}

//struct SignInView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignInView()
//    }
//}
