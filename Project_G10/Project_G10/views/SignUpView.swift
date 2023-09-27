//
//  SignUpView.swift
//  Project_G10
//
//  Created by Jansen Fung on 2023-03-25.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var fiewAuthHelper: FireAuthHelper
    @Environment(\.dismiss) private var dismiss
    
    @State private var rememberEmail: Bool = false
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var showPassword: Bool = false
    @State var showConfirmPassword: Bool = false
    @State var showErrorAlert: Bool = false
    @State var errorMessage: String = ""
    
    var body: some View {
        VStack(alignment: .leading){
            
            //email address
            Section("Email"){
                TextField("Email Address", text: self.$email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
            }
            
            //password
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
            }
            
            //confirm password
            Section("Confirm Password"){
                //show confirm password
                if self.showConfirmPassword {
                    ZStack(alignment: .trailingLastTextBaseline){
                        TextField("Confirm Password", text: self.$confirmPassword)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                        Image(systemName: "eye.slash.fill")
                            .onTapGesture {
                                self.showConfirmPassword.toggle()
                            }
                    }
                }
                //hide confirm password
                else{
                    ZStack(alignment: .trailingLastTextBaseline){
                        SecureField("Confirm Password", text: self.$confirmPassword)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                        
                        Image(systemName: "eye.fill")
                            .onTapGesture {
                                self.showConfirmPassword.toggle()
                            }
                    }
                }
            }
            
            //remember email address toogle
            Toggle("Remember email address", isOn: self.$rememberEmail).padding(10)
            
            //Create new user account
            HStack(alignment: .center){
                Spacer()
                Button(action:{
                    Task{
                        await self.createNewAccount(email:self.email    ,password:self.password,confirmPassword:self.confirmPassword)
                    }
                })
                {
                    Text("Create New Account")
                }
                .tint(.indigo)
                .buttonStyle(.borderedProminent)
                .alert(isPresented: self.$showErrorAlert){
                    Alert(title: Text("Invalid Email or Password"),
                          message: Text("\(self.errorMessage)"),
                          dismissButton: .default(Text("Continue")))
                }
                
                Spacer()
            }//HStack ends
            .padding()
        }//VStack ends
        .padding(.horizontal)
    }
    
    private func createNewAccount(email: String, password: String, confirmPassword: String) async{
        do{
            let regex = try Regex("[A-Za-z0-9]+@[A-Za-z0-9]+[.](com|ca)")
           
            //email, password or confirm password is empty
            if password.trimmingCharacters(in: .whitespaces).isEmpty ||
                email.trimmingCharacters(in: .whitespaces).isEmpty ||
                confirmPassword.trimmingCharacters(in: .whitespaces).isEmpty{
                
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
            
            //invalid password length or invalid confirm password length
            if password.count < 6 || confirmPassword.count < 6 {
                   self.showErrorAlert.toggle()
                   self.errorMessage = "Password must be at least 6 characters"
                   return
            }
            
            //password and confirm password do not match
            if password != confirmPassword{
                self.showErrorAlert.toggle()
                self.errorMessage = "Password and Confirm Password do not match"
                return
            }
            
            //create new account
            if await self.fiewAuthHelper.createNewAccount(email: email.lowercased(), password: password)
            {
                //if user switch the rememberEmail toggle to true
                //save the user email address in UserDefaults
                if self.rememberEmail {
                    UserDefaults.standard.set(email, forKey: "USER_EMAIL")
                }
                //remove the user email address from UserDefaults
                else{
                    UserDefaults.standard.removeObject(forKey: "USER_EMAIL")
                }
                   
                dismiss()
            }
            else{
                self.showErrorAlert.toggle()
                self.errorMessage = "Email address already taken by other users"
                return
                
            }
        }
        catch{
            print(#function, "Unable to convert Regular Expression \(error)")
        }
    }
}

//struct SignUpView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignUpView()
//    }
//}
