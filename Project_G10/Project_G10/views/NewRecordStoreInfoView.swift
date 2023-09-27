//
//  NewRecordStoreInfoView.swift
//  Project_G10
//
//  Created by Jansen Fung on 2023-03-26.
//

import SwiftUI

struct NewRecordStoreInfoView: View {
    @EnvironmentObject private var fireDBHelper: FireDBHelper
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var address: String = ""
    @State private var phoneNumber: String = ""
    @State private var website: String = ""
    @State private var email: String = ""
    @State private var openTime: Date = Date()
    @State private var closeTime: Date = Date()
    @State private var fromDay: String = ""
    @State private var toDay: String = ""
    @State private var fromDaySelection = 0
    @State private var toDaySelection = 0
    @State private var businessHours =  [String]()
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var alertTitle: String = ""
    @State private var submitResult: Bool = false
    
    private var week = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    var body: some View {
        VStack{
            Form{
                //Mandatory store name
                Section("Store name*"){
                    TextField("Store Name", text: self.$name)
                }
                
                //Mandatory address
                Section("Address*"){
                    TextField("Address", text: self.$address)
                }
                
                //Mandatory phone number
                Section("Phone number*"){
                    TextField("Phone Number", text: self.$phoneNumber)
                        .keyboardType(.phonePad)
                }
                
                //Mandatory business hours
                Section("Business Hours*"){
                        Picker("From", selection: self.$fromDaySelection){
                            ForEach(0..<self.week.count){
                                Text(self.week[$0])
                            }
                        }
                        Picker("To", selection: self.$toDaySelection){
                            ForEach(0..<self.week.count){
                                Text(self.week[$0])
                            }
                        }
                    
                    HStack{
                        DatePicker("From:", selection: self.$openTime, displayedComponents: .hourAndMinute)
                        DatePicker("To:", selection: self.$closeTime, displayedComponents: .hourAndMinute)
                    }//HStack ends
                }
                
                //Optional store's website
                Section("Website"){
                    TextField("website", text: self.$website)
                        .keyboardType(.URL)
                }
                
                //Optional store's email address
                Section("Eamil"){
                    TextField("email", text: self.$email)
                        .keyboardType(.emailAddress)
                }
            }
            .autocorrectionDisabled(false)
            .textInputAutocapitalization(.never)
            
            //Submit button
            Button(action:{
                self.submitResult = self.submitNewRecordStoreInfo()
            }){
                Text("Submit")
            }.tint(.indigo)
                .buttonStyle(.borderedProminent)
                .alert(isPresented: self.$showAlert){
                    Alert(title: Text("\(self.alertTitle)"),
                          message: Text("\(self.alertMessage)"),
                          dismissButton: .default(Text("Continue")){
                        
                        if self.submitResult {
                           dismiss()
                        }
                    })
                }
                
        }//VStack
        .navigationTitle("New Record Store Info")
        .navigationBarTitleDisplayMode(.inline)
    }//body ends
    
    //Insert the new record store info in firestore
    private func submitNewRecordStoreInfo() -> Bool {
        do{
            let regex = try Regex("[A-Za-z0-9]+@[A-Za-z0-9]+[.]com")
            
            let webRegex = try Regex("[A-Za-z0-9]+[.][A-Za-z0-9]+")
            
            let phoneNumRegex = try Regex("[0-9]{10}")
            
            //store's name, phone number, or address is empty
            if self.name.trimmingCharacters(in: .whitespaces).isEmpty ||
                self.address.trimmingCharacters(in: .whitespaces).isEmpty ||
                self.phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty
            {
                self.showAlert.toggle()
                self.alertTitle = "Invalid Information"
                self.alertMessage = "name, address, and phone number must not be empty"
                
                return false
                
            }
            
            //invalid phone number
            if self.phoneNumber.count != 10 || !self.phoneNumber.contains(phoneNumRegex) {
                self.showAlert.toggle()
                self.alertTitle = "Invalid Information"
                self.alertMessage = "Invalid phone number"

                return false
            }
            
            //invalid website format
            if !self.website.trimmingCharacters(in: .whitespaces).isEmpty && !self.website.lowercased().contains(webRegex){
                self.showAlert.toggle()
                self.alertTitle = "Invalid Information"
                self.alertMessage = "Invalid website format"

                return false
            }
            
            //invalid email address
            if !self.email.trimmingCharacters(in: .whitespaces).isEmpty && !self.email.lowercased().contains(regex){
                self.showAlert.toggle()
                self.alertTitle = "Invalid Information"
                self.alertMessage = "Invalid email address"

                return false
            }
            
            let email = self.email.trimmingCharacters(in: .whitespaces).isEmpty ? "not provided" : self.email
            
            let website = self.website.trimmingCharacters(in: .whitespaces).isEmpty ? "not provided" : self.website
            
            self.fromDay = self.week[self.fromDaySelection]
            self.toDay = self.week[self.toDaySelection]
            
            let businessHours = "\(self.fromDay) to \(self.toDay): \(self.openTime.formatted(date: .omitted, time: .shortened)) - \(self.closeTime.formatted(date: .omitted, time: .shortened))"
            
            self.businessHours.append(businessHours)
            
            let newRecordStoreInfo = RecordStoreInfo(name: self.name, address: self.address, phoneNumber: self.phoneNumber, website: website, imageURL: "defaultImage", email: email, businessHours: self.businessHours, isClaimed: false)
            
            self.showAlert.toggle()
            self.alertTitle = "Thank You for submitting new information"
            self.alertMessage = "The New Record Store info will be verified soon"

            //Insert the new record store info in firestore
            self.fireDBHelper.insertUnClaimedRecordStoreInfo(newRecordStoreInfo: newRecordStoreInfo)
            
            return true
        }
        catch{
            return true
        }
    }

}

struct NewRecordStoreInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NewRecordStoreInfoView()
    }
}
