//
//  UnclaimedRecordStoreDetailView.swift
//  Project_G10
//
//  Created by Jansen Fung on 2023-03-26.
//

import SwiftUI

struct UnclaimedRecordStoreDetailView: View {
    @EnvironmentObject private var fireDBHelper: FireDBHelper
    @Environment(\.dismiss) var dismiss
    
    let selectedIndex: Int
    let selectedUnClaimedInfo: RecordStoreInfo
    
    private let gridItem:[GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ScrollView{
            VStack{
                if !self.fireDBHelper.unClaimedRecordStoreList.isEmpty{
                    //store name
                    Text("Name: \(self.selectedUnClaimedInfo.name)")
                        .padding(3)
                        .font(.title2)
                        .bold()
                    
                    //image
                    AsyncImage(url: URL(string:"\(self.selectedUnClaimedInfo.imageURL)")){
                        phase in
                        
                        //display default image if the image url is not available
                        if let error = phase.error {
                            Image(systemName: "photo.fill")
                                .resizable()
                                .frame(width: 250, height: 250)
                        }
                        
                        else if let image = phase.image{
                            image.resizable()
                                .frame(width: 250, height: 250)
                                .overlay(RoundedRectangle(cornerRadius: 3).stroke(.gray, lineWidth: 2))
                        }
                    }
                    
                    VStack{
                        Text("\(self.selectedUnClaimedInfo.isClaimed ? "Clamied" : "Unclamied")")
                            .padding(3)
                            .font(.title3)
                        
                        //address
                        VStack{
                            Text("Address:")
                                .padding(3)
                                .font(.title3)
                                .bold()
                            
                            Text("\(self.selectedUnClaimedInfo.address)")
                                .padding(.horizontal, 100)
                                .font(.title3)
                        }
                        .padding(3)
                        
                        //business hours
                        VStack{
                            Text("Business Hours:").font(.title3)
                                .padding(3)
                                .bold()
                            
                            ForEach(self.selectedUnClaimedInfo
                                .businessHours.enumerated().map{$0}, id:\.element.self){
                                    index, businessHours in
                                    Text("\(businessHours)")
                                        .padding(3)
                                        .font(.title3)
                                }
                        }
                        .padding(3)
                        
                        //phone number
                        HStack{
                            Text("Phone Number: ")
                                .padding(3)
                                .font(.title3)
                                .bold()
                            
                            Text("\(self.selectedUnClaimedInfo.phoneNumber)")
                                .padding(3)
                                .font(.title3)
                        }
                        .padding(3)
                            
                        //email address
                        HStack{
                            Text("Email: ")
                                .padding(3)
                                .font(.title3)
                                .bold()
                            Text("\(self.selectedUnClaimedInfo.email)")
                                .padding(3)
                                .font(.title3)
                            
                        }.padding(3)
                        
                        //website
                        HStack{
                            Text("Website: ")
                                .padding(3)
                                .font(.title3)
                                .bold()
                            
                            Text("\(self.selectedUnClaimedInfo.website)")
                                .padding(3)
                                .font(.title3)
                        }.padding(3)
                    }//VStack ends
                }//end if
                
                //Cofirm or Delete buttons
                LazyVGrid(columns: self.gridItem){
                    Button(action:{
                        //self.claimInfo()
                        Task{
                            await self.insetToClaimed()
                        }
                        
                    }){
                        Text("Confirm")
                    }
                    .tint(.green)
                    .buttonStyle(.borderedProminent)
                    
                    Button(action:{
                        self.deleteUnClaimedInfo()
                    }){
                        Text("Delete")
                    }
                    .tint(.red)
                    .buttonStyle(.borderedProminent)
                }//LazyVGrid ends
            }//VStack ends
        }//ScrollView ends
    }//body ends
    
    private func deleteUnClaimedInfo(){
        self.fireDBHelper.deleteUnClaimedRecordStoreInfo(recordStoreInfoToDelete: self.selectedUnClaimedInfo)
        
        dismiss()
    }
    
//    private func claimInfo(){
//        self.fireDBHelper.updateInfoToClaimed(recordStoreInfoToUpdate: self.selectedUnClaimedInfo)
//    }
    
    private func insetToClaimed() {
        self.fireDBHelper.updateInfoToClaimed(recordStoreInfoToUpdate: self.selectedUnClaimedInfo)
        
        self.fireDBHelper.insertClaimedRecordStoreInfo(newRecordStoreInfo: self.selectedUnClaimedInfo)
            
        self.deleteUnClaimedInfo()
            
        dismiss()
    }
}

//struct UnclaimedRecordStoreDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        UnclaimedRecordStoreDetailView()
//    }
//}
